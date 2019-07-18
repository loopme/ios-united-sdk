//
//  ScrollViewController.m
//  Demo
//
//  Created by Bohdan on 4/10/19.
//  Copyright © 2019 LoopMe. All rights reserved.
//

#import "ScrollViewController.h"
#import <LoopMeUnitedSDK/LoopMeAdView.h>

@interface ScrollViewController ()<LoopMeAdViewDelegate, UIScrollViewDelegate>

@property (nonatomic) LoopMeAdView *mpuVideo;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;


@end

@implementation ScrollViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.scrollView.delegate = self;
    self.mpuVideo = [LoopMeAdView adViewWithAppKey:self.appKey
                                             frame:(CGRect){10, 200, 300, 250}
           viewControllerForPresentationGDPRWindow: self
                                        scrollView:self.scrollView
                                          delegate:self];
    
    [self.mpuVideo setMinimizedModeEnabled:YES];
    
    [self.contentView addSubview:self.mpuVideo];
    
    [self.mpuVideo loadAd];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (UIViewController *)viewControllerForPresentation {
    return self;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.mpuVideo updateAdVisibilityInScrollView];
}
    

@end
