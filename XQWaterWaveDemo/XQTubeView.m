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
}

#pragma mark - getter
- (UIView *) animationView {

    if (!_animationView) {
        _animationView = [[XQTubeAnimationView alloc]initWithFrame:CGRectMake(0, 0, 270, 30)];
        _animationView.center = CGPointMake(SCREEN_WIDTH/2, 146);
    }
    return _animationView;
}




@end
