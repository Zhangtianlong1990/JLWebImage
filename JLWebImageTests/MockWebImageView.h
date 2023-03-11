//
//  MockWebImageView.h
//  JLWebImageTests
//
//  Created by 张天龙 on 2023/3/12.
//  Copyright © 2023 张天龙. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JLWebImageContact.h"
#import <UIKit/UIKit.h>

@interface MockWebImageView : NSObject<JLWebImageViewInterface>
@property (nonatomic,strong) UIImage *image;
@end


