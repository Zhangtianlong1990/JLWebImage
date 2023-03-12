//
//  JLWebImageDB.m
//  JLWebImage
//
//  Created by 张天龙 on 2023/3/12.
//  Copyright © 2023 张天龙. All rights reserved.
//

#import "JLWebImageDB.h"
#import "JLFileTool.h"
#import "DataManager.h"

@implementation JLWebImageDB

- (void)insertDataWithKey:(NSString *)aKey timeInterval:(NSTimeInterval)timeInterval{
    [[DataManager shareInstance] insertDataWithKey:aKey timeInterval:timeInterval];
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

@end
