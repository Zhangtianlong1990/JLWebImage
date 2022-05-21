//
//  NSString+Extension.m
//  JLWebImage
//
//  Created by 张天龙 on 2022/5/21.
//  Copyright © 2022 张天龙. All rights reserved.
//

#import "NSString+Extension.h"

@implementation NSString (Extension)
- (NSInteger)fileSize{
      //文件管理者
      NSFileManager *mgr = [NSFileManager defaultManager];
      //判断字符串是否为文件/文件夹
      BOOL dir = NO;
      BOOL exists = [mgr fileExistsAtPath:self isDirectory:&dir];
      //文件/文件夹不存在
      if (exists == NO) return 0;
      //self是文件夹
     if (dir){
          //遍历文件夹中的所有内容
          NSArray *subpaths = [mgr subpathsAtPath:self];
          //计算文件夹大小
          NSInteger totalByteSize = 0;
          for (NSString *subpath in subpaths){
               //拼接全路径
                NSString *fullSubPath = [self stringByAppendingPathComponent:subpath];
             //判断是否为文件
             BOOL dir = NO;
             [mgr fileExistsAtPath:fullSubPath isDirectory:&dir];
             if (dir == NO){//是文件
                    NSDictionary *attr = [mgr attributesOfItemAtPath:fullSubPath error:nil];
                   totalByteSize += [attr[NSFileSize] integerValue];
              }
          }
          return totalByteSize;
     } else{//是文件
           NSDictionary *attr = [mgr attributesOfItemAtPath:self error:nil];
            return [attr[NSFileSize] integerValue];
    }
 }
@end
