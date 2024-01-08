using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using System;

public class AdsManager : MonoBehaviour
{

    public static string uniqueUserId = "demoapp";
    public Text text;

    // Start is called before the first frame update
    void Start()
    {
        Debug.Log("start method called");

        IronSource.Agent.init("1c524597d");
        
        //Add AdInfo Interstitial Events
        IronSourceInterstitialEvents.onAdReadyEvent += InterstitialOnAdReadyEvent;
        IronSourceInterstitialEvents.onAdLoadFailedEvent += InterstitialOnAdLoadFailed;
        IronSourceInterstitialEvents.onAdOpenedEvent += InterstitialOnAdOpenedEvent;
        IronSourceInterstitialEvents.onAdClickedEvent += InterstitialOnAdClickedEvent;
        IronSourceInterstitialEvents.onAdShowSucceededEvent += InterstitialOnAdShowSucceededEvent;
        IronSourceInterstitialEvents.onAdShowFailedEvent += InterstitialOnAdShowFailedEvent;
        IronSourceInterstitialEvents.onAdClosedEvent += InterstitialOnAdClosedEvent;

        //Add AdInfo Rewarded Video Events
        IronSourceRewardedVideoEvents.onAdOpenedEvent += RewardedVideoOnAdOpenedEvent;
        IronSourceRewardedVideoEvents.onAdClosedEvent += RewardedVideoOnAdClosedEvent;
        IronSourceRewardedVideoEvents.onAdAvailableEvent += RewardedVideoOnAdAvailable;
        IronSourceRewardedVideoEvents.onAdUnavailableEvent += RewardedVideoOnAdUnavailable;
        IronSourceRewardedVideoEvents.onAdShowFailedEvent += RewardedVideoOnAdShowFailedEvent;
        IronSourceRewardedVideoEvents.onAdRewardedEvent += RewardedVideoOnAdRewardedEvent;
        IronSourceRewardedVideoEvents.onAdClickedEvent += RewardedVideoOnAdClickedEvent;

        //Add AdInfo Banner Events
        IronSourceBannerEvents.onAdLoadedEvent += BannerOnAdLoadedEvent;
        IronSourceBannerEvents.onAdLoadFailedEvent += BannerOnAdLoadFailedEvent;
        IronSourceBannerEvents.onAdClickedEvent += BannerOnAdClickedEvent;
        IronSourceBannerEvents.onAdScreenPresentedEvent += BannerOnAdScreenPresentedEvent;
        IronSourceBannerEvents.onAdScreenDismissedEvent += BannerOnAdScreenDismissedEvent;
        IronSourceBannerEvents.onAdLeftApplicationEvent += BannerOnAdLeftApplicationEvent;
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    void OnApplicationPause(bool isPaused) {                 
        IronSource.Agent.onApplicationPause(isPaused);
    }

    void addTextToLog(string message){
        DateTime currentDateTime = DateTime.UtcNow;
        text.text = currentDateTime + ": " + message + "\n" + text.text;
    }

    public void LoadInterstitial(){
        Debug.Log ("LoadInterstitialButtonClicked");
        IronSource.Agent.loadInterstitial();
        addTextToLog("Load Interstitial Button Clicked");
        
    }

    public void ShowInterstitial(){
        Debug.Log ("ShowInterstitialButtonClicked");

		if (IronSource.Agent.isInterstitialReady ()) {
			IronSource.Agent.showInterstitial ();
            addTextToLog("interstitial ads shown");
		} else {
			Debug.Log ("IronSource.Agent.isInterstitialReady - False");
            addTextToLog("isInterstitialReady - False");
		}
    }

    public void ShowRewarded(){
        Debug.Log ("ShowRewardedButtonClicked");

        bool available = IronSource.Agent.isRewardedVideoAvailable();

		if (available) {
			IronSource.Agent.showRewardedVideo();
            addTextToLog("rewarded shown");
		} else {
			Debug.Log ("No rewarded ads available at the moment");
            addTextToLog("no rewarded ads atm");
		}
    }

    public void LoadBanner(){
        Debug.Log ("Load Banner Button Clicked");
        IronSource.Agent.loadBanner(IronSourceBannerSize.BANNER, IronSourceBannerPosition.BOTTOM);
        addTextToLog("Load Banner Button Clicked");

    }

        public void DestroyBanner()
    {
        Debug.Log("Destroy Banner Button Clicked");
        IronSource.Agent.destroyBanner();
        addTextToLog("Destroy Banner Button Clicked");

    }

    /************* Interstitial AdInfo Delegates *************/
    // Invoked when the interstitial ad was loaded succesfully.
    void InterstitialOnAdReadyEvent(IronSourceAdInfo adInfo) {
        addTextToLog("InterstitialOnAdReadyEvent");
    }

    // Invoked when the initialization process has failed.
    void InterstitialOnAdLoadFailed(IronSourceError ironSourceError) {
        addTextToLog("InterstitialOnAdLoadFailed");
    }

    // Invoked when the Interstitial Ad Unit has opened. This is the impression indication. 
    void InterstitialOnAdOpenedEvent(IronSourceAdInfo adInfo) {
        addTextToLog("InterstitialOnAdOpenedEvent");
    }

    // Invoked when end user clicked on the interstitial ad
    void InterstitialOnAdClickedEvent(IronSourceAdInfo adInfo) {
        addTextToLog("InterstitialOnAdClickedEvent");
    }

    // Invoked when the ad failed to show.
    void InterstitialOnAdShowFailedEvent(IronSourceError ironSourceError, IronSourceAdInfo adInfo) {
        addTextToLog("InterstitialOnAdShowFailedEvent");
    }
    
    // Invoked when the interstitial ad closed and the user went back to the application screen.
    void InterstitialOnAdClosedEvent(IronSourceAdInfo adInfo) {
        addTextToLog("InterstitialOnAdClosedEvent");
    }

    // Invoked before the interstitial ad was opened, and before the InterstitialOnAdOpenedEvent is reported.
    // This callback is not supported by all networks, and we recommend using it only if  
    // it's supported by all networks you included in your build. 
    void InterstitialOnAdShowSucceededEvent(IronSourceAdInfo adInfo) {
        addTextToLog("InterstitialOnAdShowSucceededEvent");
    }


    /************* RewardedVideo AdInfo Delegates *************/
    // Indicates that there’s an available ad.
    // The adInfo object includes information about the ad that was loaded successfully
    // This replaces the RewardedVideoAvailabilityChangedEvent(true) event
    void RewardedVideoOnAdAvailable(IronSourceAdInfo adInfo) {
        addTextToLog("RewardedVideoOnAdAvailable");
    }
    // Indicates that no ads are available to be displayed
    // This replaces the RewardedVideoAvailabilityChangedEvent(false) event
    void RewardedVideoOnAdUnavailable() {
        addTextToLog("RewardedVideoOnAdUnavailable");
    }
    // The Rewarded Video ad view has opened. Your activity will loose focus.
    void RewardedVideoOnAdOpenedEvent(IronSourceAdInfo adInfo){
        addTextToLog("RewardedVideoOnAdOpenedEvent");
    }
    // The Rewarded Video ad view is about to be closed. Your activity will regain its focus.
    void RewardedVideoOnAdClosedEvent(IronSourceAdInfo adInfo){
        addTextToLog("RewardedVideoOnAdClosedEvent");
    }
    
    // The user completed to watch the video, and should be rewarded.
    // The placement parameter will include the reward data.
    // When using server-to-server callbacks, you may ignore this event and wait for the ironSource server callback.
    void RewardedVideoOnAdRewardedEvent(IronSourcePlacement placement, IronSourceAdInfo adInfo){
        addTextToLog("RewardedVideoOnAdRewardedEvent");
    }
    // The rewarded video ad was failed to show.
    void RewardedVideoOnAdShowFailedEvent(IronSourceError error, IronSourceAdInfo adInfo){
        addTextToLog("RewardedVideoOnAdShowFailedEvent");
    }
    // Invoked when the video ad was clicked.
    // This callback is not supported by all networks, and we recommend using it only if
    // it’s supported by all networks you included in your build.
    void RewardedVideoOnAdClickedEvent(IronSourcePlacement placement, IronSourceAdInfo adInfo){
        addTextToLog("RewardedVideoOnAdClickedEvent");
    }

    /************* Banner AdInfo Delegates *************/
    //Invoked once the banner has loaded
    void BannerOnAdLoadedEvent(IronSourceAdInfo adInfo) 
    {
        addTextToLog("BannerOnAdLoadedEvent");
    }
    //Invoked when the banner loading process has failed.
    void BannerOnAdLoadFailedEvent(IronSourceError ironSourceError) 
    {
        addTextToLog("BannerOnAdLoadFailedEvent");
    }
    // Invoked when end user clicks on the banner ad
    void BannerOnAdClickedEvent(IronSourceAdInfo adInfo) 
    {
        addTextToLog("BannerOnAdClickedEvent");
    }
    //Notifies the presentation of a full screen content following user click
    void BannerOnAdScreenPresentedEvent(IronSourceAdInfo adInfo) 
    {
        addTextToLog("BannerOnAdScreenPresentedEvent");
    }
    //Notifies the presented screen has been dismissed
    void BannerOnAdScreenDismissedEvent(IronSourceAdInfo adInfo) 
    {
        addTextToLog("BannerOnAdScreenDismissedEvent");
    }
    //Invoked when the user leaves the app
    void BannerOnAdLeftApplicationEvent(IronSourceAdInfo adInfo) 
    {
        addTextToLog("BannerOnAdLeftApplicationEvent");
    }

}
			