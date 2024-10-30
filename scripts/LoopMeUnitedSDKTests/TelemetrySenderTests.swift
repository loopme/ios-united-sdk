//
//  TelemetrySenderTests.swift
//  LoopMeUnitedSDK
//
//  Created by [Your Name] on 30/10/2024.
//

import Foundation
import Testing
@testable import LoopMeUnitedSDK

@Suite(.serialized) struct TelemetrySenderTests {

    // Helper function to create a TelemetryEvent of type .sessionStart
    func createSessionStartEvent(sessionID: String) throws -> TelemetryEvent {
        let sessionIDAttribute = try EventAttributeValue(attribute: .session_id, value: sessionID)
        let createdAtAttribute = try EventAttributeValue(attribute: .created_at, value: Date())
        let mediationAttribute = try EventAttributeValue(attribute: .mediation, value: "mediationName")
        let platformAttribute = try EventAttributeValue(attribute: .platform, value: "iOS")
        let versionAttribute = try EventAttributeValue(attribute: .version, value: "1.0")
        let adapterVersionAttribute = try EventAttributeValue(attribute: .adapter_version, value: "1.0")
        let packageAttribute = try EventAttributeValue(attribute: .package, value: "com.example.app")

        let event = try TelemetryEvent(
            type: .sessionStart,
            attributes: [
                sessionIDAttribute,
                createdAtAttribute,
                mediationAttribute,
                platformAttribute,
                versionAttribute,
                adapterVersionAttribute,
                packageAttribute
            ]
        )

        return event
    }

    @Test("Test sending a single event successfully")
    func testSendSingleEventSuccess() {
        // Set up URLSession with MockURLProtocol
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        let urlSession = URLSession(configuration: configuration)

        // Initialize TelemetrySender
        guard let telemetrySender = TelemetrySender(
            apiEndpoint: "https://mockapi.example.com/telemetry",
            urlSession: urlSession
        ) else {
            Issue.record("Failed to create TelemetrySender")
            return
        }

        // Set up MockURLProtocol to return a successful response
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            let data = Data()
            return (response, data)
        }

