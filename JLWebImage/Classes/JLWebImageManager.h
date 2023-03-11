//
//  JLWebCacheManger.h
//
//
//  Created by 张天龙 on 17/3/6.
//  Copyright © 2017年. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "JLSingleton.h"
#import "JLWebImageContact.h"

@interface JLWebImageManager<T: NSOperation *> : NSObject
@property (nonatomic,strong) id<JLWebImageMemoryInterface> memory;
@property (nonatomic,strong) id<JLWebImageDiskInterface> disk;
JLSingletonH(WebImageManager)
- (void)setImageView:(id<JLWebImageViewInterface>)imageView url:(NSString *)url placeholderImage:(NSString *)placeholderImage;
- (void)addOperationToQueue:(T)aOperation;
- (void)setOperationCacheWithKey:(T)aOperation withKey:(NSString *)aKey;
- (T)getOperationCacheWithKey:(NSString *)aKey;
- (void)removeOperationCacheWithKey:(NSString *)aKey;
/**
 清除图片缓存
 */
- (void)clearMemories;

@end
