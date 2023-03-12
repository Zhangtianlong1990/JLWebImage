//
//  JLWebImageDisk.m
//  JLWebImage
//
//  Created by 张天龙 on 2023/3/11.
//  Copyright © 2023 张天龙. All rights reserved.
//

#import "JLWebImageDisk.h"
#import "JLFileTool.h"

@interface JLWebImageDisk()

@property(nonatomic, strong) dispatch_queue_t diskQueue;

@end

@implementation JLWebImageDisk

- (instancetype)init
{
    self = [super init];
    if (self) {
        _diskQueue = dispatch_queue_create("com.disk.safequeue", DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}

- (UIImage *)getDiskCacheWithURL:(NSString *)url{
    __block UIImage *image = nil;
    if (!url) return image;
    dispatch_sync(_diskQueue, ^{
        //2.2.4 加载沙盒的文件数据
        NSData *data = [NSData dataWithContentsOfFile:[JLFileTool getFilePath:url]];
        if (!data) {
            image = nil;
        }else{
            image = [UIImage imageWithData:data];
        }
    });
    return image;
}
- (BOOL)setupDiskCache:(NSData *)aImageData withURL:(NSString *)url{
    __block BOOL isWrite = NO;
    if (!url) return NO;
    dispatch_barrier_sync(_diskQueue, ^{
        isWrite = [aImageData writeToFile:[JLFileTool getFilePath:url] atomically:YES];
    });
    return isWrite;
}
@end
