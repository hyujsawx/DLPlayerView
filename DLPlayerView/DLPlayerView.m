//
//  DLPlayerView.m
//  DLPlayerView
//
//  Created by 丽丽 on 2017/7/10.
//  Copyright © 2017年 konggeek. All rights reserved.
//

#import "DLPlayerView.h"
#import "UIView+Category.h"
#import <MediaPlayer/MediaPlayer.h>

#define SCREEN_WIDTH    [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT   [UIScreen mainScreen].bounds.size.height
//音量/亮度调节速度
#define VolumeStep 0.02f
#define BrightnessStep 0.02f
//功能界面隐藏的时间
#define PerformCount  80

@interface DLPlayerView ()<PlayerSliderDelegate>

@property (nonatomic,assign)BOOL isAllScreen;//是否全屏
@property (nonatomic,assign)BOOL showFuncBtns;//显示功能按钮
@property (nonatomic,assign)CGRect myFrame;//保存frame
@property (nonatomic,assign)CGPoint originalLocation;//滑动手势
@property (nonatomic,strong)UIView *bottonFuncView;//底部黑色
@property (nonatomic,strong)UIButton *backBtn;//返回按钮
@property (nonatomic,strong)UIImageView *brightnessView;//亮度
@property (nonatomic,strong)UIProgressView *brightnessProgress;//亮度
@property (nonatomic, strong)UIActivityIndicatorView *activityIndicator;//直播缓冲等待
@property (nonatomic,strong)UIButton *screenBtn;//全屏幕按钮
@property (nonatomic,strong)UIButton *pausebtn;//暂停按钮
@property (nonatomic,strong)UILabel *leftTimeLabel;//当前播放时间
@property (nonatomic,strong)UILabel *rightTimeLabel;//总时间
@property (nonatomic,strong)PlayerProgressView *playerProgressView;//播放进度条
@property (nonatomic,strong)NSTimer *hiddenTimer;
@property (nonatomic,assign)NSInteger leftHiddenCount;//timer方法用来隐藏工具条

@end

@implementation DLPlayerView

- (instancetype)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor blackColor];
        self.myFrame = frame;
        
        self.playerView = [[UIView alloc]init];
        self.playerView.backgroundColor = [UIColor clearColor];
        [self addSubview:self.playerView];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showFuncView:)];
        [self addGestureRecognizer:tap];
        
        self.backBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 20, 50, 40)];
        [self.backBtn setImage:[UIImage imageNamed:@"ic_normal_backBG"] forState:UIControlStateNormal];
        [self.backBtn addTarget:self action:@selector(backBtnFunc) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.backBtn];
        
        self.bottonFuncView = [[UIView alloc]init];
        self.bottonFuncView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        [self addSubview:self.bottonFuncView];
        
        self.screenBtn = [[UIButton alloc]init];
        [self.screenBtn setImage:[UIImage imageNamed:@"ic_hl_liveSxreen"] forState:UIControlStateNormal];
        [self.screenBtn addTarget:self action:@selector(screenBtnFunc) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.screenBtn];
        
        self.pausebtn = [[UIButton alloc]init];
        [self.pausebtn addTarget:self action:@selector(pausebtnFunc) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.pausebtn];
        self.isPause = NO;
        
        self.leftTimeLabel = [[UILabel alloc]init];
        self.leftTimeLabel.textColor = [UIColor whiteColor];
        self.leftTimeLabel.font = [UIFont systemFontOfSize:10];
        self.leftTimeLabel.text = @"00:00";
        self.leftTimeLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.leftTimeLabel];
        
        self.rightTimeLabel = [[UILabel alloc]init];
        self.rightTimeLabel.textColor = [UIColor whiteColor];
        self.rightTimeLabel.font = [UIFont systemFontOfSize:10];
        self.rightTimeLabel.text = @"00:00";
        self.rightTimeLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.rightTimeLabel];
        
        self.playerProgressView = [[PlayerProgressView alloc] init];
        [self.playerProgressView setDelegate:self];
        [self addSubview:self.playerProgressView];
        
        self.brightnessView = [[UIImageView alloc]init];
        self.brightnessView.image = [UIImage imageNamed:@"video_brightness_bg.png"];
        self.brightnessProgress = [[UIProgressView alloc]initWithFrame:CGRectMake(22.5, 100, 80, 10)];
        self.brightnessProgress.trackImage = [UIImage imageNamed:@"video_num_bg.png"];
        self.brightnessProgress.progressImage = [UIImage imageNamed:@"video_num_front.png"];
        self.brightnessProgress.progress = [UIScreen mainScreen].brightness;
        [self.brightnessView addSubview:self.brightnessProgress];
        [self addSubview:self.brightnessView];
        self.brightnessView.alpha = 0;
        
        self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        self.activityIndicator.hidesWhenStopped = YES;
        [self addSubview:self.activityIndicator];
        self.showLoading = NO;
        
        [self showFuncView:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(layoutSubviews) name:UIDeviceOrientationDidChangeNotification object:nil];
        
    }
    return self;
    
}

