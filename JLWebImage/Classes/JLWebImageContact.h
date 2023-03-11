//
//  JLWebImageContact.h
//  JLWebImage
//
//  Created by 张天龙 on 2023/3/11.
//  Copyright © 2023 张天龙. All rights reserved.
//

#ifndef JLWebImageContact_h
#define JLWebImageContact_h

@protocol JLWebImageViewInterface <NSObject>

- (NSString *)jl_getLoadingURL;
- (void)jl_setImage:(UIImage *)image;
- (void)jl_setLoadingURL:(NSString *)loadingURL;

@end

#endif /* JLWebImageContact_h */
