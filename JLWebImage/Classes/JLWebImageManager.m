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
@property(nonatomic, strong) dispatch_queue_t operationQueue;
@end

@implementation JLWebImageManager

JLSingletonM(WebImageManager)

- (instancetype)init
{
    self = [super init];
    if (self) {
        _operationQueue = dispatch_queue_create("com.operation.safequeue", DISPATCH_QUEUE_CONCURRENT);
        _operations = [NSMutableDictionary dictionary];
        _queue = [[NSOperationQueue alloc] init];
        [self setupAppLifecycleNotification];
    }
    return self;
}

- (void)setImageView:(id<JLWebImageViewInterface>)imageView url:(NSString *)url placeholderImage:(NSString *)placeholderImage{
    // 1.0 如果此imageView正在下载图片就取消
    NSString *loadingURL = nil;
    if ([imageView respondsToSelector:@selector(cb_getLoadingURL)] && imageView) {
        loadingURL = [imageView cb_getLoadingURL];
    }
    if (loadingURL) {
        NSOperation *operation = [self getOperationCacheWithKey:loadingURL];
        [operation cancel];
    }
    
    // 2.0 先从内存缓存中取出图片
    UIImage *image = nil;
    if (self.memory) {
        [self.memory getImageCacheWithKey:url];
    }
    
    if (image) { //2.1 内存中有图片
        
        if (imageView && [imageView respondsToSelector:@selector(cb_setImage:)]) {
            [imageView cb_setImage:image];
        }
        
    }else{//2.2 内存中没有图片
        
        //2.2.1 获得Library/Caches文件夹
        NSString *cachesPath = [JLFileTool getCachePath];
        
        //2.2.2 获得文件名
        NSString *filename = [url lastPathComponent];
        
        //2.2.3 计算出文件的全路径
        NSString *file = [cachesPath stringByAppendingPathComponent:filename];
        
        //2.2.4 加载沙盒的文件数据
        NSData *data = [NSData dataWithContentsOfFile:file];
        
        if (data) { //2.2.4.1 直接利用沙盒中图片
            
            UIImage *image = [UIImage imageWithData:data];
            if (imageView && [imageView respondsToSelector:@selector(cb_setImage:)]) {
                [imageView cb_setImage:image];
            }
            if (self.memory) {
                [self.memory setupImageCache:image withKey:url];
            }
            
        }else { //2.2.4.2  下载图片
    
            if (imageView && [imageView respondsToSelector:@selector(cb_setImage:)]) {
                [imageView cb_setImage:[UIImage imageNamed:placeholderImage]];
            }
            JLWebImageOperation *operation = [self getOperationCacheWithKey:url];
            
            if (operation == nil) { // 这张图片暂时没有下载任务
                
                //a. 正在下载这张图片
                if (imageView && [imageView respondsToSelector:@selector(cb_setLoadingURL:)]) {
                    [imageView cb_setLoadingURL:url];
                }
                
                //b. 创建下载任务
                operation = [[JLWebImageOperation alloc] init];
                operation.url = url;
                operation.img = imageView;
                operation.file = file;
                
                //c. 添加到队列中
                [self addOperationToQueue:operation];
                //d. 存放到字典中
                [self setOperationCacheWithKey:operation withKey:url];
                
            }
        
        }
        
    }
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
    dispatch_sync(_operationQueue, ^{
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
