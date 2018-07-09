//
//  LMVASTMacroProcessor.h
//  LoopMe
//
//  Copyright (c) 2018 LoopMe. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LoopMeVASTMacroProcessor : NSObject

+ (NSURL *)macroExpandedURLForURL:(NSURL *)URL errorCode:(NSInteger)errorCode;
+ (NSURL *)macroExpandedURLForURL:(NSURL *)URL errorCode:(NSInteger)errorCode videoTimeOffset:(NSTimeInterval)timeOffset videoAssetURL:(NSURL *)videoAssetURL;

@end