#pragma mark setFunc

- (void)setPlayerView:(UIView *)playerView {
    _playerView = playerView;
    
    [self addSubview:self.playerView];
    [self sendSubviewToBack:self.playerView];
    [self layoutSubviews];
}

- (void)setShowLoading:(BOOL)showLoading {
    _showLoading = showLoading;
    
    if (showLoading) {
        [self.activityIndicator startAnimating];
        self.activityIndicator.hidden = NO;
    }else {
        [self.activityIndicator stopAnimating];
        self.activityIndicator.hidden = YES;
    }
}

- (void)setCurrentDuration:(NSInteger)currentDuration {
    _currentDuration = currentDuration;
    
    self.leftTimeLabel.text = [self getVideoTimeStringFromCount:currentDuration];
    [self.playerProgressView setCurrentProgress:self.currentDuration/self.allDuration];
}

- (void)setLoadedDuration:(NSInteger)loadedDuration {
    _loadedDuration = loadedDuration;
    
    [self.playerProgressView setLoadedProgress:self.loadedDuration/self.allDuration];
}

- (void)setAllDuration:(CGFloat)allDuration {
    _allDuration = allDuration;
    
     self.rightTimeLabel.text = [self getVideoTimeStringFromCount:allDuration];
    [self.playerProgressView setCurrentProgress:self.currentDuration/self.allDuration];
    [self.playerProgressView setLoadedProgress:self.loadedDuration/self.allDuration];
}

- (void)setIsPause:(BOOL)isPause {
    _isPause = isPause;
    
    if (isPause) {
        [self.pausebtn setImage:[UIImage imageNamed:@"ic_hl_liveStart"] forState:UIControlStateNormal];
    }else {
        [self.pausebtn setImage:[UIImage imageNamed:@"ic_hl_livePause"] forState:UIControlStateNormal];
    }
}

#pragma mark views

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (SCREEN_WIDTH > SCREEN_HEIGHT) {
        self.isAllScreen = YES;
        self.frame = [UIScreen mainScreen].bounds;
    }else {
        self.isAllScreen = NO;
        self.frame = self.myFrame;
    }
    
    [self initViews];
}

- (void)initViews {
    self.playerView.frame = self.frame;
    self.bottonFuncView.frame = CGRectMake(0, self.getHeight-40, self.getWidth, 40);
    self.pausebtn.frame = CGRectMake(0, self.getMaxY-40, 50, 40);
    self.screenBtn.frame = CGRectMake(self.getMaxX-50, self.getMaxY-40, 50, 40);
    self.leftTimeLabel.frame = CGRectMake(35, self.getHeight-40, 50, 40);
    self.rightTimeLabel.frame = CGRectMake(self.getWidth-85, self.getHeight-40, 50, 40);
    self.playerProgressView.frame = CGRectMake(80, self.getMaxY-40, self.getWidth-160, 40);
    self.brightnessView.frame = CGRectMake(SCREEN_WIDTH/2-62.5, SCREEN_HEIGHT/2-62.5, 125, 125);
    self.activityIndicator.frame = CGRectMake(self.getWidth/2-15, self.getHeight/2-15, 30, 30);
}

#pragma mark actions

- (void)backBtnFunc {
    [self startToHidden];
    if (self.isAllScreen) {
        NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
        [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
        return;
    }
    if (self.backAction) {
        self.backAction();
    }
}

- (void)screenBtnFunc {
    [self startToHidden];
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationLandscapeRight];
    if (self.isAllScreen) {
        value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
    }
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
}

- (void)pausebtnFunc {
    [self startToHidden];
    self.isPause = !self.isPause;
    if (self.pauseAction) {
        self.pauseAction(self.isPause);
    }
}

