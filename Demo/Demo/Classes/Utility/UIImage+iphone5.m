//
//  UIImage+iphone5.m
//  LoopmeDemo
//
//  Copyright (c) 2015 Loopmemedia. All rights reserved.
//

#import "UIImage+iphone5.h"

@implementation UIImage (iphone5)

+ (UIImage*)imageNamedForDevice:(NSString*)name
{
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        if (([UIScreen mainScreen].bounds.size.height * [UIScreen mainScreen].scale) >= 1136.0f) {
            //Check if is there a path extension or not
            if (name.pathExtension.length) {
                name = [name stringByReplacingOccurrencesOfString: [NSString stringWithFormat:@".%@", name.pathExtension]
                                                       withString: [NSString stringWithFormat:@"-568h.%@", name.pathExtension ] ];
            } else {
                name = [name stringByAppendingString:@"-568h"];
            }
        }
    }
    return [UIImage imageNamed: name];
}

@end
