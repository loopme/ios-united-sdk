//
//  LDViewController.m
//  LoopmeDemo
//
//  Copyright (c) 2015 Loopmemedia. All rights reserved.
//

#import "LDViewController.h"
#import "UIImage+iphone5.h"

@interface LDViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *background;

@end

@implementation LDViewController

#pragma mark - Services

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        _background.image = [UIImage imageNamedForDevice:@"bg_new_main"];
    }
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 70, 30)];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.image = [UIImage imageNamed:@"LoopMeLogo"];
    UIBarButtonItem *barBtn = [[UIBarButtonItem alloc] initWithCustomView:imageView];
    self.navigationItem.leftBarButtonItem = barBtn;
    
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc] initWithTitle:version style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.rightBarButtonItem = rightBtn;
}

@end
