//
//  LoopMeDefinitions.h
//  LoopMeSDK
//
//  Created by Dmitriy Lihachov on 8/21/12.
//  Copyright (c) 2012 LoopMe. All rights reserved.
//

#ifndef LoopMeDefinitions_h
#define LoopMeDefinitions_h

#define LOOPME_SDK_VERSION [[NSBundle bundleForClass:LoopMeSDK.class].infoDictionary objectForKey:@"CFBundleShortVersionString"]

#define LOOPME_MOAT_PARTNER_CODE @"loopmeinappvideo302333386816"
#define kLoopMeIASAnID @"927083"

#define kLoopMeWebViewLoadingTimeout 180
#define kLoopMeBaseURL @"https://i.loopme.me/"
#define kLoopMeURLScheme @"loopme"

#define kLoopMeHTMLBannerSize CGSizeMake(320, 50)
#define kLoopMeMPUBannerSize CGSizeMake(300, 250)

#define LOOPME_USERDEFAULTS_KEY_AUTOLOADING @"loopmeautoloading"

#undef SYSTEM_VERSION_LESS_THAN

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

#endif
