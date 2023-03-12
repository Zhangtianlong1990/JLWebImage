//
//  JLThreadTool.m
//  JLWebImage
//
//  Created by 张天龙 on 2023/3/12.
//  Copyright © 2023 张天龙. All rights reserved.
//

#import "JLThreadTool.h"

@implementation JLThreadTool
+ (void)asyncMainThread:(void (^)())task{
    dispatch_async(dispatch_get_main_queue(), ^{
        task();
    });
}
+ (void)syncMainThread:(void (^)())task{
    dispatch_sync(dispatch_get_main_queue(), ^{
        task();
    });
}
+ (void)asyncGlobalQueue:(void(^)())task{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        task();
    });
}
@end
