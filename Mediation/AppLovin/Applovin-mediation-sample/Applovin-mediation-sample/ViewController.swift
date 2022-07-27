//
//  ViewController.swift
//  Applovin-mediation-sample
//
//  Created by Volodymyr Novikov on 21.06.2022.
//

import UIKit
import LoopMeUnitedSDK
import AppLovinSDK

class ViewController: UIViewController, MAAdDelegate {
    
    var interstitialAd: MAInterstitialAd!
    
    func didLoad(_ ad: MAAd) {
        self.interstitialAd.show(forPlacement: nil, customData: nil, viewController: self)
    }
    
    func didFailToLoadAd(forAdUnitIdentifier adUnitIdentifier: String, withError error: MAError) {
    }
    
    func didDisplay(_ ad: MAAd) {
    }
    
    func didHide(_ ad: MAAd) {
    }
    
    func didClick(_ ad: MAAd) {
    }
    
    func didFail(toDisplay ad: MAAd, withError error: MAError) {
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        LoopMeSDK.shared().initSDK(fromRootViewController: self, completionBlock: {
            (isInti, error) in
                DispatchQueue.main.async {
                    ALSdk.shared()!.initializeSdk { (configuration: ALSdkConfiguration) in
                        self.interstitialAd = MAInterstitialAd(adUnitIdentifier: "89f27e85ef66d3db")
                        self.interstitialAd.delegate = self
                        self.interstitialAd.load()
                    }
                }
        })
    }
}

