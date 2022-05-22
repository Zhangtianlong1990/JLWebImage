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
@property(nonatomic, strong) dispatch_queue_t imageQueue;
@property(nonatomic, strong) dispatch_queue_t operationQueue;
@end

@implementation JLWebImageManager

JLSingletonM(WebImageManager)

- (instancetype)init
{
    self = [super init];
    if (self) {
        _imageQueue = dispatch_queue_create("com.image.safequeue", DISPATCH_QUEUE_CONCURRENT);
        _operationQueue = dispatch_queue_create("com.operation.safequeue", DISPATCH_QUEUE_CONCURRENT);
        _images = [NSMutableDictionary dictionary];
        _operations = [NSMutableDictionary dictionary];
        _queue = [[NSOperationQueue alloc] init];
    }
    return self;
}

- (void)setupImageCache:(UIImage *)aImage WithKey:(NSString *)aKey{
    if (!aKey) return;
    dispatch_barrier_async(_imageQueue, ^{
        self.images[aKey] = aImage;
    });
}

- (UIImage *)getImageCacheWithKey:(NSString *)aKey{
    __block UIImage *image = nil;
    if (!aKey) return image;
    dispatch_sync(_imageQueue, ^{
        image = self.images[aKey];
    });
    return image;
}

- (void)addOperationToQueue:(NSOperation *)aOperation{
    [self.queue addOperation:aOperation];
}

- (void)setOperationCacheWithKey:(NSOperation *)aOperation withKey:(NSString *)aKey{
    if (!aKey) return;
    dispatch_barrier_async(_operationQueue, ^{
        self.operations[aKey] = aOperation;
    });
}

- (NSOperation *)getOperationCacheWithKey:(NSString *)aKey{
    __block NSOperation *operation = nil;
    if (!aKey) return operation;
    dispatch_sync(_imageQueue, ^{
        operation = self.operations[aKey];
    });
    return operation;
}

- (void)removeOperationCacheWithKey:(NSString *)aKey{
    if(!aKey) return;
    dispatch_sync(_operationQueue, ^{
        [self.operations removeObjectForKey:aKey];
    });
}


- (void)clearMemories{
    dispatch_sync(_imageQueue, ^{
        [self.images removeAllObjects];
    });
}

@end
