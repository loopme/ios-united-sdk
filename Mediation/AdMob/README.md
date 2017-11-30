# LoopMe AdMob Bridge #

The `LoopMe` bridge allows you to mediate between `AdMob` interstitial ads and `LoopMe`.
<br/><b>NOTE</b>: This page assumes you have accounts on `AdMob` and `LoopMe` dashboards and already integrated with the `AdMob` SDK.

The bridge is compatible with `LoopMe` SDK v5.1.2 and higher, tested with `AdMob` SDK v7.10.1.

### Create and configure custom event on AdMob dashboard ###

<b>NOTE:</b> `LoopMe` is not available as a predefine network in the AdMob tool, SDK bridge needs to be manually configured with AdMob "Custom Event" option.

* Sign in to your AdMob account at [https://apps.admob.com](https://apps.admob.com)
* Click the __Monetize__ tab
* Under __All apps__ on the left-hand side, select the app you want to update
* Click the link in the __Mediation__ column to the right of the ad unit you want to modify

![](https://lh3.googleusercontent.com/FO7qJGdu9mrhaPmhU2LhV08wW2J57D3wzIbDTsS4yQEqQV1DOAZY3L5sHWOKYrM=w762)

* Click __+ New ad network__
* Click __+ Custom event__
* Provide the following details:
    * __Class Name__: GADLoopMeInterstitialAdapter
    * __Label__: LoopMe
    * __Parameter__: LOOPME_APP_KEY
* Click __Continue__
* Copy __GADLoopMeInterstitialAdapter.h__ and __GADLoopMeInterstitialAdapter.m__ to Your project
* Allocate traffic by entering an eCPM value for the custom event. Your allocation options are the same as they are for ad networks
* Click __Save__

### Adding LoopMe SDK to your project ###

* Download `LoopMeSDK` from this repository
* Copy `LoopMeSDK` folder to your project (alternatively you can use LoopMeSDK as a subproject or build static library)
* Copy `LoopMeMediation` folder to your project
* Make sure the following frameworks are added in `Xcode` project's `build phases`
  * `MessageUI.framework`
  * `StoreKit.framework`
  * `AVFoundation.framework`
  * `CoreMedia.framework`
  * `AudioToolbox.framework`
  * `AdSupport.framework`
  * `CoreTelephony.framework`
  * `SystemConfiguration.framework` 
  
### Usage ###

AdMob SDK will automatically find LoopMe Bridge and will use it to ad showing.

### Sample project ###

Check out our `AdMobAdapterDemo` project as an integration sample.
