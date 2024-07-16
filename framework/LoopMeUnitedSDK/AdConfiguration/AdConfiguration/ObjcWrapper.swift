
import Foundation

@objc (LoopMeAdOrientation)
public enum AdOrientationWrapper: Int {
    case undefined
    case portrait
    case landscape
}

@objc (LoopMeCreativeType)
public enum CreativeTypeWrapper: Int {
    case vpaid
    case vast
    case normal
    case mraid
}

@objc (LoopMeAdConfiguration)
public class AdConfigurationWrapper: NSObject {
    private var adConfiguration: AdConfiguration
    
    public init(adConfiguration: AdConfiguration) {
        self.adConfiguration = adConfiguration
        self.skadNetworkInfo = adConfiguration.skAdNetworkInfo
        if let vastProperties = adConfiguration.vastProperties {
            self.vastProperties = VastPropertiesWrapper(with: vastProperties)
        }
        super.init()
    }
    
    @objc public var appKey: String {
        get {
            return self.adConfiguration.appKey
        }
        set {
            self.adConfiguration.appKey = newValue
        }
    }
    
    @objc public var isRewarded: Bool  {
        get {
            return self.adConfiguration.isRewarded
        } 
        set {
            self.adConfiguration.isRewarded = newValue
        }
    }
    
    @objc public var placement: String = "unknown"
    
    @objc public var adId: String {
        return self.adConfiguration.id
    }
    
    @objc public var debug: Bool {
        return self.adConfiguration.debug
    }
    
    @objc public var preload25: Bool {
        return self.adConfiguration.preload25
    }
    
    var _adOrientation: AdOrientationWrapper = .undefined
    @objc public var adOrientation: AdOrientationWrapper {
        get {
            if let orientation = adConfiguration.vastProperties?.orientation, orientation != .undefined {
                return orientation
            } else {
                return adConfiguration.adOrientation == .portrait ? .portrait : .landscape
            }
        }
        set {
            _adOrientation = newValue
        }
    }
    
    @objc public var creativeType: CreativeTypeWrapper {
        switch self.adConfiguration.creativeType {
        case .mraid:
            return .mraid
        case .vast:
            return .vast
        case .vpaid:
            return .vpaid
        case .loopme:
            return .normal
        }
    }
    
    @objc public var creativeContent: String {
        get {
            return self.adConfiguration.creativeContent
        }
        set {
            adConfiguration.creativeContent = newValue
        }
    }
    
    @objc public var isPortrait: Bool {
        return adOrientation == .portrait
    }
    
    @objc public var skadSignature: String? {
        if skadNetworkInfo?.fidelities.count == 2 {
            return skadNetworkInfo?.fidelities.first?.signature
        } else {
            return skadNetworkInfo?.fidelities.last?.signature
        }
    }
    
    @objc public var skadNonce: String? {
        if skadNetworkInfo?.fidelities.count == 2 {
            return skadNetworkInfo?.fidelities.first?.nonce
        } else {
            return skadNetworkInfo?.fidelities.last?.nonce
        }
    }
    
    @objc public var skadNetwork: String? {
        return skadNetworkInfo?.network
    }
    
    @objc public var skadVersion: String? {
        return skadNetworkInfo?.version
    }
    
    @objc public var skadTimestamp: NSNumber? {
        if skadNetworkInfo?.fidelities.count == 2 {
            return skadNetworkInfo?.fidelities.first?.timestamp.numberValue
        } else {
            return skadNetworkInfo?.fidelities.last?.timestamp.numberValue
        }
    }
    
    @objc public var skadSourceApp: NSNumber? {
        return skadNetworkInfo?.sourceapp.numberValue
    }
    
    @objc public var skadItunesitem: NSNumber? {
        return skadNetworkInfo?.itunesitem.numberValue
    }
    
    @objc public var skadCampaign: NSNumber? {
        return skadNetworkInfo?.campaign.numberValue
    }
    
    @objc public var skadSourceidentifier: NSNumber? {
        return skadNetworkInfo?.sourceidentifier.numberValue
    }
    
    @objc public var expandProperties: MRAIDExpandPropertiesWrapper?
    @objc public var vastProperties: VastPropertiesWrapper?
    public var skadNetworkInfo: SKAdNetworkInfo?
    @objc public var allowOrientationChange: Bool = false
    
    @objc public func toDictionary() -> NSMutableDictionary{
        let dictionary: NSMutableDictionary = [:]
        dictionary["app_key"] = self.adConfiguration.appKey
        dictionary["cid"] = self.adConfiguration.cid
        dictionary["crid"] = self.adConfiguration.crid
        dictionary["request_id"] = self.adConfiguration.requestId
        dictionary["placement"] = self.placement
        return dictionary
     }
}

