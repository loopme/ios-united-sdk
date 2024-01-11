//
//  BannerViewController.swift
//  Applovin-mediation-sample
//
//  Created by ValeriiRoman on 16/10/2023.
//

import UIKit
import AppLovinSDK
import LoopMeUnitedSDK

class BannerViewController: UIViewController, MAAdViewAdDelegate {
    
    private var adView: MAAdView!
    private let iphoneHeight: CGFloat = 50
    private let ipadHeight: CGFloat = 90
    private let adUnitIdentifier = "4000e273b81db3ad"
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
        
    func didExpand(_ ad: MAAd) {}
    
    func didCollapse(_ ad: MAAd) {}
    
    func didLoad(_ ad: MAAd) {}
    
    func didFailToLoadAd(forAdUnitIdentifier adUnitIdentifier: String, withError error: MAError) {}
    
    func didDisplay(_ ad: MAAd) {}
    
    func didHide(_ ad: MAAd) {}
    
    func didClick(_ ad: MAAd) {}
    
    func didFail(toDisplay ad: MAAd, withError error: MAError) {}
}
