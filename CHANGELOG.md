## Version 7.4.24 (10.12.2024)

- Release new version of adapters (#236)

## Version 7.4.23 (28.11.2024)

- [SDK-575] Fixed: timeElapsedSinceStart is nil (#235)
- Update AppLovinLoopMeCustomAdapter.podspec (#233)
- Add new version to ISLoopMeCustomAdapter (#232)

## Version 7.4.22 (26.11.2024)

- Fix project struct (#231)
- [SDK-484] Video streaming (#225)
- [SDK-566]Added new  Endpoint for ortb API (#230)
- Feature/sdk 452 (#216)
- [SDK-480] Remove unused error from SDK (#213)
- [SDK-452] Added new error for empty data response (#214)
- Replaced: LoopMeEventErrorTypeLog with LoopMeEventErrorTypeCustom as workaround of LoopMeErrorEventSender integration into LoopMeLoggingSender
- [SDK-403] Add information to error logging (#175)
- [SDK-471] Added created time to error sender (#212)
- [SDK-450] Added ortb version to error sender header field (#211)
-  Implement session_id data filed (#210)
- SDK-458 Fix field validation naming
- [SDK-458] Ortb request data validation (#206)
- Fix Skad errors (#207)
- Update errorType (#205)
- [SDK-397] Add latency changer in request method (#185)
- Update AppLovin Adapter version to 0.0.9
- Update IronSource Adapter version to 0.0.13

## Version 7.4.21 (13.09.2024)

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

## Version 7.4.20 (15.07.2024)

- [SDK-346] Fix LoopMe bridge error
- [SDK-345] No click redirect for some RM creatives
- [SDK-335] Remove 'expdir': [5] from banner request
- Refactor ISLoopMeCustomBanner
- Clean up ViewController in IronSource Demo App
- [SDK-322] Latency issue. Remove swapped size request on NO_ADS
- [SDK-330] Clean up code. Remove IAS and Moat code
- [SDK-329] Black screen on first ad load
- [SDK-328] Wrong close button behaviour
- [SDK-320] Do not show close button for banner placement
- [SDK-321] Banner rendered incorrectly
- [SDK-317] Remove video object from request if it's banner (#151)
- [SDK-318] Fix threads issue in IronSource adapter (#148)
- Refactoring LoopMeURLResolver
- [SDK-315] Fix repo (#149)
- [SDK-315] Avoid logic when video url is nill. (#146)
- [SDK-314] Fix hierarchy for AlertVC in Ironsource simple app (#145)
- [SDK-316] Enhance SDK error event (#143)
- [SDK-283] Fix rewarded skipoffset time in SDK and update adapters del… (#141)
- [SDK-286] Remove initialization-time code that is unneeded (#139)
- [SDK-293] Fix error fields (#140)
- [SDK-288] Add new field to error body (#138)
- [SDK-277] Enhance SDK error event reporting (#137)
- [SDK-277] Added SessionDuration and impdepth to user.ext object (#136)
- Remove creating blurred endcard background
- [SDK-265] Add pxration signal to  Device Object in ORTB request (#128)
- [SDK-252] Remove pos from video object (#134)
- Remove the OMSDK from the codebase (#121)
- Remove LoopMeResources.bundle (#131)
- Use scripts to generate development environment
- Investigation: Many 'Time out' messages
- [SDK-268] Fix consent
- [SDK-268] Move "consent" object to correct place
- [SDK-264] Added new signal to App object
- Update IronSource Adapter version to 0.0.11
- ISLoopMeCustomAdapter. Fixing initialization
- Remove unused code
- Update IronSource Demo App By implementing delegate listeners
- Remove useless LoopMeAnalyticsProvider
- Remove library search path for swift 5
- Update AppLovin Adapter version to 0.0.7
- Update IronSource Adapter version to 0.0.10

## Version 7.4.19 (29.05.2024)

- Disable video request for banner slot
- Refactoring. Fix OMIDWrapper analysis issu
- Refactoring. Fix analysis issues
- Refactoring. Fix passing primitive boolean value to isRewarded
- Refactoring LoopMeVPAIDClient
- Update IronSource Adapter version to 0.0.9
- Update AppLovin Adapter version to 0.0.6

## Version 7.4.18 (27.05.2024)

- Fix: video ads have the wrong size when rotated
- Update AppLovin Adapter version to 0.0.5
- Review and update AppLovin Max Adapter code

## Version 7.4.17 (25.05.2024)

- Added missing method willAppear

## Version 7.4.16 (24.05.2024)

- [SDK-240] Fix the rotation logic in SDK
- [SDK-222] Fix after code review
- [SDK-221] Fix request for video size on SDK
- [SDK-221]Fix thread issue in LoopMeVASTImageDowloader
- [SDK-216] Remove commented lines
- [SDK-215] Remove duplicate method
- [SDK-216] Remove video360 support
- [SDK-215] Fix deprecated method in Applovin adapter

## Version 7.4.15 (03.05.2024)

- Remove nested bundles

## Version 7.4.14 (03.05.2024)

- Added OMID dependency
- Update AppLovin Demo app. Removed deprecated methods
- [SDK-214] Fix bundle in Applovin
- [sdk-214-2] Change repo for Applopovin
- [SDK-214] Fix Applovin repo
- [SDK-214] Fix Applovin repo
- Update AppLovinLoopMeCustomAdapter version to support LoopMeUnitedSDK 7.4.13
- Update ISLoopMeCustomAdapter version to support IronSourceSDK 8.0 and LoopMeUnitedSDK 7.4.13
- [SDK-214] Fix Applovin repo

## Version 7.4.13 (29.04.2024)

- Remove commented code
- [SDK-209] Fix threads in Interstitial
- Add default ATT request window to IS Demo App
- Repo clean up. Remove xcworkspace for AdMobAdapterDemo
- Repo clean up. Remove .idea
- Repo clean up. Remove LoopMeUnitedSDK.framework copy
- Remove MoPub. MoPub was shut down
- Remove LoopMe own GDPR-like consent popup
- [SDK-209] Fix thread in LoopMeInterstitial class
- Embedding OMID library
- remove MOAT and IAS libraries
- [SDK-191] Update version of OMID
- [SDK-205] Fix
- [SDK-205] Remove libAvid-loopme-3.6.8. and LOOMoatMobileAppK
- Agoop's reported crash. Refactoring of LoopMeGDPRTools.m
- [SDK-202] Update OMID version to 1.4.12
- [SDK-191] Fix after code review
- [SDK-191] Change name of error struct
- [SDK-191] Refactor and migration OMSDKWrapper
- [SDK-191] Migrate OMIDEvent Wrapper
- Refactoring. LoopMeORTBTools.m
- [SDK-191] Migration  OMID wrapper to Swift
- [SDK-136] Fix rewarded request
- SDK Companion ad support in OpenRTB request
- [SDK-187] Add version of sdk
- [SDK-136] Fix Rewarded init func
- Refactoring LoopMeJSClient.m
- Refactoring. LoopMeMRAIDClient.m
- useCustomClose deprecated
- [SDK-133] Add new init for rewarded
- Update AppLovinLoopMeCustomAdapter to use LoopMeSDK 7.4.12
- Update ISLoopMeCustomAdapter to use LoopMeSDK 7.4.12
- [SDK-113] Add rewarded input for init methods

## Version 7.4.12 (05.04.2024)

- Update ISLoopMeCustomAdapter version to support IronSourceSDK 7.9.0
- Add missing Bridging Header file to AppLovin Sample App
- Fix AppLovin repository naming conflicts
- Refactoring. LoopMeAdDisplayControllerNormal.m
- [SDK-176]  avoid auto-invoke ATT pop up
- Refactoring. LoopMeOMIDWrapper.m
- [SDK-129] Fix after code review
- [SDK-129] Fix after review
- [SDK-129] Added func to SDK  to get sourceapp id from itunes
- Update mediation adapters with new LoopMeUnitedSDK version (7.4.11)

## Version 7.4.11 (21.03.2024)

- [SDK-136] Add rwdd key to video object in LoopMeORTBTools
- [SDK-174] Take rootVC from window in SDK init method
- [SDK-136_113] Unskippable rewarded and interstitial ads
- [SDK-140] Handle with XMLParser errors
- [SDK-166] Add swift version to ISLoopMeCustomAdapter podspec
- [SDK-169] Change adUnitIdentifier and bundle in Applovin demo app
- [SDK-170] Fix file name in adapter and set version in podspec Applovin
- [SDK-169] Fix presenting ads twice
- [SDK-141] Fix Applovin Demo project
- Update Podfile for Applovin-mediation-sample - fixed local adapter path
- [SDK-141] Fix PodSpec source
- Define version for dependencies for ISLoopMeCustomAdapter
- [SDk-141] Create Applovin Custom Adapter

## Version 7.4.10 (04.03.2024)

- Fixed Build issue: can't find import path

## Version 7.4.9 (04.03.2024)

- [SDK-162] Rename value
- [SDK-162] Fix DNT parameter
- [SDK-162] Fix DNT
- [SDK-63] Fix placeholder
- Unit Tests. AdTrackingLinks.swift, AdVerification.swift, AssetLinks.swift, VastSkipOffset.swift
- Fix
- Fix
- Fix code style
- Fix
- [SDK-63] Remove changes
- [SDK-63] Fix
- [SDK-63] fix skad logic in banner
- [SDK-162] Fix ATTrackingManagerAuthorizationStatus
- [SDK-63] Put default value
- Unit tests. Converter.swift
- Update VASTMacroProcessor.swift
- [SDK-63] Update Skad implemantation
- Fix import warnings
- Suppress OpenGL warnings for video360
- Build and publish automatisation
- Fix CompanionClickTracking
- Click Trackers not fired from SDK
- Crash reported by Appsoleut
- Set skipoffset to 100% if attribute does not exist
- Update build script by building framework directly to LoopMeUnitedSDK.embeddedframework
- Remove unused tests
- [SDK-107] Fix IDFA when users allow tracking
- [SDK-117]Fix typo i key version (SkadNetwork)
- [SDK-123] Fix run test in simulator
- Update the bundle
- [SDK-63] Draft
- [SDK-63] Add skad impression
- [SDK-63] Update AdConfigure file with Skadnetwork response
- [SDK-63] Update response with Skadnetwork requests

## Version 7.4.8 (31.01.2024)

- Create privacy manifest
 
## Version 7.4.7 (19.01.2024)

- Fix bundle resources issue

## Version 7.4.6 (17.01.2024)

- Improve bundle resources link

## Version 7.4.5 (08.11.2023)

- Change marketing version

## Version 7.4.4 (08.11.2023)

- Change marketing version

## Version 7.4.3 (02.11.2023)

- Allow fullscreen ad to rotate (LoopMeSDK)
- Fix storyboard and add custom size banner (Ironsource)
- Connected Banner, Interstitial, Rewarded (AppLovin)
- Create adapter (AppLovin)
- Fix conflicts with constraints (Ironsource)

## Version 7.4.2 (09.10.2023)

- Fix constrain (Frame) in LoopMeAdView

## Version 7.4.1 (26.09.2023)

- Fix and improvement

## Version 7.4.0 (25.09.2023)

- Fix and improvement

## Version 7.3.9 (29.07.2023)

- Fixed VAST landscape video

## Version 7.3.8 (27.07.2023)

- add AppLovin adapter

## Version 7.3.7 (26.01.2023)

- update admob adapter

## Version 7.3.6 (26.01.2022)

- add xcframework

## Version 7.3.5 (13.01.2022)

- add IronSorce adapter

## Version 7.3.4 (21.10.2021)

- Fixes
- update mopub adapter

## Version 7.3.3 (14.09.2021)

- Fixes
- ios 14 tracking
- GDPR support the consent string
- CCPA: Ability to support the US Privacy String
- Coppa: Ability to support determine the value COPPA flag

## Version 7.3.2 (06.05.2020)

- Fixed non replaceable macroses issue in VAST URL

## Version 7.3.1 (14.04.2020)

- Updated OMSDK to 1.3.3
- Memory management improvements

## Version 7.3.0 (27.03.2020)

- Updated OMSDK to 1.3
- Vast wrapper and mediafile fixes
- New click browser

## Version 7.2.7 (09.01.2020)

- Totally removed UIWebView from SDK

## Version 7.2.6 (23.12.2019)

- Fixed click URL issues

## Version 7.2.5 (06.12.2019)

- Added support of California Consumer Privacy Act (CCPA)

## Version 7.2.4 (14.11.2019)

- Fixed incorrect ad response cache

## Version 7.2.3 (06.11.2019)

- Fixed LoopMeError enum type from NSUInteger to NSInteger

## Version 7.2.2 (01.11.2019)

- Part of architecture was moved to Swift
- Ad Response parsing covered with unit tests
- Fixed double triggered events
- Removed invisible close area for MRAID banners
- Fixed bug with disappearing end card after the video creative
- A number of additional changes and improvements

## Version 7.2.1 (31.10.2019)

- Part of architecture was moved to Swift
- Ad Response parsing covered with unit tests
- Fixed double triggered events
- Removed invisible close area for MRAID banners
- Fixed bug with disappearing end card after the video creative
- A number of additional changes and improvements

## Version 7.1.1 (27.07.2019)

- Fixed bug when `init callback` called twice

## Version 7.1.0 (18.07.2019)

- Added Open Measurement SDK (OM SDK) for viewability measurement
- Added VAST 4.1 support
- Replaced deprecated UIWebView with WKWebView


## Version 7.0.4 (24.01.2019)

- IAS measurement support improvements

## Version 7.0.3 (18.12.2018)

- fixed VPAID ads
- fixed GDPR dialog window

## Version 7.0.2 (08.08.2018)

- fixed bugs video caching
- fixed layout errors on vast ad

## Version 7.0.1 (19.07.2018)

- fixed VPAID ad

## Version 7.0.0 (16.07.2018)

- fixed VAST player UI
- so high version for clearer update from old SDK

## Version 1.2.0 (09.07.2018)

- GDPR support
- support IAS viewability measurement
- eliminated memory leaks
- performance improved

## Version 1.1.0 (13.04.2018)

- Compatible with VAST 4.0
- Compatible with MRAID expandable banner
- Display rate performance improvement


## Version 1.0.0 (29.10.2017)

- Initial version
