//
//  XQBaseView.h
//  XQWaterWaveDemo
//
//  Created by kang on 2016/10/18.
//  Copyright © 2016年 kang. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface XQBaseView : UIView

@property (nonatomic, strong) UIButton *resumeButton;
@property (nonatomic, strong) UIButton *pauseButton;
@property (nonatomic, strong) UIButton *startButton;

- (void) startAnimation:(id) sender;

- (void) resumeAnimation:(id) sender;

- (void) pauseAnimation:(id) sender;

@end
