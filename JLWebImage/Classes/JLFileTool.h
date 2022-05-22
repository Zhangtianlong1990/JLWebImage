//
//  JLFileTool.h
//  JLWebImage
//
//  Created by 张天龙 on 2022/5/22.
//  Copyright © 2022 张天龙. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JLFileTool : NSObject
+ (NSString *)getCachePath;
+ (NSInteger)countFileSizeWithPath:(NSString *)aPath;
@end

NS_ASSUME_NONNULL_END
