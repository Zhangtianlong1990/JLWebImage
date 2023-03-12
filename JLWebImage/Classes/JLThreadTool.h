//
//  JLThreadTool.h
//  JLWebImage
//
//  Created by 张天龙 on 2023/3/12.
//  Copyright © 2023 张天龙. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JLThreadTool : NSObject
+ (void)asyncMainThread:(void(^)())task;
+ (void)syncMainThread:(void(^)())task;
+ (void)asyncGlobalQueue:(void(^)())task;
@end

