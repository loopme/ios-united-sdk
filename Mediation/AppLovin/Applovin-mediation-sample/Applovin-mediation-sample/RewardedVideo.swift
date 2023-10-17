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
    private var rewarded = MARewardedInterstitialAd(adUnitIdentifier: "28bd2f0f755d20da")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.spinnerView.startAnimating()
        
        self.rewarded.delegate = self
        self.rewarded.load()
    }
    
    @IBAction func ShowInterstitial(_ sender: UIButton) {
        self.rewarded.show(forPlacement: nil, customData: nil, viewController: self)
    }
    
    func didLoad(_ ad: MAAd) {
        retryAttempt = 0
        spinnerView.stopAnimating()
        showButton.isEnabled = true
    }
    
    func didFailToLoadAd(forAdUnitIdentifier adUnitIdentifier: String, withError error: MAError) {
        retryAttempt += 1
        let delaySec = pow(2.0, min(6.0, retryAttempt))
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delaySec) {
            self.rewarded.load()
        }
    }
    
    func didDisplay(_ ad: MAAd) {}
    
    func didHide(_ ad: MAAd) {
        rewarded.load()
    }
    
    func didClick(_ ad: MAAd) {}
    
    func didFail(toDisplay ad: MAAd, withError error: MAError) {
        rewarded.load()
    }
    
    func didRewardUser(for ad: MAAd, with reward: MAReward) {}
}
