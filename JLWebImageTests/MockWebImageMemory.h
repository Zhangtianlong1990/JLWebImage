//
//  MockWebImageMemory.h
//  JLWebImageTests
//
//  Created by 张天龙 on 2023/3/12.
//  Copyright © 2023 张天龙. All rights reserved.
//

#import "JLWebImageContact.h"
#import <UIKit/UIKit.h>

@interface MockWebImageMemory : NSObject<JLWebImageMemoryInterface>
@property (nonatomic,strong) UIImage *image;
@property (nonatomic,assign) int getImageCacheCallCount;
@end

