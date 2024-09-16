//
//  BannerViewController.swift
//  Applovin-mediation-sample
//
//  Created by ValeriiRoman on 16/10/2023.
//

import UIKit
import AppLovinSDK

class BannerViewController: UIViewController, MAAdViewAdDelegate {
    
    private var adView: MAAdView!
    private let iphoneHeight: CGFloat = 50
    private let ipadHeight: CGFloat = 90
    private let adUnitIdentifier = "1ef882e49e5d9430"
    override func viewDidLoad() {
        super.viewDidLoad()
         adView = MAAdView(adUnitIdentifier: adUnitIdentifier)
        self.adView.delegate = self
                
        // Set background or background color for banners to be fully functional
        adView.backgroundColor = .black
        adView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(adView)
        
        // Anchor the banner to the left, right, and top of the screen.
        adView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true;
        adView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true;
        adView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true;
        
        adView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true;
        adView.heightAnchor.constraint(equalToConstant: (UIDevice.current.userInterfaceIdiom == .pad) ? ipadHeight : iphoneHeight).isActive = true
        // Load the first ad
        self.adView.loadAd()
    }
        
    func didExpand(_ ad: MAAd) {
        NSLog("CALLBACK - banner didExpand")
    }
    
    func didCollapse(_ ad: MAAd) {
        NSLog("CALLBACK - banner didCollapse")
    }
    
    func didLoad(_ ad: MAAd) {
        NSLog("CALLBACK - banner didLoad")
    }
    
    func didFailToLoadAd(forAdUnitIdentifier adUnitIdentifier: String, withError error: MAError) {
        NSLog("CALLBACK - banner didFailToLoadAd", error)
    }
    
    /* DO NOT USE - THIS IS RESERVED FOR FULLSCREEN ADS ONLY AND WILL BE REMOVED IN A FUTURE SDK RELEASE */
    func didDisplay(_ ad: MAAd) {
        NSLog("CALLBACK - banner didDisplay")
    }
    
    /* DO NOT USE - THIS IS RESERVED FOR FULLSCREEN ADS ONLY AND WILL BE REMOVED IN A FUTURE SDK RELEASE */
    func didHide(_ ad: MAAd) {
        NSLog("CALLBACK - banner didHide")
    }
    
    func didClick(_ ad: MAAd) {
        NSLog("CALLBACK - banner didClick")
    }
    
    func didFail(toDisplay ad: MAAd, withError error: MAError) {
        NSLog("CALLBACK - banner didFail", error)
    }
}
