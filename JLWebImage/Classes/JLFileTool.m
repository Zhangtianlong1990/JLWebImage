//
//  JLFileTool.m
//  JLWebImage
//
//  Created by 张天龙 on 2022/5/22.
//  Copyright © 2022 张天龙. All rights reserved.
//

#import "JLFileTool.h"

@implementation JLFileTool
+ (NSString *)getCachePath{
    
    //文件管理者
    NSFileManager *mgr = [NSFileManager defaultManager];
    //2.2.1 获得Library/Caches文件夹
    NSString *cachesPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    //2.2.3 计算出文件的全路径
    NSString *JLImageFolderPath = [cachesPath stringByAppendingPathComponent:@"JLImage"];
    //判断字符串是否为文件/文件夹
     BOOL dir = NO;
     BOOL exists = [mgr fileExistsAtPath:JLImageFolderPath isDirectory:&dir];
    
    if (exists == YES && dir == YES) {
        return JLImageFolderPath;
    }else{
        
        // 创建目录
        BOOL res=[mgr createDirectoryAtPath:JLImageFolderPath withIntermediateDirectories:YES attributes:nil error:nil];
        if (res) {
            NSLog(@"文件夹创建成功,JLImageFolderPath = %@",JLImageFolderPath);
            return JLImageFolderPath;
        }else{
            NSLog(@"文件夹创建失败");
            return nil;
        }
    
    }
    
}
+ (NSInteger)countFileSizeWithPath:(NSString *)aPath{
      //文件管理者
      NSFileManager *mgr = [NSFileManager defaultManager];
      //判断字符串是否为文件/文件夹
      BOOL dir = NO;
      BOOL exists = [mgr fileExistsAtPath:aPath isDirectory:&dir];
      //文件/文件夹不存在
      if (exists == NO) return 0;
      //self是文件夹
     if (dir){
          //遍历文件夹中的所有内容
          NSArray *subpaths = [mgr subpathsAtPath:aPath];
          //计算文件夹大小
          NSInteger totalByteSize = 0;
          for (NSString *subpath in subpaths){
               //拼接全路径
                NSString *fullSubPath = [aPath stringByAppendingPathComponent:subpath];
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
           NSDictionary *attr = [mgr attributesOfItemAtPath:aPath error:nil];
            return [attr[NSFileSize] integerValue];
    }
 }

+ (BOOL)isFileExistsAtPath:(NSString *)aPath{
    //文件管理者
    NSFileManager *mgr = [NSFileManager defaultManager];
    //判断字符串是否为文件/文件夹
    BOOL dir = NO;
    BOOL exists = [mgr fileExistsAtPath:aPath isDirectory:&dir];
    //文件/文件夹不存在
    return exists;
}

//删除文件
+ (BOOL)deleteFileWithUrl:(NSString *)aUrl{
    
    //2.2.1 获得Library/Caches文件夹
    NSString *cachesPath = [JLFileTool getCachePath];
    
    //2.2.2 获得文件名
    NSString *filename = [aUrl lastPathComponent];
    
    //2.2.3 计算出文件的全路径
    NSString *file = [cachesPath stringByAppendingPathComponent:filename];
    
    BOOL isExists = [JLFileTool isFileExistsAtPath:file];
    
    if (isExists==NO) return NO;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL res=[fileManager removeItemAtPath:file error:nil];
    if (res) {
        NSLog(@"%@: 文件删除成功",file);
    }else{
        NSLog(@"%@: 文件删除失败",file);
    }
    
    return res;
    
}

+ (NSString *)getFilePath: (NSString *)aUrl{
    //2.2.1 获得Library/Caches文件夹
    NSString *cachesPath = [JLFileTool getCachePath];
    
    //2.2.2 获得文件名
    NSString *filename = [aUrl lastPathComponent];
    
    //2.2.3 计算出文件的全路径
    NSString *filePath = [cachesPath stringByAppendingPathComponent:filename];
    
    return filePath;
}

@end
