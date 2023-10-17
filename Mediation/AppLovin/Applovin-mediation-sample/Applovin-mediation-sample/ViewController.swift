//
//  ViewController.swift
//  Applovin-mediation-sample
//
//  Created by Volodymyr Novikov on 21.06.2022.
//

import UIKit
import LoopMeUnitedSDK
import AppLovinSDK

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        LoopMeSDK.shared().initSDK(fromRootViewController: self, completionBlock: {
            (isInti, error) in
            DispatchQueue.main.async {
                ALSdk.shared()!.initializeSdk { (configuration: ALSdkConfiguration) in
                    ALSdk.shared()!.settings.isVerboseLoggingEnabled = true

                }
            }
        })
    }
}

