//
//  CityCell.m
//  LoopmeDemo
//
//  Copyright (c) 2015 Loopmemedia. All rights reserved.
//

#import "TableCityCell.h"
#import "UIImageView+WebCache.h"

@implementation TableCityCell

- (void)setData:(NSDictionary *)data
{
    self.labCityName.text = data[@"name"];
    self.labCountry.text = data[@"country"];
    self.labArea.text = data[@"area"];
    [self.imgCover sd_setImageWithURL:[NSURL URLWithString:data[@"image"]]];
}

@end
