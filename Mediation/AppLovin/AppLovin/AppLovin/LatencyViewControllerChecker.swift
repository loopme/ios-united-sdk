////
////  LatencyViewControllerChecker.swift
////  AppLovinDemoApp
////
////  Created by Valerii Roman on 22/07/2024.
////
//
//import UIKit
//import AppLovinSDK
//import LoopMeUnitedSDK
//
//
//class LatencyViewControllerChecker: UIViewController, MAAdViewAdDelegate, MARewardedAdDelegate, MAAdDelegate  {
//    private var adView: MAAdView!
//    private let adUnitIdentifierAdView = "1ef882e49e5d9430"
//    private var activityIndicator: UIActivityIndicatorView!
//    private var rewarded: MARewardedAd!
//    private let adUnitIdentifierRewarded = "dfd4fcbe11acafdf"
//    
//    private var loadRewardedVideoCount = 0
//    private var loadInterstitialCount = 0
//    private var loadBannerCount = 0
//    private var maxLoadAttempts = 10
//    private var isInterstitial = false
//    private var isBanner = false
//    private var isRewarded = false
//    private var isLoading = false
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        activityIndicator = UIActivityIndicatorView(style: .large)
//        
//        activityIndicator.center = self.view.center
//        activityIndicator.hidesWhenStopped = true
//        self.view.addSubview(activityIndicator)
//        
//        adView = MAAdView(adUnitIdentifier: adUnitIdentifierAdView)
//        adView.delegate = self
//        rewarded = MARewardedAd.shared(withAdUnitIdentifier: adUnitIdentifierRewarded)
//        rewarded.delegate = self
//    }
//    
//    @IBAction func checkRewarded(_ sender: UIButton) {
//        if !isLoading {
//            self.loadRewardedVideo()
//        }
//    }
//    
//    @IBAction func checkInterstitial(_ sender: UIButton) {
//        if !isLoading {
//            self.loadInterstitialVideo()
//        }
//    }
//    
//    @IBAction func checkBanner(_ sender: UIButton) {
//        if !isLoading {
//            self.loadBanner()
//        }
//    }
//    
//    func showActivityIndicator() {
//        DispatchQueue.main.async {
//            self.activityIndicator.startAnimating()
//            self.activityIndicator.isHidden = false
//        }
//    }
//    
//    func hideActivityIndicator() {
//        DispatchQueue.main.async {
//            self.activityIndicator.stopAnimating()
//            self.activityIndicator.isHidden = true
//        }
//    }
//    
//    func loadBanner() {
//        if loadBannerCount == 0 {
//            showActivityIndicator()
//        }
//        
//        if loadBannerCount < maxLoadAttempts {
//            isLoading = true
//            isBanner = true
//            loadBannerCount += 1
//            LegacyManger.shared.logEvent(forCall: loadBannerCount as NSNumber, withText: "Load (App)", adType: "Banner")
//            adView.loadAd()
//        } else {
//            hideActivityIndicator()
//            isLoading = false
//            isBanner = false
//            loadBannerCount = 0
//        }
//    }
//    
//    func loadRewardedVideo() {
//        if loadRewardedVideoCount == 0 {
//            showActivityIndicator()
//        }
//        
//        if loadRewardedVideoCount < maxLoadAttempts {
//            isLoading = true
//            isRewarded = true
//            loadRewardedVideoCount += 1
//            LegacyManger.shared.logEvent(forCall: loadRewardedVideoCount as NSNumber, withText: "Load Rewarded (App)", adType: "Rewarded")
//            rewarded.load()
//        } else {
//            isLoading = false
//            isRewarded = false
//            loadRewardedVideoCount = 0
//            hideActivityIndicator()
//        }
//    }
//    
//    func loadInterstitialVideo () {
//        if loadInterstitialCount == 0 {
//            showActivityIndicator()
//        }
//        
//        if loadInterstitialCount < maxLoadAttempts {
//            isLoading = true
//            isInterstitial = true
//            loadInterstitialCount += 1
//            LegacyManger.shared.logEvent(forCall: loadInterstitialCount as NSNumber, withText: "Load (App)", adType: "Interstitial")
//            adView.loadAd()
//        } else {
//            hideActivityIndicator()
//            isLoading = false
//            isInterstitial = false
//            loadInterstitialCount = 0
//        }
//    }
//    
//    
//    func didExpand(_ ad: MAAd) {
//        
//    }
//    
//    func didCollapse(_ ad: MAAd) {
//        
//    }
//    
//    func didRewardUser(for ad: MAAd, with reward: MAReward) {
//        
//    }
//    
//    func didLoad(_ ad: MAAd) {
//        if isRewarded {
//            LegacyManger.shared.logEvent(forCall: loadRewardedVideoCount as NSNumber, withText: "Did Load (App)", adType: "Rewarded")
//            self.loadRewardedVideo()
//        } else if isBanner  {
//            LegacyManger.shared.logEvent(forCall: loadBannerCount as NSNumber, withText: "Did Load (App)", adType: "Banner")
//            self.loadBanner()
//        } else if isInterstitial {
//            LegacyManger.shared.logEvent(forCall: loadInterstitialCount as NSNumber, withText: "Did Load (App)", adType: "Interstitial")
//            self.loadInterstitialVideo()
//        }
//        
//        
//
//    }
//    
//    func didFailToLoadAd(forAdUnitIdentifier adUnitIdentifier: String, withError error: MAError) {
//        if isRewarded {
//            LegacyManger.shared.logEvent(forCall: loadRewardedVideoCount as NSNumber, withText: "Did Fail (App)", adType: "Rewarded")
//            self.loadRewardedVideo()
//        } else if isBanner  {
//            LegacyManger.shared.logEvent(forCall: loadBannerCount as NSNumber, withText: "Did Fail (App)", adType: "Banner")
//            self.loadBanner()
//        } else if isInterstitial {
//            LegacyManger.shared.logEvent(forCall: loadInterstitialCount as NSNumber, withText: "Did Fail (App)", adType: "Interstitial")
//            self.loadInterstitialVideo()
//        }
//    }
//    
//    
//    func didDisplay(_ ad: MAAd) {
//        
//    }
//    
//    func didHide(_ ad: MAAd) {
//        
//    }
//    
//    func didClick(_ ad: MAAd) {
//        
//    }
//    
//    func didFail(toDisplay ad: MAAd, withError error: MAError) {
//        
//    }
//    
//    
//}
