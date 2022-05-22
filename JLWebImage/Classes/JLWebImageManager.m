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
        [self setupAppLifecycleNotification];
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
