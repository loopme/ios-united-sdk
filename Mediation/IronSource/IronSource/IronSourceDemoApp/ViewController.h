//
//  ViewController.h
//  IronSourceDemoApp
//
//  Copyright © 2017 IronSource. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <IronSource/IronSource.h>

@interface ViewController : UIViewController<LevelPlayRewardedVideoManualDelegate ,LevelPlayInterstitialDelegate, LevelPlayBannerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *showRVButton;
@property (weak, nonatomic) IBOutlet UIButton *loadRVButton;
@property (weak, nonatomic) IBOutlet UIButton *showISButton;
@property (weak, nonatomic) IBOutlet UIButton *loadISButton;
@property (weak, nonatomic) IBOutlet UIButton *loadBannerButton;
@property (weak, nonatomic) IBOutlet UIButton *destroyBannerButton;
@property (nonatomic, strong) ISPlacementInfo *rvPlacementInfo;
@property (nonatomic, strong) ISBannerView *banner;
@property (nonatomic, assign) BOOL showAlertVC;

@end