        // Create the TelemetryEvent
        do {
            let event = try createSessionStartEvent(sessionID: "session123")

            var statuses: [TelemetrySendStatus] = []
            var completionCalled = false

            // Use a DispatchGroup to wait for the asynchronous operation to complete
            let dispatchGroup = DispatchGroup()
            dispatchGroup.enter()

            telemetrySender.sendEvents([event]) { sendStatuses in
                statuses = sendStatuses
                completionCalled = true
                dispatchGroup.leave()
            }

            // Wait for the dispatch group to finish
            let waitResult = dispatchGroup.wait(timeout: .now() + 1)
            #expect(waitResult == .success, "Timeout waiting for sendEvents to complete")
            #expect(completionCalled, "Completion block was not called")
            #expect(statuses.count == 1)
            if case .success(let returnedEvent) = statuses.first {
                #expect(returnedEvent.id == event.id)
                #expect(returnedEvent.type == event.type)
                #expect(returnedEvent.attributes.count == event.attributes.count)
            } else {
                Issue.record("Expected success status")
            }
        } catch {
            Issue.record("Failed to create TelemetryEvent: \(error)")
        }
    }

    @Test("Test sending multiple events successfully")
    func testSendMultipleEventsSuccess() {
        // Set up URLSession with MockURLProtocol
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        let urlSession = URLSession(configuration: configuration)

        // Initialize TelemetrySender
        guard let telemetrySender = TelemetrySender(
            apiEndpoint: "https://mockapi.example.com/telemetry",
            urlSession: urlSession
        ) else {
            Issue.record("Failed to create TelemetrySender")
            return
        }

        // Set up MockURLProtocol to return a successful response
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            let data = Data()
            return (response, data)
        }

        do {
            let event1 = try createSessionStartEvent(sessionID: "session1")
            let event2 = try createSessionStartEvent(sessionID: "session2")
            let event3 = try createSessionStartEvent(sessionID: "session3")

            let events = [event1, event2, event3]
            var statuses: [TelemetrySendStatus] = []
            var completionCalled = false

            // Use a DispatchGroup to wait for the asynchronous operation to complete
            let dispatchGroup = DispatchGroup()
            dispatchGroup.enter()

            telemetrySender.sendEvents(events) { sendStatuses in
                statuses = sendStatuses
                completionCalled = true
                dispatchGroup.leave()
            }

            // Wait for the dispatch group to finish
            let waitResult = dispatchGroup.wait(timeout: .now() + 2)
            #expect(waitResult == .success, "Timeout waiting for sendEvents to complete")
            #expect(completionCalled, "Completion block was not called")
            #expect(statuses.count == events.count)
            for (status, event) in zip(statuses, events) {
                if case .success(let returnedEvent) = status {
                    #expect(returnedEvent.id == event.id)
                    #expect(returnedEvent.type == event.type)
                    #expect(returnedEvent.attributes.count == event.attributes.count)
                } else {
                    Issue.record("Expected success status for event with id \(event.id)")
                }
            }
        } catch {
            Issue.record("Failed to create TelemetryEvents: \(error)")
        }
    }

    @Test("Test retry logic succeeds after a retry")
    func testRetryLogicSuccessAfterRetry() {
        // Set up URLSession with MockURLProtocol
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        let urlSession = URLSession(configuration: configuration)

        // Initialize TelemetrySender
        guard let telemetrySender = TelemetrySender(
            apiEndpoint: "https://mockapi.example.com/telemetry",
            urlSession: urlSession
        ) else {
            Issue.record("Failed to create TelemetrySender")
            return
        }

        var attemptCount = 0

        // Set up MockURLProtocol to fail the first time and succeed the second time
        MockURLProtocol.requestHandler = { request in
            attemptCount += 1
            if attemptCount == 1 {
                // Simulate network error
                throw NSError(domain: "NetworkError", code: -1, userInfo: nil)
            } else {
                let response = HTTPURLResponse(
                    url: request.url!,
                    statusCode: 200,
                    httpVersion: nil,
                    headerFields: nil
                )!
                let data = Data()
                return (response, data)
            }
        }

        do {
            let event = try createSessionStartEvent(sessionID: "sessionRetry")

            var statuses: [TelemetrySendStatus] = []
            var completionCalled = false

            // Use a DispatchGroup to wait for the asynchronous operation to complete
            let dispatchGroup = DispatchGroup()
            dispatchGroup.enter()

            telemetrySender.sendEvents([event]) { sendStatuses in
                statuses = sendStatuses
                completionCalled = true
                dispatchGroup.leave()
            }

            // Wait for the dispatch group to finish
            let waitResult = dispatchGroup.wait(timeout: .now() + 2)
            #expect(waitResult == .success, "Timeout waiting for sendEvents to complete")
            #expect(completionCalled, "Completion block was not called")
            #expect(statuses.count == 1)
            if case .success(let returnedEvent) = statuses.first {
                #expect(returnedEvent.id == event.id)
                #expect(returnedEvent.type == event.type)
                #expect(returnedEvent.attributes.count == event.attributes.count)
            } else {
                Issue.record("Expected success status after retry")
            }

            #expect(attemptCount == 2, "Expected 2 attempts, got \(attemptCount)")
        } catch {
                Issue.record("Failed to create TelemetryEvent: \(error)")
        }
    }

    @Test("Test retry logic fails after retries exhausted")
    func testRetryExhausted() {
        // Set up URLSession with MockURLProtocol
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        let urlSession = URLSession(configuration: configuration)

        // Initialize TelemetrySender
        guard let telemetrySender = TelemetrySender(
            apiEndpoint: "https://mockapi.example.com/telemetry",
            urlSession: urlSession
        ) else {
            Issue.record("Failed to create TelemetrySender")
            return
        }

        var attemptCount = 0

        // Set up MockURLProtocol to always fail
        MockURLProtocol.requestHandler = { request in
            attemptCount += 1
            // Simulate network error
            throw NSError(domain: "NetworkError", code: -1, userInfo: nil)
        }

        do {
            let event = try createSessionStartEvent(sessionID: "sessionFail")

            var statuses: [TelemetrySendStatus] = []
            var completionCalled = false

            // Use a DispatchGroup to wait for the asynchronous operation to complete
            let dispatchGroup = DispatchGroup()
            dispatchGroup.enter()

            telemetrySender.sendEvents([event]) { sendStatuses in
                statuses = sendStatuses
                completionCalled = true
                dispatchGroup.leave()
            }

            // Wait for the dispatch group to finish
            let waitResult = dispatchGroup.wait(timeout: .now() + 5)
            #expect(waitResult == .success, "Timeout waiting for sendEvents to complete")
            #expect(completionCalled, "Completion block was not called")
            #expect(statuses.count == 1)
            if case .failure(let returnedEvent, let error) = statuses.first {
                #expect(returnedEvent.id == event.id)
                #expect(returnedEvent.type == event.type)
                #expect(error != nil)
            } else {
                Issue.record("Expected failure status after retries exhausted")
            }

            #expect(attemptCount == 3, "Expected 3 attempts, got \(attemptCount)")
        } catch {
            Issue.record("Failed to create TelemetryEvent: \(error)")
        }
    }

    @Test("Test completion block is called")
    func testCompletionBlockCalled() {
        // Set up URLSession with MockURLProtocol
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        let urlSession = URLSession(configuration: configuration)

        // Initialize TelemetrySender
        guard let telemetrySender = TelemetrySender(
            apiEndpoint: "https://mockapi.example.com/telemetry",
            urlSession: urlSession
        ) else {
            Issue.record("Failed to create TelemetrySender")
            return
        }

        // Set up MockURLProtocol to return a successful response
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            let data = Data()
            return (response, data)
        }

        do {
            let event1 = try createSessionStartEvent(sessionID: "session1")
            let event2 = try createSessionStartEvent(sessionID: "session2")

            let events = [event1, event2]
            var statuses: [TelemetrySendStatus] = []
            var completionCalled = false

            // Use a DispatchGroup to wait for the asynchronous operation to complete
            let dispatchGroup = DispatchGroup()
            dispatchGroup.enter()

            telemetrySender.sendEvents(events) { sendStatuses in
                statuses = sendStatuses
                completionCalled = true
                dispatchGroup.leave()
            }

            // Wait for the dispatch group to finish
            let waitResult = dispatchGroup.wait(timeout: .now() + 1)
            #expect(waitResult == .success, "Timeout waiting for sendEvents to complete")
            #expect(completionCalled, "Completion block was not called")
            #expect(statuses.count == events.count)
        } catch {
            Issue.record("Failed to create TelemetryEvents: \(error)")
        }
    }

    @Test("Test that operations are queued")
    func testQueueOperations() {
        // Set up URLSession with MockURLProtocol
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        let urlSession = URLSession(configuration: configuration)

        // Initialize TelemetrySender
        guard let telemetrySender = TelemetrySender(
            apiEndpoint: "https://mockapi.example.com/telemetry",
            urlSession: urlSession
        ) else {
            Issue.record("Failed to create TelemetrySender")
            return
        }

        var statuses1: [TelemetrySendStatus] = []
        var statuses2: [TelemetrySendStatus] = []
        var completionCalled1 = false
        var completionCalled2 = false

        // Set up MockURLProtocol to simulate delay
        MockURLProtocol.requestHandler = { request in
            Thread.sleep(forTimeInterval: 0.1)
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, Data())
        }

        do {
            let event1 = try createSessionStartEvent(sessionID: "sessionQueue1")
            let event2 = try createSessionStartEvent(sessionID: "sessionQueue2")

            // Use DispatchGroups to wait for the asynchronous operations to complete
            let dispatchGroup1 = DispatchGroup()
            dispatchGroup1.enter()
            telemetrySender.sendEvents([event1]) { sendStatuses in
                statuses1 = sendStatuses
                completionCalled1 = true
                dispatchGroup1.leave()
            }

            let dispatchGroup2 = DispatchGroup()
            dispatchGroup2.enter()
            telemetrySender.sendEvents([event2]) { sendStatuses in
                statuses2 = sendStatuses
                completionCalled2 = true
                dispatchGroup2.leave()
            }

            // Wait for both dispatch groups to finish
            let waitResult1 = dispatchGroup1.wait(timeout: .now() + 2)
            let waitResult2 = dispatchGroup2.wait(timeout: .now() + 2)
            #expect(waitResult1 == .success, "Timeout waiting for first sendEvents to complete")
            #expect(waitResult2 == .success, "Timeout waiting for second sendEvents to complete")
            #expect(completionCalled1, "First completion block was not called")
            #expect(completionCalled2, "Second completion block was not called")
            #expect(statuses1.count == 1)
            #expect(statuses2.count == 1)

            if case .success(let returnedEvent1) = statuses1.first {
                #expect(returnedEvent1.id == event1.id)
            } else {
                Issue.record("Expected success status for event 1")
            }

            if case .success(let returnedEvent2) = statuses2.first {
                #expect(returnedEvent2.id == event2.id)
            } else {
                Issue.record("Expected success status for event 2")
            }
        } catch {
            Issue.record("Failed to create TelemetryEvents: \(error)")
        }
    }
}
