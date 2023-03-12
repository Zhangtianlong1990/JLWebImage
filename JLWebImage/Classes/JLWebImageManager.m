//
//  JLWebCacheManger.m
//  
//
//  Created by 张天龙 on 17/3/6.
//  Copyright © 2017年. All rights reserved.
//

#import "JLWebImageManager.h"
#import "DataManager.h"
#import "JLFileTool.h"
#import "JLWebImageOperation.h"
#import "JLThreadTool.h"

@interface JLWebImageManager ()

@end

@implementation JLWebImageManager

JLSingletonM(WebImageManager)

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupAppLifecycleNotification];
    }
    return self;
}

- (void)setImageView:(id<JLWebImageViewInterface>)imageView url:(NSString *)url placeholderImage:(UIImage *)placeholderImage{
    
    NSAssert(imageView != nil, @"imageView is nil!");
    NSAssert(url != nil, @"url is nil!");
    NSAssert(self.memory != nil, @"memory is nil!");
    NSAssert(self.disk != nil, @"disk is nil!");
    NSAssert(self.downloader != nil, @"downloader is nil!");
    
    //下载图片前设置默认图片等待
    if (placeholderImage) {
        [imageView cb_setImage:placeholderImage url:url];
    }else{
        [imageView cb_setImage:nil url:url];
    }
    
    // 2.0 先从内存缓存中取出图片
    UIImage *memoryImage = [self.memory getImageCacheWithKey:url];;
    
    if (memoryImage) {
        NSLog(@"获取缓存：%@",url);
        [imageView cb_setImage:memoryImage url:url];
    }else{
        UIImage *diskImage = [self.disk getDiskCacheWithURL:url];
        
        if (diskImage) { //2.2.4.1 直接利用沙盒中图片
            NSLog(@"获取磁盘：%@",url);
            [imageView cb_setImage:diskImage url:url];
            [self.memory setupImageCache:diskImage withKey:url];
        }else { //2.2.4.2  下载图片
            NSLog(@"启动下载op：%@ %@",url,[NSThread currentThread]);
            [self.downloader downloadImage:imageView url:url];
        }
        
    }
}

- (void)clearMemories{
    if (self.memory) {
        [self.memory clearMemories];
    }
}

- (void)setupAppLifecycleNotification{
    //后台进前台通知 UIApplicationDidBecomeActiveNotification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveMemoryWarning) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    //进入后台UIApplicationDidEnterBackgroundNotification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
}

//进入后台方法
- (void)didReceiveMemoryWarning {
    [self clearMemories];
    [self checkExpiredImageCache];
}

    //每次后台进前台都会执行这个方法
- (void)didEnterBackground {
    [self checkExpiredImageCache];
}

- (void)checkExpiredImageCache{
    [[DataManager shareInstance] selectExpirationData:^(NSArray<JLImageDate *> * response) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self handleData:response];
        });
    }];
    
}

- (void)handleData:(NSArray<JLImageDate *> *)response{
    BOOL isDelete = NO;
    for (JLImageDate *date in response) {
        isDelete = [JLFileTool deleteFileWithUrl:date.url];
        if (isDelete) {
            //
            isDelete = [[DataManager shareInstance] deleteWithID:date.url];
            if (isDelete==NO) {
                break;
            }else{
                isDelete = YES;
            }
        }else{
            break;//删除一条失败就跳出循环，防止死循环，减少不了缓存就一直循环检测
        }
    }
    if (isDelete) {
        //删除完数据检查总文件大小是否超过超出范围，超出的话就5条删除最旧的，直到达标为止
        [self checkTotalSizeOfImage];
    }
}

- (void)checkTotalSizeOfImage{
    double totalFileSize = [JLFileTool countFileSizeWithPath:[JLFileTool getCachePath]]/(1024.0 * 1024.0);
    if (totalFileSize > 50.0) {//大于50M就需要删除一些了
        [[DataManager shareInstance] selectExpirationDataOrderByTimeWithLimit:5 response:^(NSArray<JLImageDate *> *response) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self handleData:response];
            });
        }];
    }else{
        NSLog(@"达标了");
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self]; //移除通知
}

@end
