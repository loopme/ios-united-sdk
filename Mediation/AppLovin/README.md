# IOS AppLovin Bridge #

1. **[Overview](#overview)**
2. **[Register on LoopMe network](#register-on-loopme-network)**
3. **[Adding LoopMe IOS SDK](#adding-loopme-ios-sdk)**
4. **[Adding LoopMe's AppLovin Bridge](#adding-loopmes-applovin-bridge)**
5. **[Initialization](#Initialization)**
6. **[Mediate from AppLovin Interstitial to LoopMe Interstitial Ad](#mediate-from-applovin-interstitial-to-loopme-interstitial-ad)**
7. **[Sample project](#sample-project)**

## Overview ##

LoopMe is the largest mobile video DSP and Ad Network, reaching over 1 billion consumers world-wide. LoopMe’s
full-screen video and rich media ad formats deliver more engaging mobile advertising experiences to consumers on
smartphones and tablets. LoopMe supports SDK bridges to ad mediation platforms.

If you have questions please contact us at support@loopme.com.

## Register on LoopMe network ##

To use and setup the SDK bridge, register your app on the LoopMe network via the LoopMe Dashboard to retrieve a unique LoopMe app key for your app. The app key uniquely identifies your app in the LoopMe ad network (Example app key: 51bb33e7cb). Please ask POC in Loopme to register your app/placement and provide the appKey.<br>
You will need the app key during next steps of integration.

## Adding LoopMe IOS SDK ##
use `pod 'LoopMeUnitedSDK'` or 
* Download `LoopMeSDK` from this repository
* Copy `LoopMeUnitedSDK.embeddedframework` to your project (alternatively you can use LoopMeSDK sorce code)
* Make sure the following frameworks are added in `Xcode` project's `build phases`
  * `MessageUI.framework`
  * `StoreKit.framework`
  * `AVFoundation.framework`
  * `CoreMedia.framework`
  * `AudioToolbox.framework`
  * `AdSupport.framework`
  * `CoreTelephony.framework`
  * `SystemConfiguration.framework` 


## Adding LoopMe's AppLovin Bridge ##
* Copy `LoopMeMediationAdapter` class to your project

## Initialization ##
Make sure `LoopMeSdk` is [initialized](https://github.com/loopme/ios-united-sdk/wiki/Initialization) before using AppLovin.

## Mediate from AppLovin Interstitial to LoopMe Interstitial Ad ##

<b>Configure Ad Network Mediation on AppLovin</b>
<br><b>NOTE:</b> This page assumes you already have account on AppLovin and Ad unit(s)

* Click <b>Networks</b> in Manage group then <b>Click here to add a Custom Network</b>

<p><img src="images/applovin_manage_networks.png" /></p>

<p><img src="images/applovin_create_custom.png" /></p>

* Click <b>In Ad Unit's setting set loopme's appkey in PlacementId field</b>
Enter the appkey and real eCPM that you have got after LoopMe publisher team approval. Click Continue.<br>
Note: you find eCPM on the LoopMe Dashboard > Apps & Sites > Ad Spot information.

* You will get:

<p><img src="images/applovin custom event.png"  /></p>

Parameter: enter the app key value you received after registering your Ad Spot on the LoopMe dashboard. <br>E.g. '
298f62c196'.<br><br>

* Load

```java
interstitialAd = MAInterstitialAd(adUnitIdentifier: "AD_UNIT_ID")
```

* Show

```java
interstitialAd.show();
```

## Sample project ##

Check out our `unity_sample_project` as an integration example.
