import Foundation
import UIKit

@objcMembers
@objc(LoopMeLifecycleManager)
public class LifecycleManager: NSObject {
    
    // MARK: - Singleton Instance
    @objc public static let shared = LifecycleManager()
    
    // MARK: - Properties
    public var sessionId: String?
    private var sessionDepth: [String: Int]
    private var sessionStartTime: Date?
    private var totalPausedTime: TimeInterval = 0
    private var isPaused: Bool = false
    private var hasLaunchedOnce: Bool = false
    private var didEnterBackground: Bool = false
    
    // MARK: - Initializer
    private override init() {
        self.sessionDepth = [:]
        super.init()
        self.startObserving()
    }
    
    deinit {
        self.stopObserving()
    }
    
    // MARK: - Observing Lifecycle Notifications
    private func startObserving() {
        let center = NotificationCenter.default
        
        center.addObserver(self, selector: #selector(handleDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        center.addObserver(self, selector: #selector(handleWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        center.addObserver(self, selector: #selector(handleDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        center.addObserver(self, selector: #selector(handleWillResignActive), name: UIApplication.willResignActiveNotification, object: nil)
    }
    
    private func stopObserving() {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Notification Handlers
    
    @objc private func handleDidEnterBackground() {
        cleanAllData()
        didEnterBackground = true
    }
    
    @objc private func handleWillEnterForeground() {
        resumeTime()
    }
    
    @objc private func handleDidBecomeActive() {
        if didEnterBackground {
            startSession()
        }
    }
    
    @objc private func handleWillResignActive() {
        pauseTime()
    }
    
    // MARK: - Session Management
    
    @objc public func startSession() {
        sessionDepth.removeAll()
        sessionId = UUID().uuidString
        sessionStartTime = Date()
        totalPausedTime = 0
        isPaused = false
    }
    
    // MARK: - Session Depth Management
    
    @objc public func updateSessionDepth(forKey appKey: String) {
        if let count = sessionDepth[appKey] {
            sessionDepth[appKey] = count + 1
        } else {
            sessionDepth[appKey] = 1
        }
    }
    
    @objc public func sessionDepth(forAppKey appKey: String) -> Int {
        return sessionDepth[appKey] ?? 0
    }
    
    // MARK: - Time Elapsed Since Session Start
    
    @objc public func timeElapsedSinceStart() -> NSNumber {
        guard let sessionStartTime = sessionStartTime else { return NSNumber(value: 0.0) }
        let currentTime = Date()
        var elapsedTime = currentTime.timeIntervalSince(sessionStartTime) - totalPausedTime
        if isPaused {
            elapsedTime = lastElapsedTime
        }
        return NSNumber(value: elapsedTime)
    }
    
    // MARK: - Pausing and Resuming Time
    
    private var lastElapsedTime: TimeInterval = 0
    
    @objc private func pauseTime() {
        guard !isPaused, let startTime = sessionStartTime else { return }
        let currentTime = Date()
        let elapsedTime = currentTime.timeIntervalSince(startTime) - totalPausedTime
        lastElapsedTime = elapsedTime
        isPaused = true
    }
    
    @objc private func resumeTime() {
        guard isPaused else { return }
        let currentTime = Date()
        sessionStartTime = currentTime.addingTimeInterval(-lastElapsedTime)
        isPaused = false
    }
    
    // MARK: - Cleaning All Data
    
    private func cleanAllData() {
        sessionId = nil
        sessionDepth.removeAll()
        sessionStartTime = nil
        totalPausedTime = 0
        isPaused = false
    }
}
