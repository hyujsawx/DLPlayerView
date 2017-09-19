//
//  ProgressBarView.h
//  YKPlayerSDKNoViewDemo
//
//  Created by SMY on 16/9/2.
//  Copyright © 2016年 SMY. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PlayerSliderDelegate <NSObject>

- (void)onSliderValueChanged:(float)value;

@end

@interface PlayerProgressView : UIView

@property (nonatomic, weak) id<PlayerSliderDelegate> delegate;

- (void)setCurrentProgress:(float)progress;

- (void)setLoadedProgress:(float)progress;

@end