@objc (LoopMeVASTEventTracker)
public class VastEventTrackerWrapper: NSObject {
    
    var tracker: VastEventTracker
    
    @objc public init(trackingLinks: AdTrackingLinksWrapper) {
        self.tracker = VastEventTracker(trackingLinks: trackingLinks.trackingLinks)
        super.init()
    }
    
    @objc public func trackEvent(_ event: VASTEventType) {
        tracker.track(event: event)
    }

    @objc public func trackErrorCode(_ code: Int) { 
        tracker.track(error: code)
    }
    
    @objc public func trackAdVerificationNonExecuted() {
        tracker.trackAdVerificationNonExecuted()
    }
    
    @objc public func setCurrentTime(_ currentTime: TimeInterval) {
        tracker.setCurrentTime(currentTime: currentTime)
    }
}

@objc (LoopMeProgressEvent)
public class ProgressEventWrappper: NSObject {
    let progressEvent: ProgressEvent
    
    init(progressEvent: ProgressEvent) {
        self.progressEvent = progressEvent
    }
}

@objc (LoopMeVastProperties)
public class VastPropertiesWrapper: NSObject {
    
    private var vastProperties: VastProperties
    private var skipOffsetWrapper: VastSkipOffsetWrapper
    private var trackingLinksWrapper: AdTrackingLinksWrapper
    private var assetLinksWrapper: AssetLinksWrapper
    private var adVerificationWrappers: [AdVerificationWrapper]
    
    @objc public var adId: String? {
        return vastProperties.adId
    }
    
    @objc public var duration: TimeInterval {
        return vastProperties.duration
    }
    
    @objc public var skipOffset: VastSkipOffsetWrapper {
        return skipOffsetWrapper
    }
    
    @objc public var trackingLinks: AdTrackingLinksWrapper {
        return trackingLinksWrapper
    }
    
    @objc public var assetLinks: AssetLinksWrapper {
        return assetLinksWrapper
    }
    
    @objc public var adVerifications: [AdVerificationWrapper] {
        return adVerificationWrappers
    }
    
    @objc public var isVpaid: Bool {
        return !vastProperties.assetLinks.vpaidURL.isEmpty
    }
    
    init(with vastProperties: VastProperties) {
        self.vastProperties = vastProperties
        self.trackingLinksWrapper = AdTrackingLinksWrapper(trackingLinks: vastProperties.trackingLinks)
        self.assetLinksWrapper = AssetLinksWrapper(assetLinks: vastProperties.assetLinks)
        self.skipOffsetWrapper = VastSkipOffsetWrapper(skipOffset: vastProperties.skipOffset)
        
        var adVerificationWrappers: [AdVerificationWrapper] = []
        for adVerification in vastProperties.adVerifications {
            let wrapper = AdVerificationWrapper(adVerification: adVerification)
            adVerificationWrappers.append(wrapper)
        }
        self.adVerificationWrappers = adVerificationWrappers
    }
}

@objc (LoopMeAdTrackingLinks)
public class AdTrackingLinksWrapper: NSObject {
    var trackingLinks: AdTrackingLinks
    var viwableImpressionWrapper: ViewableImpressionWrapper
    var linearWrapper: LinearTrackingWrapper
    
    init(trackingLinks: AdTrackingLinks) {
        self.trackingLinks = trackingLinks
        self.viwableImpressionWrapper = ViewableImpressionWrapper(viewableImpression: trackingLinks.viewableImpression)
        self.linearWrapper = LinearTrackingWrapper(linearTracking: trackingLinks.linear)
    }
    
    @objc public var errorTemplates: Set<String> {
        return trackingLinks.errorTemplates
    }
    
    @objc public var impression: Set<String> {
        return trackingLinks.impression
    }
    
    @objc public var clickVideo: String {
        return trackingLinks.clickVideo
    }
    
    @objc public var clickCompanion: String {
        return trackingLinks.clickCompanion
    }
    
    @objc public var viewableImpression: ViewableImpressionWrapper {
        return viwableImpressionWrapper
    }
    
    @objc public var linear: LinearTrackingWrapper {
        return linearWrapper
    }
}

@objc (LoopMeVastSkipOffset)
public class VastSkipOffsetWrapper: NSObject {
    let skipOffset: VastSkipOffset
    
    init(skipOffset: VastSkipOffset) {
        self.skipOffset = skipOffset
    }
    
    @objc public static func initWith30Second() -> VastSkipOffsetWrapper {
        return VastSkipOffsetWrapper(skipOffset: .seconds30)
    }
    
