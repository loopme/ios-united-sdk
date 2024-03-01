//
//  InterstitialViewController.swift
//  Applovin-mediation-sample
//
//  Created by ValeriiRoman on 16/10/2023.
//

import UIKit
import LoopMeUnitedSDK
import AppLovinSDK

class InterstitialViewController: UIViewController, MAAdDelegate {
    
    @IBOutlet weak var showButton: UIButton!
    @IBOutlet weak var spinnerView: UIActivityIndicatorView!
    
    private var retryAttempt = 0.0
    private var interstitialAd: MAInterstitialAd!
    private let adUnitIdentifier = "6d5c1f112ec58c8f"

    override func viewDidLoad() {
        super.viewDidLoad()
        self.spinnerView.startAnimating()
        
        self.interstitialAd = MAInterstitialAd(adUnitIdentifier: adUnitIdentifier)
        self.interstitialAd.delegate = self
        self.interstitialAd.load()
    }
    
    @IBAction func ShowInterstitial(_ sender: UIButton) {
        self.interstitialAd.show(forPlacement: nil, customData: nil, viewController: self)
    }
    
    func didLoad(_ ad: MAAd) {
        retryAttempt = 0
        spinnerView.stopAnimating()
        showButton.isEnabled = true
        NSLog("CALLBACK - interstitial didLoad ")
    }
    
    func didFailToLoadAd(forAdUnitIdentifier adUnitIdentifier: String, withError error: MAError) {
        retryAttempt += 1
        let delaySec = pow(2.0, min(6.0, retryAttempt))
        DispatchQueue.main.asyncAfter(deadline: .now() + delaySec) {
            self.interstitialAd.load()
        }
        NSLog("CALLBACK - interstitial didFailToLoadAd", error)
    }
    
    func didDisplay(_ ad: MAAd) {
        NSLog("CALLBACK - interstitial didDisplay")
    }
    
    func didHide(_ ad: MAAd) {
        interstitialAd.load()
        NSLog("CALLBACK - interstitial didHide")
    }
    
    func didClick(_ ad: MAAd) {
        NSLog("CALLBACK - interstitial didClick")
    }
    
    func didFail(toDisplay ad: MAAd, withError error: MAError) {
        interstitialAd.load()
        NSLog("CALLBACK - interstitial didFail", error)
    }
}
