You can find integration guide on [wiki](https://loopme-ltd.gitbook.io/docs-public/loopme-ios-sdk) page.

## What's new ##

**Version 7.4.21**

- [SDK] Fix adDisplayControllerWillLeaveApplication delegate (#202)
- Remove unused LoopMeServerURLBuilder
- Small refactor (#200)
- Redirect does not work for HTML creative
- Send SDK init time to kibana
- Remove unused delegate in Applovin, added missed delegate to Ironsource (#195)
- Trigger adDidLoad before we're starting loading an HTML creative inside the WebView
- Remove absent LoopMeGeoLocationProvider.m reference
- Remove absent LoopMeGeoLocationProvider reference
- [SDK] Fix delegate login in IS adapter and remove unused code in demo… (#190)
- Don't use mraid for non mraid ads
- Remove LoopMeResources.bundle from IronSourceDemoApp
- Remove unused IronSourceDemoApp.xcworkspace
- Fix IronSource initialization for IronSourceDemoApp
- [SDK] Fix delegate in Applovin adapter banner (#184)
- [SDK] Update  mraid js resources in initWebView (#183)
- Fix setAdapterName call method (#182)
- [SDK-424] Optimise Omid init method (#181)
- [SDK-424] change sdk_type value in ErrorSender (#180)
- [SDK-420] Remove location permission (#179)
- Omid SDK init latency checker (#178)
- [SDK-400] Add latency check to SDK init (#177)
- [SDK-394] Refactor LoopmeAdView and LoopMeInterstitialGeneral classes (#174)
- Refactor batteryLevel property (#176)
- Fix impression issue in banner SDK  (#173)
- [SDK-381] Fix latency issue in IC demo ap (#172)
- [SDK-361] Add battery saver signal to SDK (#171)
- [SDK-364] Add batteryLevel signal to request (#170)
- [SDK-349] Remove vibration from SDK (#169)
- [SDK-338] Add Latency logic  to IronSource demo app (#168)
- [SDK-344] Change ads orientation depend on responce (#167)
- Update AppLovin Adapter version to 0.0.8
- Fix pod error for ISLoopMeCustomAdapter
- Update IronSource Adapter version to 0.0.12

Please view the [changelog](CHANGELOG.md) for details.

## License ##

see [License](LICENSE.md)
