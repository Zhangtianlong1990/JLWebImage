//
//  JLWebImageContact.h
//  JLWebImage
//
//  Created by 张天龙 on 2023/3/11.
//  Copyright © 2023 张天龙. All rights reserved.
//

#ifndef JLWebImageContact_h
#define JLWebImageContact_h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol JLWebImageViewInterface <NSObject>

- (NSString *)cb_getLoadingURL;
- (void)cb_setImage:(UIImage *)image;
- (void)cb_setLoadingURL:(NSString *)loadingURL;

@end

@protocol JLWebImageMemoryInterface <NSObject>
- (void)setupImageCache:(UIImage *)aImage withKey:(NSString *)aKey;
- (UIImage *)getImageCacheWithKey:(NSString *)aKey;
- (void)clearMemories;
@end

@protocol JLWebImageDiskInterface <NSObject>
- (UIImage *)getDiskCacheWithURL:(NSString *)url;
- (BOOL)setupDiskCache:(NSData *)aImageData withURL:(NSString *)url;
@end

@class JLWebImageOperation;
@protocol JLWebImageDownloaderInterface <NSObject>
- (void)downloadImage:(id<JLWebImageViewInterface>)imageView url:(NSString *)url;
- (void)addOperationToQueue:(JLWebImageOperation *)aOperation;
- (void)setOperationCacheWithKey:(JLWebImageOperation *)aOperation withKey:(NSString *)aKey;
- (JLWebImageOperation *)getOperationCacheWithKey:(NSString *)aKey;
- (void)removeOperationCacheWithKey:(NSString *)aKey;
@end

#endif /* JLWebImageContact_h */
