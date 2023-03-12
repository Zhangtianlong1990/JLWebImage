//
//  ViewController.m
//  JLWebImage
//
//  Created by 张天龙 on 17/3/10.
//  Copyright © 2017年 张天龙. All rights reserved.
//

#import "ViewController.h"
#import "JLApp.h"
#import "UIImageView+JLWebCache.h"
#import "DataManager.h"

@interface ViewController ()

/** 所有数据 */
@property (nonatomic, strong) NSArray *apps;

@end

@implementation ViewController

- (NSArray *)apps
{
    if (!_apps) {
        NSArray *dictArray = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"apps.plist" ofType:nil]];
        
        NSMutableArray *appArray = [NSMutableArray array];
        for (NSDictionary *dict in dictArray) {
            [appArray addObject:[JLApp appWithDict:dict]];
        }
        _apps = appArray;
    }
    return _apps;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [DataManager shareInstance];
    // Do any additional setup after loading the view, typically from a nib.
}

#pragma mark - 数据源方法

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.apps.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ID = @"app";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(250, 10, 50, 50)];
        imageView.tag = 100;
        imageView.backgroundColor = [UIColor redColor];
        [cell.contentView addSubview:imageView];
        
    }
    
    JLApp *app = self.apps[indexPath.row];
    cell.textLabel.text = app.name;
    cell.detailTextLabel.text = app.download;
    UIImageView *view = (UIImageView *)[cell viewWithTag:100];
    [view jl_setImageWithURL:app.icon placeholderImage:[UIImage imageNamed:@"placeholder"]];
    
    return cell;
}


@end
