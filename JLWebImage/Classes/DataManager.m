//
//  DataManager.m
//  FMDBDemo
//
//  Created by 张天龙 on 2021/1/24.
//  Copyright © 2021 张天龙. All rights reserved.
//

#import "DataManager.h"
#import "JLImageDate.h"

@interface DataManager()
@property(nonatomic,strong)FMDatabaseQueue *dataBaseQ;
@end

@implementation DataManager

+ (instancetype)shareInstance{
    static DataManager *single = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!single) {
            single = [[DataManager alloc] init];
        }
    });
    return single;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self creatDatabase];
    }
    return self;
}

- (void)creatDatabase{
    NSString *docuPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *dbPath = [docuPath stringByAppendingPathComponent:@"JLImageDB.db"];
    NSLog(@"dbPath=%@",dbPath);
    _dataBaseQ = [FMDatabaseQueue databaseQueueWithPath:dbPath];
    
    [_dataBaseQ inDatabase:^(FMDatabase * _Nonnull db) {
        
        if (![db open]) {
            NSLog(@"db open fail");
            return;
        }
        //4.数据库中创建表（可创建多张）
        NSString *sql = @"create table if not exists t_image ('ID' TEXT PRIMARY KEY,'time' REAL NOT NULL)";
        //5.执行更新操作 此处database直接操作，不考虑多线程问题，多线程问题，用FMDatabaseQueue 每次数据库操作之后都会返回bool数值，YES，表示success，NO，表示fail,可以通过 @see lastError @see lastErrorCode @see lastErrorMessage
        BOOL result = [db executeUpdate:sql];
        if (result) {
            NSLog(@"create table success");
            
        }
        [db close];
    }];
    
}

- (void)insertDataWithKey:(NSString *)aKey timeInterval:(NSTimeInterval)timeInterval{
    
    [_dataBaseQ inDatabase:^(FMDatabase * _Nonnull db) {

        if (![db open]) {
            NSLog(@"db open fail");
            return;
        }
        NSMutableArray *insertArr = [NSMutableArray array];
        [insertArr addObject:aKey];
        [insertArr addObject:[NSNumber numberWithDouble:timeInterval]];
        BOOL result = [db executeUpdate:@"insert or ignore into t_image(ID,time) values(?,?)" withArgumentsInArray:insertArr];
        if (result) {
//            NSLog(@"insert into 't_studet' %d success,%@",model.ID,[NSThread currentThread]);
        } else {
            NSLog(@"insert into 't_studet' faild");
        }
        [db close];
    }];
    
}
- (void)selectExpirationData:(void (^)(NSArray<JLImageDate *> *))response{
    
    NSTimeInterval nowTime = [[NSDate date] timeIntervalSince1970];
    NSTimeInterval intervalTime = 60 * 60 * 24 * 7;//超过七天删除
//    intervalTime = 10;
    NSTimeInterval compareTime = nowTime - intervalTime;
    NSMutableArray *selectArray = [NSMutableArray array];
    [_dataBaseQ inDatabase:^(FMDatabase * _Nonnull db) {
        if (![db open]) {
            NSLog(@"db open fail");
            return;
        }
        FMResultSet *result = [db executeQuery:@"select * from t_image where time < ?" withArgumentsInArray:@[@(compareTime)]];;
        
        while ([result next]) {
            JLImageDate *model = [[JLImageDate alloc] init];
            model.url = [result stringForColumn:@"ID"];
            model.timeInterval = [result doubleForColumn:@"time"];
            [selectArray addObject:model];
//            NSLog(@"从数据库查询到的人员 %d,%@",model.ID,[NSThread currentThread]);
        }
        [db close];
        response(selectArray);
    }];
    
}

- (void)deleteWithID:(NSString *)ID{
    
    [_dataBaseQ inDatabase:^(FMDatabase * _Nonnull db) {
        if (![db open]) {
            NSLog(@"db open fail");
            return;
        }
        
        BOOL result = [db executeUpdate:@"delete from t_image where ID = ?" withArgumentsInArray:@[ID]];
        
        if (result) {
            NSLog(@"数据%@删除成功",ID);
        } else {
            NSLog(@"数据%@删除失败",ID);
        }
        [db close];
    }];
    

}


@end
