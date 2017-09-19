//
//  ProgressBarView.m
//  YKPlayerSDKNoViewDemo
//
//  Created by SMY on 16/9/2.
//  Copyright © 2016年 SMY. All rights reserved.
//

#import "PlayerProgressView.h"

static const float PROGRESS_VIEW_HEIGHT = 2;
static const float SLIDER_VIEW_HEIGHT = 32;

@interface PlayerProgressView () {
    UIProgressView  *_progressView;
    UISlider        *_sliderView;
}

@end

@implementation PlayerProgressView

- (instancetype)init {
    self = [super init];
    if (self) {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapFunc:)];
        [self addGestureRecognizer:tap];
        self.userInteractionEnabled = YES;
        
        _progressView = [[UIProgressView alloc] init];
        _progressView.trackTintColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1];
        _progressView.progressTintColor = [UIColor lightGrayColor];
        
        _sliderView = [[UISlider alloc] init];
        _sliderView.maximumTrackTintColor = [UIColor clearColor];
        _sliderView.minimumTrackTintColor = [UIColor blueColor];
        UIImage *thumbImageNormal = [UIImage imageNamed:@"ic_hl_videoProgress"];
        [_sliderView setThumbImage:thumbImageNormal forState:UIControlStateNormal];
        
        [_sliderView addTarget:self action:@selector(sliderValueChanged) forControlEvents:UIControlEventValueChanged];
        
        [self addSubview:_progressView];
        [self addSubview:_sliderView];
    }
    return self;
}

- (void)tapFunc:(UITapGestureRecognizer *)tap {
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect rect = self.bounds;
    
    float width = rect.size.width;
    float height = rect.size.height;
    
    _progressView.frame = CGRectMake(2, (height - PROGRESS_VIEW_HEIGHT) / 2, width-4, PROGRESS_VIEW_HEIGHT);
    _sliderView.frame = CGRectMake(0, (height - SLIDER_VIEW_HEIGHT) / 2, width, SLIDER_VIEW_HEIGHT);
}

- (void)sliderValueChanged {
    if (self.delegate) {
        [self.delegate onSliderValueChanged:_sliderView.value];
    }
}

- (void)setCurrentProgress:(float)progress {
    [_sliderView setValue:progress];
}

- (void)setLoadedProgress:(float)progress {
    [_progressView setProgress:progress];
}

@end
