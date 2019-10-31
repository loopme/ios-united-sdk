//
//  UIImage+LoopMeBinaryImage.h
//  LoopMeSDK
//
//  Created by Dmitriy Lihachov on 10.07.14.
//
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, LoopMeImageType) {
    LoopMeImageTypeBrowserBack,
    LoopMeImageTypeBrowserBackActive
} ;

// Non retina

extern unsigned char lm_navigation_back_active_icon_png[];
extern unsigned int lm_navigation_back_active_icon_png_len;

extern unsigned char lm_navigation_back_icon_png[];
extern unsigned int lm_navigation_back_icon_png_len;

// Retina

extern unsigned char lm_navigation_back_icon_2x_png[];
extern unsigned int lm_navigation_back_icon_2x_png_len;

extern unsigned char lm_navigation_back_active_icon_2x_png[];
extern unsigned int lm_navigation_back_active_icon_2x_png_len;

@interface UIImage (LoopMeBinaryImage)

+ (UIImage *)imageFromDataOfType:(LoopMeImageType)type;

@end
