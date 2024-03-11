//
//  RewardedVideo.swift
//  Applovin-mediation-sample
//
//  Created by ValeriiRoman on 16/10/2023.
//

import UIKit
import LoopMeUnitedSDK
import AppLovinSDK

class RewardedVideoViewController: UIViewController, MARewardedAdDelegate {
    
    @IBOutlet weak var showButton: UIButton!
    @IBOutlet weak var spinnerView: UIActivityIndicatorView!
    
    private var retryAttempt = 0.0
    private var rewarded: MARewardedInterstitialAd!
    private let adUnitIdentifier = "ce844853dc5db1af"

    override func viewDidLoad() {
        super.viewDidLoad()
        rewarded = MARewardedInterstitialAd(adUnitIdentifier: adUnitIdentifier)
        self.spinnerView.startAnimating()
        
        self.rewarded.delegate = self
        self.rewarded.load()
    }
    
    @IBAction func ShowInterstitial(_ sender: UIButton) {
        DispatchQueue.main.async {
            self.rewarded.show(forPlacement: nil, customData: nil, viewController: self)
        }
    }
    
    func didLoad(_ ad: MAAd) {
        retryAttempt = 0
        spinnerView.stopAnimating()
        showButton.isEnabled =  self.rewarded.isReady
        NSLog("CALLBACK - rewarded didLoad")
    }
    
    func didFailToLoadAd(forAdUnitIdentifier adUnitIdentifier: String, withError error: MAError) {
        retryAttempt += 1
        let delaySec = pow(2.0, min(6.0, retryAttempt))
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delaySec) {
            self.rewarded.load()
        }
        NSLog("CALLBACK - rewarded didFailToLoadAd", error)
    }
    
    func didDisplay(_ ad: MAAd) {
        NSLog("CALLBACK - rewarded didDisplay")
    }
    
    func didHide(_ ad: MAAd) {
        rewarded.load()
        showButton.isEnabled = self.rewarded.isReady
        spinnerView.startAnimating()
        NSLog("CALLBACK - rewarded didHide")
    }
    
    func didClick(_ ad: MAAd) {
        NSLog("CALLBACK - rewarded didClick")
    }
    
    func didFail(toDisplay ad: MAAd, withError error: MAError) {
        rewarded.load()
        NSLog("CALLBACK - rewarded didFail", error)
    }
    
    func didRewardUser(for ad: MAAd, with reward: MAReward) {
        NSLog("CALLBACK - rewarded didRewardUser", reward)
    }
}
