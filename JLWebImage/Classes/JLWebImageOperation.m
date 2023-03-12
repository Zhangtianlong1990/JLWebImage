//
//  JLOperation.m
//  
//
//  Created by 张天龙 on 17/3/10.
//  Copyright © 2017年. All rights reserved.
//

#import "JLWebImageOperation.h"
#import "JLWebImageManager.h"
#import "DataManager.h"
#import "JLThreadTool.h"

@implementation JLWebImageOperation

- (void)main{
    
    @autoreleasepool {
        
        JLWebImageManager *manager = [JLWebImageManager sharedWebImageManager];
        
        // 1.0 下载图片
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:_url]];
        
        NSString *opKey = [NSString stringWithFormat:@"%@-%@",self.img.description,self.url];
        
        if (data == nil) {
            // 移除操作
            [manager.downloader removeOperationCacheWithKey:opKey];
            return;
            
        }
        
        // 3.0 存到字典中
        UIImage *image = [UIImage imageWithData:data];
        [manager.memory setupImageCache:image withKey:_url];
        
        // 4.0 回到主线程显示图片
        [_img cb_setImage:image url:_url];
        
        // 5.0 将图片文件数据写入沙盒中
        BOOL isWrite = [manager.disk setupDiskCache:data withURL:_url];
        
        if (isWrite) {
            NSTimeInterval timeInterval =  [[NSDate date] timeIntervalSince1970];
            [[DataManager shareInstance] insertDataWithKey:_url timeInterval:timeInterval];
        }
        
        // 6.0 移除操作
        // 移除操作
        [manager.downloader removeOperationCacheWithKey:opKey];
        
    }
    
}
@end
