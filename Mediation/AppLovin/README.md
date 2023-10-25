# IOS AppLovin Bridge #

1. **[Overview](#overview)**
2. **[Register on LoopMe network](#register-on-loopme-network)**
3. **[Adding LoopMe IOS SDK](#adding-loopme-ios-sdk)**
4. **[Adding LoopMe's AppLovin Bridge](#adding-loopmes-applovin-bridge)**
5. **[Initialization](#initialization)**
6. **[Mediate from AppLovin ads to LoopMe Ad](#mediate-from-applovin-ads-to-loopme-ad)**
7. **[Interstitial](#interstitial)**
8. **[Banner](#banner)**
9. **[Rewarded Video](#rewarded-video)**
10. **[Sample project](#sample-project)**

## Overview ##

LoopMe is the largest mobile video DSP and Ad Network, reaching over 1 billion consumers world-wide. LoopMe’s
full-screen video and rich media ad formats deliver more engaging mobile advertising experiences to consumers on
smartphones and tablets. LoopMe supports SDK bridges to ad mediation platforms.

If you have questions please contact us at support@loopme.com.

## Register on LoopMe network ##

To use and setup the SDK bridge, register your app on the LoopMe network via the LoopMe Dashboard to retrieve a unique LoopMe app key for your app. The app key uniquely identifies your app in the LoopMe ad network (Example app key: 51bb33e7cb). Please ask POC in Loopme to register your app/placement and provide the appKey.<br>
You will need the app key during next steps of integration.

## Adding LoopMe IOS SDK ##
Use `CocoaPods`
Copy the customized CocoaPods script below to your Podfile:
```java
target 'Applovin-mediation-sample' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  pod 'AppLovinSDK'
  pod 'LoopMeUnitedSDK'

end
```
Make sure the LoopMeUnitedSDK frameworks are added in Xcode project's build phases


## Adding LoopMe's AppLovin Bridge ##
* Copy `LoopMeMediationAdapter` class to your project

## Initialization ##
Make sure `LoopMeSdk` is [initialized](https://github.com/loopme/ios-united-sdk/wiki/Initialization) before using AppLovin.
```java
 LoopMeSDK.shared().initSDK(fromRootViewController: ViewController, completionBlock: { }
```


## Mediate from AppLovin ads to LoopMe Ad ##

<b>Configure Ad Network Mediation on AppLovin</b>
<br><b>NOTE:</b> This page assumes you already have account on AppLovin and Ad unit(s)

* Click <b>Networks</b> in Manage group then <b>Click here to add a Custom Network</b>

<p><img src="images/applovin_manage_networks.png" /></p>

<p><img src="images/applovin_create_custom.png" /></p>

* Choose the iOS platfrom and after the type of advertisement you what to add. 
<img width="1158" alt="Screenshot 2023-10-17 at 14 03 53" src="https://github.com/loopme/ios-united-sdk/assets/145434188/2816dad6-9f26-4cd4-8b3b-144da706e40c">

* Click <b>In Ad Unit's setting set loopme's appkey in PlacementId field</b>
Enter the appkey and real eCPM that you have got after LoopMe publisher team approval. Click Continue.<br>
Note: you find eCPM on the LoopMe Dashboard > Apps & Sites > Ad Spot information.

* You will get:

<p><img src="images/applovin custom event.png"  /></p>

Parameter: enter the app key value you received after registering your Ad Spot on the LoopMe dashboard. <br>E.g. '
298f62c196'.<br><br>

## Interstitial ##

* Load

```java
interstitialAd = MAInterstitialAd(adUnitIdentifier: "AD_UNIT_ID")
interstitialAd.load()
```

* Show
```java
interstitialAd.show();
```

* Example of implementation 
```java
    override func viewDidLoad() {
        super.viewDidLoad()        
      interstitialAd = MAInterstitialAd(adUnitIdentifier: adUnitIdentifier)
      interstitialAd.delegate = self
      interstitialAd.load()
      interstitialAd.show(forPlacement: nil, customData: nil, viewController: self)
    }
```

## Banner ##

* Load
```java
adView = MAAdView(adUnitIdentifier: "AD_UNIT_ID")
adView.loadAd()
```
* Show
```java
view.addSubview(adView)
// You should set the constraints
```

* Example of implementation 
```java
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
        adView.heightAnchor.constraint(equalToConstant: (UIDevice.current.userInterfaceIdiom == .pad) ? iphoneHeight : ipadHeight).isActive = true
        self.adView.loadAd()
    }
```

## Rewarded Video ##

* Load
```java
rewarded = MARewardedInterstitialAd(adUnitIdentifier: "AD_UNIT_ID")
rewarded.load()
```

* Show
```java
rewarded.show(forPlacement: nil, customData: nil, viewController: self)
```
* Example of implementation 
```java
    override func viewDidLoad() {
        super.viewDidLoad()        
      rewarded = MAInterstitialAd(adUnitIdentifier: adUnitIdentifier)
      rewarded.delegate = self
      rewarded.load()
      rewarded.show(forPlacement: nil, customData: nil, viewController: self)
    }
```

## Sample project ##

Check out our `Applovin-mediation-sample` as an integration example.
