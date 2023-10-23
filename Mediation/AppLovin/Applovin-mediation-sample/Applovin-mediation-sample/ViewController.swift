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
            (_, _) in
            DispatchQueue.main.async {
                guard let alSDK  = ALSdk.shared() else {return }
                alSDK.initializeSdk { (configuration: _) in
                    alSDK.settings.isVerboseLoggingEnabled = true
                }
            }
        })
    }
}

