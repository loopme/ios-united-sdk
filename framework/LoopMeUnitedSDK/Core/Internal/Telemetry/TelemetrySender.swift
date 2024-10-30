//
//  TelemetrySender.swift
//  LoopMeUnitedSDK
//
//  Created by Lukasz Tomaszewski on 29/10/2024.
//

import Foundation

enum TelemetrySendStatus {
    case success(TelemetryEvent)
    case failure(TelemetryEvent, Error)
}

class TelemetrySender {
    private let url: URL
    private let urlSession: URLSession
    private let sendQueue = DispatchQueue(label: "telemetry.sender.queue", qos: .default)
    
    init?(apiEndpoint: String, urlSession: URLSession = .shared) {
        guard let url = URL(string: apiEndpoint) else {
            return nil
        }
        self.url = url
        self.urlSession = urlSession
    }
    
    func sendEvents(_ events: [TelemetryEvent], completion: @escaping ([TelemetrySendStatus]) -> Void) {
        sendQueue.async {
            self.processEvents(events: events, completion: completion)
        }
    }
    
    private func processEvents(events: [TelemetryEvent], completion: @escaping ([TelemetrySendStatus]) -> Void) {
        guard !events.isEmpty else {
            DispatchQueue.main.async {
                completion([])
            }
            return
        }
        
        let dispatchGroup = DispatchGroup()
        var sendStatuses = [TelemetrySendStatus]()
        let statusesQueue = DispatchQueue(label: "telemetry.sender.statuses.queue", qos: .background)
        
        for event in events {
            dispatchGroup.enter()
            sendEvent(event, retryCount: 3, completion: { status in
                statusesQueue.sync {
                    sendStatuses.append(status)
                }
                dispatchGroup.leave()
            })
        }
        
        dispatchGroup.notify(queue: .main) {
            completion(sendStatuses)
        }
    }

    private func sendEvent(_ event: TelemetryEvent, retryCount: Int, completion: @escaping (TelemetrySendStatus) -> Void) {
        send(event) { result in
            switch result {
            case .success:
                completion(.success(event))
            case .failure(let error):
                if retryCount > 1 {
                    let delay: TimeInterval
                    switch retryCount {
                    case 2: delay = 0.5 // 400ms for the second retry
                    case 1: delay = 1.0 // 600ms for the third retry
                    default: delay = 0.0
                    }
                    
                    DispatchQueue.global().asyncAfter(deadline: .now() + delay) {
                        self.sendEvent(event, retryCount: retryCount - 1, completion: completion)
                    }
                } else {
                    completion(.failure(event, error))
                }
            }
        }
    }
    
    private func send(_ event: TelemetryEvent, completion: @escaping (Result<Void, Error>) -> Void) {
        var request = URLRequest(url: self.url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: event.toDictionary(), options: [])
            
            let task = urlSession.dataTask(with: request) { _, response, error in
                if let error = error {
                    completion(.failure(error))
                } else if let httpResponse = response as? HTTPURLResponse,
                          (200...299).contains(httpResponse.statusCode) {
                    completion(.success(()))
                } else {
                    let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
                    let error = NSError(domain: "TelemetrySendError", code: statusCode, userInfo: [
                        NSLocalizedDescriptionKey: "Failed to send event, status code: \(statusCode)"
                    ])
                    completion(.failure(error))
                }
            }
            task.resume()
        } catch {
            completion(.failure(error))
        }
    }
}
