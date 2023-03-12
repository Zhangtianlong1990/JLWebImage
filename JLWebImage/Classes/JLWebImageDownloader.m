//
//  JLWebImageDownloader.m
//  JLWebImage
//
//  Created by 张天龙 on 2023/3/12.
//  Copyright © 2023 张天龙. All rights reserved.
//

#import "JLWebImageDownloader.h"
#import "JLWebImageOperation.h"

@interface JLWebImageDownloader ()
/**
 所有的操作对象
 */
@property (nonatomic, strong) NSMutableDictionary *operations;
/**
 队列对象
 */
@property (nonatomic, strong) NSOperationQueue *queue;
@property(nonatomic, strong) dispatch_queue_t operationQueue;
@end

@implementation JLWebImageDownloader

- (instancetype)init
{
    self = [super init];
    if (self) {
        _operationQueue = dispatch_queue_create("com.operation.safequeue", DISPATCH_QUEUE_CONCURRENT);
        _operations = [NSMutableDictionary dictionary];
        _queue = [[NSOperationQueue alloc] init];
    }
    return self;
}

- (void)downloadImage:(id<JLWebImageViewInterface>)imageView url:(NSString *)url{
    
    NSAssert(imageView != nil, @"imageView is nil!");
    NSAssert(url != nil, @"url is nil!");
    
    JLWebImageOperation *operation = [self getOperationCacheWithKey:url];
    
    if (operation == nil) { // 这张图片暂时没有下载任务
        
        //a. 正在下载这张图片
        [imageView cb_setLoadingURL:url];
        
        //b. 创建下载任务
        operation = [[JLWebImageOperation alloc] init];
        operation.url = url;
        operation.img = imageView;
        
        //c. 添加到队列中
        [self addOperationToQueue:operation];
        //d. 存放到字典中
        [self setOperationCacheWithKey:operation withKey:url];
        
    }
}
- (void)addOperationToQueue:(JLWebImageOperation *)aOperation{
    [self.queue addOperation:aOperation];
}

- (void)setOperationCacheWithKey:(JLWebImageOperation *)aOperation withKey:(NSString *)aKey{
    if (!aKey) return;
    dispatch_barrier_async(_operationQueue, ^{
        self.operations[aKey] = aOperation;
    });
}

- (JLWebImageOperation *)getOperationCacheWithKey:(NSString *)aKey{
    __block JLWebImageOperation *operation = nil;
    if (!aKey) return operation;
    dispatch_sync(_operationQueue, ^{
        operation = self.operations[aKey];
    });
    return operation;
}

- (void)removeOperationCacheWithKey:(NSString *)aKey{
    if(!aKey) return;
    dispatch_barrier_async(_operationQueue, ^{
        [self.operations removeObjectForKey:aKey];
    });
}
@end
