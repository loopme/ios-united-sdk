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
    
    private let adView = MAAdView(adUnitIdentifier: "d52c8c8e298f2206")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        adView.heightAnchor.constraint(equalToConstant: (UIDevice.current.userInterfaceIdiom == .pad) ? 90 : 50).isActive = true // Banner height on iPhone and iPad is 50 and 90, respectively
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
