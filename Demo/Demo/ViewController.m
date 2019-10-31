//
//  ViewController.m
//  Demo
//
//  Created by Bohdan on 4/9/19.
//  Copyright © 2019 LoopMe. All rights reserved.
//

#import <LoopMeUnitedSDK/LoopMeSDK.h>
#import <LoopMeUnitedSDK/LoopMeLogging.h>
#import "ViewController.h"

@interface ViewController ()

@property (nonatomic) NSArray *tableData;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[LoopMeSDK shared] initSDKFromRootViewController:self completionBlock:^(BOOL success, NSError *error) {
        if (!success) {
            LoopMeLogDebug(@"%@", error);
        }
    }];
    
    
//    NSURL *bundleURL = [[NSBundle mainBundle] URLForResource:@"LoopMeResources" withExtension:@"bundle"];
//    if (!bundleURL) {
//        @throw [NSException exceptionWithName:@"NoBundleResource" reason:@"No loopme resourse bundle" userInfo:nil];
//    }
//    NSBundle *resourcesBundle = [NSBundle bundleWithURL:bundleURL];
//    NSString *jsPath = [resourcesBundle pathForResource:@"mraid" ofType:@"js"];
//    NSString *mraidjs = [NSString stringWithContentsOfFile:jsPath encoding:NSUTF8StringEncoding error:NULL];

    
    // Do any additional setup after loading the view.
    [self.navigationItem setLargeTitleDisplayMode:UINavigationItemLargeTitleDisplayModeAutomatic];
//    [self.navigationController.navigationBar setPrefersLargeTitles:YES];
    UIImage *logo = [UIImage imageNamed:@"loopme_logo_top"];
    
    UIImageView *customView = [[UIImageView alloc] initWithImage:logo];
    [[[customView widthAnchor] constraintEqualToConstant:200] setActive:YES];
    [[[customView heightAnchor] constraintEqualToConstant:44] setActive:YES];
    
    [self.navigationItem setTitleView:customView];
    self.tableData = @[@"Interstitial (fullscreen)", @"Native video in content", @"HTML banner"];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tableData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * reusableId = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reusableId];
    
    cell.textLabel.text = [self.tableData objectAtIndex:indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *controllerName;
    NSString *appKey;
    NSString *title = [self.tableData objectAtIndex:indexPath.row];
    switch (indexPath.row) {
        case 0:
            controllerName = @"LDInterstitialViewController";
            appKey = @"test_interstitial_l";
            break;
        
        case 1:
            controllerName = @"LDScrollableViewController";
            appKey = @"9584545777";
            break;
            
        case 2:
            controllerName = @"LDBannerViewController";
            appKey = @"5265ed8a0a";
            break;

        default:
            break;
    }
    
    UIViewController *viewController = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:controllerName];
    [viewController setTitle:title];
    [viewController performSelector:@selector(setAppKey:) withObject:appKey];
    [self showViewController:viewController sender:nil];
}

@end
