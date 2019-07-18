//
//  ViewController.m
//  LoopmeDemo
//
//  Copyright (c) 2015 Loopmemedia. All rights reserved.
//

#import "LDScrollableViewController.h"
#import "TableCityCell.h"

#import <LoopMeUnitedSDK/LoopMeAdView.h>

const float kLDAdCellHeight = 250.0f; // Video dimension 16x9
const float kLDAdCellWidth = 300.0f;

const int kLDAdIndex = 5;

@interface LDScrollableViewController () <LoopMeAdViewDelegate>
@property (nonatomic, strong) LoopMeAdView *mpuVideo;
@property (nonatomic, strong) NSMutableArray *cities;

@end

@implementation LDScrollableViewController

#pragma mark - Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Pre-defined data to be displayed as a content for UITableView
    self.cities = [self dictionaryWithContentsOfJSONString:@"source.json"];
    
    // Intializing `LoopMeAdView`
    self.appKey = @"9584545777";
    self.mpuVideo = [LoopMeAdView adViewWithAppKey:self.appKey
                                             frame:(CGRect){10, 0, kLDAdCellWidth, kLDAdCellHeight}
           viewControllerForPresentationGDPRWindow: self
                                        scrollView:self.tableView
                                          delegate:self];
    
    
    
    /*
     * Enable minimized mode.
     * Minimized version of ad will appear on right-bottom corner every time
     * when original ad is out of viewport during scrolling
     */
    [self.mpuVideo setMinimizedModeEnabled:YES];

    // Request for ad
    [self.mpuVideo loadAd];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    /*
     * Resuming video ad playback or any ad activity if `UIViewController` about to appear on the screen
     */
    [self.mpuVideo setAdVisible:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    /*
     * Pausing video ad playback or any ad activity if `UIViewController` is dismissed
     */
    [self.mpuVideo setAdVisible:NO];
}

#pragma mark - UITableViewDelegate | UITableViewDataSource

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.cities.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self isAdPlacedAtIndexPath:indexPath]) {
        return self.mpuVideo.bounds.size.height;
    } else {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            return 150.0f;
        } else {
            return 65.0f;
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self isAdPlacedAtIndexPath:indexPath]) {
        NSString *identifier = @"AdCell";
        UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
        [cell.contentView addSubview:self.mpuVideo];
        return cell;
    } else {
        static NSString *CityCellIdentifier = @"CityCell";
        UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CityCellIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CityCellIdentifier];
        }
        
        NSDictionary *data = self.cities[indexPath.row];
        cell.textLabel.text = data[@"name"];
        cell.detailTextLabel.text = data[@"country"];
//        cell.labArea.text = data[@"area"];
//        cell.data = self.cities[indexPath.row];
        
        return cell;
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    /*
     * Updating ad visibility in order to manage video ad playback
     */
    [self.mpuVideo updateAdVisibilityInScrollView];
}

#pragma mark - LoopMeAdViewDelegate

- (void)loopMeAdViewDidLoadAd:(LoopMeAdView *)adView
{
    [self insertAd:adView atIndex:kLDAdIndex];
}

- (void)loopMeAdView:(LoopMeAdView *)adView didFailToLoadAdWithError:(NSError *)error {
    
}

- (UIViewController *)viewControllerForPresentation
{
    return self;
}

#pragma mark - private

- (BOOL)isAdPlacedAtIndexPath:(NSIndexPath *)indexPath
{
    return ([self.cities[indexPath.row] isKindOfClass:[LoopMeAdView class]]) ? YES : NO;
}

- (void)insertAd:(LoopMeAdView *)adView atIndex:(NSInteger)index {
    //  Update dataSource, insert `LoopMeAdView` item into `UITableView` content
    [self.cities insertObject:adView atIndex:index];
    [self.tableView beginUpdates];
    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]]
                          withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView endUpdates];
}

- (id)dictionaryWithContentsOfJSONString:(NSString*)fileLocation
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:[fileLocation stringByDeletingPathExtension] ofType:[fileLocation pathExtension]];
    NSData* data = [NSData dataWithContentsOfFile:filePath];
    __autoreleasing NSError* error = nil;
    id result = [NSJSONSerialization JSONObjectWithData:data
                                                options:NSJSONReadingMutableContainers error:&error];
    
    if (error != nil) return nil;
    return result;
}

@end
