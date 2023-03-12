//
//  JLWebCacheManger.m
//  
//
//  Created by 张天龙 on 17/3/6.
//  Copyright © 2017年. All rights reserved.
//

#import "JLWebImageManager.h"
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
    [self.db checkExpiredImageCache];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self]; //移除通知
}

@end
