//
//  LDContentTableViewCell.h
//  LoopMeMediatonDemo
//
//  Created by Dmitriy on 7/29/15.
//  Copyright (c) 2015 injectios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MPNativeAdRendering.h"

@interface LDAdTableViewCell : UITableViewCell <MPNativeAdRendering>

@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *mainTextLabel;
@property (strong, nonatomic) UIImageView *iconImageView;

@end
