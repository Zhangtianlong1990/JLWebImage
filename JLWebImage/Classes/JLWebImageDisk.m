//
//  JLWebImageDisk.m
//  JLWebImage
//
//  Created by 张天龙 on 2023/3/11.
//  Copyright © 2023 张天龙. All rights reserved.
//

#import "JLWebImageDisk.h"
#import "JLFileTool.h"

@implementation JLWebImageDisk
- (UIImage *)getDiskCacheWithURL:(NSString *)url{
    //2.2.4 加载沙盒的文件数据
    NSData *data = [NSData dataWithContentsOfFile:[JLFileTool getFilePath:url]];
    if (!data) {
        return nil;
    }
    UIImage *image = [UIImage imageWithData:data];
    return image;
}
- (BOOL)setupDiskCache:(NSData *)aImageData withURL:(NSString *)url{
    BOOL isWrite = [aImageData writeToFile:[JLFileTool getFilePath:url] atomically:YES];
    return isWrite;
}
@end
