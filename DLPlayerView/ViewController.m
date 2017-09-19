//
//  ViewController.m
//  DLPlayerView
//
//  Created by 丽丽 on 2017/7/10.
//  Copyright © 2017年 konggeek. All rights reserved.
//

#import "ViewController.h"
#import "DLPlayerView.h"

#define SCREEN_WIDTH    [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT   [UIScreen mainScreen].bounds.size.height
#define LIVEVIEWHEIGHT  210*SCREEN_HEIGHT/667.0

@interface ViewController ()

@property (nonatomic,strong)DLPlayerView *playerView;

@end

@implementation ViewController

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    //显示加载
    self.playerView.showLoading = !self.playerView.showLoading;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];

    self.playerView = [[DLPlayerView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, LIVEVIEWHEIGHT)];
    [self.view addSubview:self.playerView];
    //当前时间
    self.playerView.currentDuration = 2475;
    //加载时间
    self.playerView.loadedDuration = 3500;
    //总时间
    self.playerView.allDuration = 5734;
    //显示加载
    self.playerView.showLoading = YES;
    
    self.playerView.backAction = ^{
        NSLog(@"返回了");
    };
    
    self.playerView.pauseAction = ^(BOOL isPause) {
        NSLog(@"%d",isPause);
    };
    
    self.playerView.seekToAction = ^(NSInteger integer) {
        NSLog(@"跳转到%ld秒",(long)integer);
    };
    
}




@end
