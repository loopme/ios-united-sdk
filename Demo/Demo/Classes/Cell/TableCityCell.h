//
//  CityCell.h
//  LoopmeDemo
//
//  Copyright (c) 2015 Loopmemedia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TableCityCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imgCover;
@property (weak, nonatomic) IBOutlet UILabel *labCityName;
@property (weak, nonatomic) IBOutlet UILabel *labCountry;
@property (weak, nonatomic) IBOutlet UILabel *labArea;
@property (weak, nonatomic) IBOutlet UILabel *labKm;

@property (nonatomic) NSDictionary *data;

@end
