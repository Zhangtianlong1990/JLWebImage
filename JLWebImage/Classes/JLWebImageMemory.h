//
//  JLWebImageMemory.h
//  JLWebImage
//
//  Created by 张天龙 on 2023/3/11.
//  Copyright © 2023 张天龙. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface JLWebImageMemory : NSObject
- (void)setupImageCache:(UIImage *)aImage WithKey:(NSString *)aKey;
- (UIImage *)getImageCacheWithKey:(NSString *)aKey;
- (void)clearMemories;
@end

