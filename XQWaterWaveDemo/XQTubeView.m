//
//  XQTubeView.m
//  XQWaterWaveDemo
//
//  Created by kang on 2016/10/18.
//  Copyright © 2016年 kang. All rights reserved.
//

#import "XQTubeView.h"
#import "XQShapeLayer.h"
#import "XQTubeAnimationView.h"
@interface XQTubeView ()


@property (nonatomic, strong) XQTubeAnimationView *animationView;
@property (nonatomic, strong) XQTubeAnimationView *animationView2;
@end

@implementation XQTubeView


#pragma mark - 初始化
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = colorWithRGBA(251, 91, 91,1);
        self.layer.masksToBounds = YES;
        
        [self setSubviews];
        
    }
    return self;
}


- (void) setSubviews {
    
    [self addSubview:self.animationView];
    
    [self addSubview:self.animationView2];
    
}

#pragma mark - getter
- (UIView *) animationView {

    if (!_animationView) {
        _animationView = [[XQTubeAnimationView alloc]initTubeViewWithFrame:CGRectMake(0, 0, 270, 30)];
        _animationView.center = CGPointMake(SCREEN_WIDTH/2, 146-15);
    }
    return _animationView;
}

- (UIView *) animationView2 {
    
    if (!_animationView2) {
        _animationView2 = [[XQTubeAnimationView alloc]initAnimationViewWithFrame:CGRectMake(0, 0, 270, 30)];
        _animationView2.center = CGPointMake(SCREEN_WIDTH/2, 146+15);
    }
    return _animationView2;
}





@end
