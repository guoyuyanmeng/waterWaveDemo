//
//  XQBaseView.m
//  XQWaterWaveDemo
//
//  Created by kang on 2016/10/18.
//  Copyright © 2016年 kang. All rights reserved.
//

#import "XQBaseView.h"
@interface XQBaseView ()
@property (nonatomic, strong) UIButton *resumeButton;
@property (nonatomic, strong) UIButton *pauseButton;
@property (nonatomic, strong) UIButton *startButton;
@end

@implementation XQBaseView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = colorWithRGB(251, 91, 91,1);
        self.layer.masksToBounds = YES;
        
        [self setButtons];
        
    }
    return self;
}

- (void) setButtons {
    //开始动画按钮
    _startButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _startButton.frame = CGRectMake(157.5, 20, 60, 30);
    [_startButton setBackgroundColor:[UIColor greenColor]];
    [_startButton setTitleColor:colorWithRGB(45,100,45,1.0) forState:UIControlStateNormal];
    [_startButton setTitleColor:colorWithRGB(30,40,70,1.0) forState:UIControlStateDisabled];
    [_startButton setTitle:@"开始" forState:UIControlStateNormal];
    [_startButton.layer setCornerRadius:5.0f];
    [_startButton.layer setBorderWidth:1.0f];
    [_startButton addTarget:self  action:@selector(startAnimation:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_startButton];
    
    //恢复动画按钮
    _resumeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _resumeButton.frame = CGRectMake(30, 20, 60, 30);
    [_resumeButton setBackgroundColor:colorWithRGB(70,50,70,0.8)];
    [_resumeButton setTitleColor:colorWithRGB(45,100,45,1.0) forState:UIControlStateNormal];
    [_resumeButton setTitle:@"恢复" forState:UIControlStateNormal];
    [_resumeButton.layer setCornerRadius:5.0f];
    [_resumeButton.layer setBorderWidth:1.0f];
    [_resumeButton addTarget:self  action:@selector(resumeAnimation:) forControlEvents:UIControlEventTouchUpInside];
    [_resumeButton setEnabled:NO];
    [self addSubview:_resumeButton];
    
    //暂停动画按钮
    _pauseButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_pauseButton setBackgroundColor:colorWithRGB(70,50,70,0.8)];
    _pauseButton.frame = CGRectMake(285,20, 60, 30);
    [_pauseButton setTitleColor:colorWithRGB(45,100,45,1.0) forState:UIControlStateNormal];
    [_pauseButton setTitle:@"暂停" forState:UIControlStateNormal];
    [_pauseButton.layer setCornerRadius:5.0f];
    [_pauseButton.layer setBorderWidth:1.0f];
    [_pauseButton addTarget:self  action:@selector(pauseAnimation:) forControlEvents:UIControlEventTouchUpInside];
    [_pauseButton setEnabled:NO];
    [self addSubview:_pauseButton];
}

#pragma mark - button response
- (void) startAnimation:(id) sender {
    
    [sender setBackgroundColor:colorWithRGB(70,50,70,0.8)];
    [_startButton setEnabled:NO];
    
    [_pauseButton setEnabled:YES];
    [_pauseButton setBackgroundColor:[UIColor greenColor]];
    
    [_resumeButton setEnabled:YES];
    [_resumeButton setBackgroundColor:[UIColor greenColor]];
}

- (void) resumeAnimation:(id) sender {

    [sender setBackgroundColor:colorWithRGB(70,50,70,0.8)];
    [_resumeButton setEnabled:NO];
    
    [_pauseButton setEnabled:YES];
    [_pauseButton setBackgroundColor:[UIColor greenColor]];
}

- (void) pauseAnimation:(id) sender {

    [sender setBackgroundColor:colorWithRGB(70,50,70,0.8)];
    [_pauseButton setEnabled:NO];
    
    [_resumeButton setEnabled:YES];
    [_resumeButton setBackgroundColor:[UIColor greenColor]];
}
@end
