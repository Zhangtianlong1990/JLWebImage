//
//  UIImageView+JLWebCache.m
//  
//
//  Created by 张天龙 on 17/3/6.
//  Copyright © 2017年. All rights reserved.
//

#import "UIImageView+JLWebCache.h"
#import "JLWebImageManager.h"
#import "JLWebImageMemory.h"
#import "JLWebImageDisk.h"
#import "JLWebImageDownloader.h"
#import "JLThreadTool.h"
#import <objc/runtime.h>

static char loadingURLKey;

@interface UIImageView ()
/**
 正在下载的图片地址
 */
@property (nonatomic,copy) NSString *loadingURL;
@end

@implementation UIImageView (JLWebCache)

- (void)setLoadingURL:(NSString *)loadingURL{
    objc_setAssociatedObject(self, &loadingURLKey, loadingURL, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)loadingURL{
    return objc_getAssociatedObject(self, &loadingURLKey);
}

#pragma mark - JLWebImageViewInterface

- (void)cb_setImage:(UIImage *)image url:(NSString *)url{
    [JLThreadTool asyncMainThread:^{
        if ([self.loadingURL isEqualToString:url]) {
            self.image = image;
        }
    }];
}

- (void)jl_setImageWithURL:(NSString *)url placeholderImage:(UIImage *)placeholderImage{
    NSAssert(url != nil, @"url is nil!");
    
    JLWebImageManager *manager = [JLWebImageManager sharedWebImageManager];
    if (!manager.memory) {
        manager.memory = [[JLWebImageMemory alloc] init];
    }
    
    if (!manager.disk) {
        manager.disk = [[JLWebImageDisk alloc] init];
    }
    
    if (!manager.downloader) {
        manager.downloader = [[JLWebImageDownloader alloc] init];
    }
    
    self.loadingURL = url;
    
    [JLThreadTool asyncGlobalQueue:^{
        [[JLWebImageManager sharedWebImageManager] setImageView:self url:[url copy] placeholderImage:placeholderImage];
    }];
    
}

@end
