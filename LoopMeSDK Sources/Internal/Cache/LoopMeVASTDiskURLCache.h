//
//  LoopMeVASTDiskURLCache.h
//  
//  Copyright (c) 2016 LoopMe. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LoopMeVASTDiskURLCache : NSObject

+ (LoopMeVASTDiskURLCache *)sharedDiskCache;

/*
 * Do NOT call any of the following methods on the main thread, potentially lengthy wait for disk IO
 */
- (BOOL)cachedDataExistsForKey:(NSString *)key;
- (NSData *)retrieveDataForKey:(NSString *)key;
- (void)storeData:(NSData *)data forKey:(NSString *)key;

@end
