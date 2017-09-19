//
//  DLPlayerView.h
//  DLPlayerView
//
//  Created by 丽丽 on 2017/7/10.
//  Copyright © 2017年 konggeek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlayerProgressView.h"

typedef void(^NormalBlock)();
typedef void(^IntegetBlock)(NSInteger integer);
typedef void(^BoolBlock)(BOOL isBool);

@interface DLPlayerView : UIView

@property (nonatomic,assign)BOOL isPause;//是否暂停
@property (nonatomic,assign)BOOL showLoading;//显示加载
@property (nonatomic,assign)NSInteger currentDuration;//当前播放时间，单位秒
@property (nonatomic,assign)NSInteger loadedDuration;//视频已经加载的时间，单位秒
@property (nonatomic,assign)CGFloat allDuration;//播放总时间，单位秒
@property (nonatomic,strong)UIView *playerView;//播放器视图

@property (nonatomic,strong)NormalBlock backAction;//返回
@property (nonatomic,strong)BoolBlock pauseAction;//暂停
@property (nonatomic,strong)IntegetBlock seekToAction;//跳转到播放进度

@end
