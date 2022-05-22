//
//  DataManager.h
//  FMDBDemo
//
//  Created by 张天龙 on 2021/1/24.
//  Copyright © 2021 张天龙. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDB.h"
#import "JLImageDate.h"


@interface DataManager : NSObject
+ (instancetype)shareInstance;
- (void)insertDataWithKey:(NSString *)aKey timeInterval:(NSTimeInterval)timeInterval;
- (void)selectExpirationData:(void(^)(NSArray<JLImageDate *> *))response;
- (void)selectExpirationDataOrderByTimeWithLimit:(NSInteger)limit response:(void (^)(NSArray<JLImageDate *> *))response;
- (BOOL)deleteWithID:(NSString *)ID;
@end

