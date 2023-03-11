//
//  JLWebImageMemory.m
//  JLWebImage
//
//  Created by 张天龙 on 2023/3/11.
//  Copyright © 2023 张天龙. All rights reserved.
//

#import "JLWebImageMemory.h"

@interface JLWebImageMemory ()
@property (nonatomic, strong) NSMutableDictionary *images;
@property(nonatomic, strong) dispatch_queue_t imageQueue;
@end

@implementation JLWebImageMemory
- (instancetype)init
{
    self = [super init];
    if (self) {
        _imageQueue = dispatch_queue_create("com.image.safequeue", DISPATCH_QUEUE_CONCURRENT);
        _images = [NSMutableDictionary dictionary];
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
- (void)clearMemories{
    dispatch_barrier_async(_imageQueue, ^{
        [self.images removeAllObjects];
    });
}
@end
