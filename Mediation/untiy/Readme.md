# Android Unity-plugin

1. **[Overview](#overview)**
2. **[Register on LoopMe network](#register-on-loopme-network)**
3. **[Manual adding LoopMe IOs SDK](#manual-adding-loopme-ios-sdk)**
4. **[Initialization](#Initialization)**
5. **[Interstitial Ad](#mediate-from-applovin-interstitial-to-loopme-interstitial-ad)**

## Overview ##

LoopMe is the largest mobile video DSP and Ad Network, reaching over 1 billion consumers world-wide. LoopMe’s
full-screen video and rich media ad formats deliver more engaging mobile advertising experiences to consumers on
smartphones and tablets. LoopMe supports SDK bridges to ad mediation platforms.

If you have questions please contact us at support@loopme.com.

## Register on LoopMe network ##

To use and setup the SDK bridge, register your app on the LoopMe network via the LoopMe Dashboard to retrieve a unique LoopMe app key for your app. The app key uniquely identifies your app in the LoopMe ad network (Example app key: 51bb33e7cb). Please ask POC in Loopme to register your app/placement and provide the appKey.<br>
You will need the app key during next steps of integration.

## Manual adding LoopMe IOs SDK ##
Add LoopMeSDK to your unity project and
Download and add [unitybridge.unitypackage](https://github.com/loopme/ios-united-sdk/raw/master/Mediation/unity/unitybridge.unitypackage) to your unity project

## Initialization ##

To initialize LoopmeSDK you need implement LoopMeSDKListener:
```java
    class InitListener:LoopMeSDKListener{
        public void onSdkInitializationSuccess(){
            Debug.Log("init success!");
        }
        public void onSdkInitializationFail(int error, string message){
            Debug.Log(message);
        }
    }
```
And invoke ```LoopMeSDK.Initialize(new InitListener());```

## Interstitial Ad ##

To  you need implement LoopMeInterstitialListener:
```java
    class InterstitialListener:LoopMeInterstitialListener{
        public void onLoopMeInterstitialLoadSuccess(LoopMeInterstitial interstitial){
            interstitial.Show();
        }
        public void onLoopMeInterstitialLoadFail(LoopMeInterstitial interstitial, LoopMeError error){
            Debug.Log(error.getMessage());
        }
        public void onLoopMeInterstitialShow(LoopMeInterstitial interstitial){}
        public void onLoopMeInterstitialHide(LoopMeInterstitial interstitial){}
        public void onLoopMeInterstitialClicked(LoopMeInterstitial interstitial){}
        public void onLoopMeInterstitialLeaveApp(LoopMeInterstitial interstitial){}
        public void onLoopMeInterstitialExpired(LoopMeInterstitial interstitial){}
        public void onLoopMeInterstitialVideoDidReachEnd(LoopMeInterstitial interstitial){}
    }
```

* Load

```java
interstitialAd = new InterstitialAd(appkey, new InterstitialListener());
```

* Show

```java
interstitialAd.Show();
```

