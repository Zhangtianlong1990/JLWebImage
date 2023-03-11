//
//  JLWebImageTests.m
//  JLWebImageTests
//
//  Created by 张天龙 on 17/3/10.
//  Copyright © 2017年 张天龙. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "JLWebImageManager.h"
#import "MockWebImageView.h"
#import "MockWebImageMemory.h"

@interface JLWebImageTests : XCTestCase
@property (nonatomic,strong) JLWebImageManager *manager;
@end

@implementation JLWebImageTests

- (void)setUp {
//    [super setUp];
    self.manager = [JLWebImageManager sharedWebImageManager];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
//    [super tearDown];
}

- (void)testExample {
    
    UIImage *img = [[UIImage alloc] init];
    MockWebImageView *imageView = [[MockWebImageView alloc] init];
    MockWebImageMemory *memory = [[MockWebImageMemory alloc] init];
    memory.image = img;
    self.manager.memory = memory;
    [self.manager setImageView:imageView url:@"111" placeholderImage:@"222"];
    NSAssert(imageView.image == img, @"测试失败");
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

@end
