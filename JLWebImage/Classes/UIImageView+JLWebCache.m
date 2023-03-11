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

- (NSString *)cb_getLoadingURL{
    return self.loadingURL;
}

- (void)cb_setLoadingURL:(NSString *)loadingURL{
    self.loadingURL = loadingURL;
}

- (void)cb_setImage:(UIImage *)image{
    self.image = image;
}

- (void)jl_setImageWithURL:(NSString *)url placeholderImage:(NSString *)placeholderImage{
    JLWebImageMemory *memory = [[JLWebImageMemory alloc] init];
    [JLWebImageManager sharedWebImageManager].memory = memory;
    [[JLWebImageManager sharedWebImageManager] setImageView:self url:url placeholderImage:placeholderImage];
    
}

@end
