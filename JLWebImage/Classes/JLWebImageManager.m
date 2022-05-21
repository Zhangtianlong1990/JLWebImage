//
//  JLWebCacheManger.m
//  
//
//  Created by 张天龙 on 17/3/6.
//  Copyright © 2017年. All rights reserved.
//

#import "JLWebImageManager.h"

@interface JLWebImageManager ()
/**
 内存缓存的图片
 */
@property (nonatomic, strong) NSMutableDictionary *images;
/**
 所有的操作对象
 */
@property (nonatomic, strong) NSMutableDictionary *operations;
/**
 队列对象
 */
@property (nonatomic, strong) NSOperationQueue *queue;

@end

@implementation JLWebImageManager

JLSingletonM(WebImageManager)

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (NSMutableDictionary *)images
{
    if (!_images) {
        _images = [NSMutableDictionary dictionary];
    }
    return _images;
}
- (NSMutableDictionary *)operations
{
    if (!_operations) {
        _operations = [NSMutableDictionary dictionary];
    }
    return _operations;
}
- (NSOperationQueue *)queue
{
    if (!_queue) {
        _queue = [[NSOperationQueue alloc] init];
    }
    return _queue;
}

- (void)setupImageCache:(UIImage *)aImage WithKey:(NSString *)aKey{
    self.images[aKey] = aImage;
}

- (UIImage *)getImageCacheWithKey:(NSString *)aKey{
    return self.images[aKey];
}

- (void)addOperationToQueue:(NSOperation *)aOperation{
    [self.queue addOperation:aOperation];
}

- (void)setOperationCacheWithKey:(NSOperation *)aOperation withKey:(NSString *)aKey{
    self.operations[aKey] = aOperation;
}

- (NSOperation *)getOperationCacheWithKey:(NSString *)aKey{
    return self.operations[aKey];
}

- (void)removeOperationCacheWithKey:(NSString *)aKey{
    [self.operations removeObjectForKey:aKey];
}


- (void)clearMemories{
    [self.images removeAllObjects];
}

@end
