//
//  MockWebImageMemory.m
//  JLWebImageTests
//
//  Created by 张天龙 on 2023/3/12.
//  Copyright © 2023 张天龙. All rights reserved.
//

#import "MockWebImageMemory.h"

@implementation MockWebImageMemory
- (UIImage *)getImageCacheWithKey:(NSString *)aKey{
    return self.image;
}
@end