- (void)showFuncView:(UITapGestureRecognizer *)tap {
    if (self.brightnessView.alpha) {
        [UIView animateWithDuration:1 animations:^{
            self.brightnessView.alpha = 0;
        }];
    }
    self.bottonFuncView.hidden = self.showFuncBtns;
    self.playerProgressView.hidden = self.showFuncBtns;
    self.backBtn.hidden = self.showFuncBtns;
    self.pausebtn.hidden = self.showFuncBtns;
    self.screenBtn.hidden = self.showFuncBtns;
    self.leftTimeLabel.hidden = self.showFuncBtns;
    self.rightTimeLabel.hidden = self.showFuncBtns;
    self.showFuncBtns = !self.showFuncBtns;
    if (self.showFuncBtns) {
        [self startToHidden];
    }
}

- (void)startToHidden {
    if (self.leftHiddenCount <= 0) {
        self.hiddenTimer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(timerFunc) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:self.hiddenTimer forMode:NSRunLoopCommonModes];
        self.leftHiddenCount = PerformCount;
    }else {
        self.leftHiddenCount = PerformCount;
    }
}

- (void)timerFunc {
    self.leftHiddenCount --;
    if (self.leftHiddenCount <= 0) {
        [self.hiddenTimer invalidate];
        self.hiddenTimer = nil;
        self.bottonFuncView.hidden = YES;
        self.playerProgressView.hidden = YES;
        self.backBtn.hidden = YES;
        self.pausebtn.hidden = YES;
        self.screenBtn.hidden = YES;
        self.leftTimeLabel.hidden = YES;
        self.rightTimeLabel.hidden = YES;
        self.showFuncBtns = NO;
    }
}

#pragma mark PlayerSliderDelegate

- (void)onSliderValueChanged:(float)value {
    [self startToHidden];
    self.currentDuration = self.allDuration*value;
    if (self.seekToAction) {
        self.seekToAction(self.currentDuration);
    }
}

#pragma mark touches

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint currentLocation = [touch locationInView:self];
    CGFloat offset_x = currentLocation.x - self.originalLocation.x;
    CGFloat offset_y = currentLocation.y - self.originalLocation.y;
    if (CGPointEqualToPoint(self.originalLocation,CGPointZero)) {
        self.originalLocation = currentLocation;
        return;
    }
    self.originalLocation = currentLocation;
    CGFloat width = self.frame.size.width;
    if ( (currentLocation.x > width*0.5) && (ABS(offset_x) <= ABS(offset_y))){
        //右边音量
        if (offset_y > 0){
            [self volumeAdd:-VolumeStep];
        }else{
            [self volumeAdd:VolumeStep];
        }
    }else if ( (currentLocation.x < width*0.5) && (ABS(offset_x) <= ABS(offset_y))){
        //左边亮度
        if (offset_y > 0) {
            self.brightnessView.alpha = 1;
            [self brightnessAdd:-BrightnessStep];
        }else{
            self.brightnessView.alpha = 1;
            [self brightnessAdd:BrightnessStep];
        }
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    if (self.brightnessView.alpha) {
        [UIView animateWithDuration:1 animations:^{
            self.brightnessView.alpha = 0;
        }];
    }
}

#pragma mark private

- (void)liveViewHiddenProgress {
    [self.leftTimeLabel removeFromSuperview];
    [self.rightTimeLabel removeFromSuperview];
    [self.playerProgressView removeFromSuperview];
}

- (void)volumeAdd:(CGFloat)step{
    [MPMusicPlayerController applicationMusicPlayer].volume += step;
}

- (void)brightnessAdd:(CGFloat)step{
    [UIScreen mainScreen].brightness += step;
    self.brightnessProgress.progress = [UIScreen mainScreen].brightness;
}

- (NSString *)getVideoTimeStringFromCount:(NSInteger)count {
    NSString *backStr = @"";
    if (count < 0) {
        return @"00:00";
    }
    NSInteger count1 = count/3600;
    NSInteger count2 = (count-count1*3600)/60;
    NSInteger count3 = count%60;
    if (count1 >0) {
        backStr = [[backStr stringByAppendingFormat:@"%ld",(long)count1] stringByAppendingString:@":"];
    }
    if (count2<10) {
        backStr = [backStr stringByAppendingString:@"0"];
    }
    backStr = [[backStr stringByAppendingFormat:@"%ld",(long)count2] stringByAppendingString:@":"];
    if (count3<10) {
        backStr = [backStr stringByAppendingString:@"0"];
    }
    backStr = [backStr stringByAppendingFormat:@"%ld",(long)count3];
    return backStr;
}

@end











