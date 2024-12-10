//
//  TelemetrySender.swift
//  LoopMeUnitedSDK
//
//  Created by Lukasz Tomaszewski on 29/10/2024.
//

import Foundation

@objc(TelemetrySendStatus)
enum TelemetrySendStatus: Int {
    case success
    case failure
}

@objc(TelemetrySender)
public class TelemetrySender: NSObject {
    private let url: URL
    private let urlSession: URLSession
    private let sendQueue = DispatchQueue(label: "telemetry.sender.queue", qos: .default)
    
    @objc public init?(apiEndpoint: String) {
        guard let url = URL(string: apiEndpoint) else {
            return nil
        }
        self.url = url
        self.urlSession = URLSession.shared
    }
    
    @objc public func sendEvents(
        _ events: [NSDictionary],
        completion: @escaping ([NSDictionary]) -> Void
    ) {
        sendQueue.async {
            let swiftEvents = events.compactMap { TelemetryEvent.from(dictionary: $0) }
            self.processEvents(events: swiftEvents) { statuses in
                let objcStatuses = statuses.map { $0.toDictionary() }
                DispatchQueue.main.async {
                    completion(objcStatuses)
                }
            }
        }
    }
    
    private func processEvents(
        events: [TelemetryEvent],
        completion: @escaping ([TelemetrySendStatusWrapper]) -> Void
    ) {
        guard !events.isEmpty else {
            DispatchQueue.main.async {
                completion([])
            }
            return
        }
        
        let dispatchGroup = DispatchGroup()
        var sendStatuses = [TelemetrySendStatusWrapper]()
        let statusesQueue = DispatchQueue(label: "telemetry.sender.statuses.queue", qos: .background)
        
        for event in events {
            dispatchGroup.enter()
            sendEvent(event, retryCount: 3) { status in
                statusesQueue.sync {
                    sendStatuses.append(status)
                }
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            completion(sendStatuses)
        }
    }
    
    private func sendEvent(
        _ event: TelemetryEvent,
        retryCount: Int,
        completion: @escaping (TelemetrySendStatusWrapper) -> Void
    ) {
        send(event) { result in
            switch result {
            case .success:
                completion(TelemetrySendStatusWrapper(status: .success, event: event))
            case .failure(let error):
                if retryCount > 1 {
                    DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
                        self.sendEvent(event, retryCount: retryCount - 1, completion: completion)
                    }
                } else {
                    completion(TelemetrySendStatusWrapper(status: .failure, event: event, error: error))
                }
            }
        }
    }
    
    private func send(
        _ event: TelemetryEvent,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
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
                    let error = NSError(
                        domain: "TelemetrySendError",
                        code: statusCode,
                        userInfo: [NSLocalizedDescriptionKey: "Failed to send event, status code: \(statusCode)"]
                    )
                    completion(.failure(error))
                }
            }
            task.resume()
        } catch {
            completion(.failure(error))
        }
    }
}

@objc(TelemetrySendStatusWrapper)
class TelemetrySendStatusWrapper: NSObject {
    @objc let status: TelemetrySendStatus
    @objc let event: NSDictionary
    @objc let error: NSError?
    
    init(status: TelemetrySendStatus, event: TelemetryEvent, error: Error? = nil) {
        self.status = status
        self.event = event.toNSDictionary()
        self.error = error as NSError?
    }
    
    func toDictionary() -> NSDictionary {
        var dict: [String: Any] = ["status": status.rawValue, "event": event]
        if let error = error {
            dict["error"] = error.localizedDescription
        }
        return dict as NSDictionary
    }
}