    @objc public static func initWith5Second() -> VastSkipOffsetWrapper {
        return VastSkipOffsetWrapper(skipOffset: .seconds5)
    }
    
    @objc public var value: Double {
        return skipOffset.value
    }
    
    @objc public var type: TimeOffsetType {
        return skipOffset.type
    }
    
    
}

@objc (LoopMeAssetLinks)
public class AssetLinksWrapper: NSObject {
    let assetLinks: AssetLinks
    
    init(assetLinks: AssetLinks) {
        self.assetLinks = assetLinks
    }
    
    @objc public var videoURL: [String]  {
        return assetLinks.videoURL
    }
    
    @objc public var vpaidURL: String {
        return assetLinks.vpaidURL
    }
    
    @objc public var adParameters: String {
        return assetLinks.adParameters
    }
    
    @objc public var endCard: Array<String> {
        return Array(assetLinks.endCard)
    }
}

@objc (LoopMeAdVerification)
public class AdVerificationWrapper: NSObject {
    var adVerification: AdVerification
    
    init(adVerification: AdVerification) {
        self.adVerification = adVerification
    }
    
    @objc public var vendor: String {
        return self.adVerification.vendor
    }
    
    @objc public var jsResource: String {
        return self.adVerification.jsResource
    }
    
    @objc public var verificationParameters: String {
        return self.adVerification.verificationParameters
    }
}

@objc (LoopMeViewableImpression)
public class ViewableImpressionWrapper: NSObject {
    
    private let viewableImpression: ViewableImpression
    
    init(viewableImpression: ViewableImpression) {
        self.viewableImpression = viewableImpression
    }
    
    public var viewable: Set<String> {
        return viewableImpression.viewable
    }
    
    public var notViewable: Set<String> {
        return viewableImpression.notViewable
    }
    
    public var viewUndetermined: Set<String> {
        return viewableImpression.viewUndetermined
    }
}


@objc (LoopMeLinearTracking)
public class LinearTrackingWrapper: NSObject {
    
    private let linearTracking: LinearTracking
    
    init(linearTracking: LinearTracking) {
        self.linearTracking = linearTracking
    }
    
    public var start: Set<String> {
        return self.linearTracking.start
    }
    
    public var firstQuartile: Set<String> {
        return self.linearTracking.firstQuartile
    }
    
    public var midpoint: Set<String> {
        return self.linearTracking.midpoint
    }
    
    public var thirdQuartile: Set<String> {
        return self.linearTracking.thirdQuartile
    }
    
    public var complete: Set<String> {
        return self.linearTracking.complete
    }
    
    public var mute: Set<String> {
        return self.linearTracking.mute
    }
    
    public var unmute: Set<String> {
        return self.linearTracking.unmute
    }
    
    public var pause: Set<String> {
        return self.linearTracking.pause
    }
    
    public var resume: Set<String> {
        return self.linearTracking.resume
    }
    
    public var fullscreen: Set<String> {
        return self.linearTracking.fullscreen
    }
    
    public var exitFullscreen: Set<String> {
        return self.linearTracking.exitFullscreen
    }
    
    public var skip: Set<String> {
        return self.linearTracking.skip
    }
    
    public var close: Set<String> {
        return self.linearTracking.close
    }
    
    public var progress: Set<ProgressEvent> {
        return self.linearTracking.progress
    }
    
}

@objc (LoopMeProgressEventTracker)
public class ProgressEventTrackerWrapper: NSObject {
    
    private let progressEventTracker: ProgressEvent
    
    init(progressEventTracker: ProgressEvent) {
        self.progressEventTracker = progressEventTracker
    }
    
    public var link: String {
        return progressEventTracker.link
    }
    
    public var offset: TimeInterval {
        return progressEventTracker.offset
    }
}

@objc (LoopMeMRAIDExpandProperties)
public class MRAIDExpandPropertiesWrapper: NSObject {
    
    var expandProperties: MRAIDExpandProperties
    
    @objc override public init() {
        self.expandProperties = .empty
        super.init()
    }
    
//    init(expandProperties: MRAIDExpandProperties = .empty) {
//        self.expandProperties = expandProperties
//        super.init()
//    }
    
    @objc public var width: Float {
        get {
            return expandProperties.width
        }
        set {
            expandProperties.width = newValue
        }
    }
    
    @objc public var height: Float {
        get {
            return expandProperties.height
        }
        set {
            expandProperties.height = newValue
        }
    }
    
    @objc public var useCustomClose: Bool {
        get {
            return expandProperties.useCustomClose
        }
        set {
            expandProperties.useCustomClose = newValue
        }
    }
}

