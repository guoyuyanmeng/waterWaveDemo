//
//  XQTubeView.m
//  XQWaterWaveDemo
//
//  Created by kang on 2016/10/18.
//  Copyright © 2016年 kang. All rights reserved.
//

#import "XQTubeView.h"
#import "XQShapeLayer.h"

@implementation XQTubeView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = colorWithRGB(251, 91, 91,1);
        self.layer.masksToBounds = YES;
        [self setBackgroundLaer];
    }
    return self;
}


/**
 设置背景两个红色椭圆和管道
 */
- (void) setBackgroundLaer {

    CGRect frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    UIColor *color = colorWithRGB(225, 65, 67, 1.0);
    
    //左边椭圆
    UIBezierPath *leftSemiPath = [UIBezierPath bezierPath];
    CGPoint pointR = CGPointMake(101, 100);
    [leftSemiPath addArcWithCenter:pointR radius:98 startAngle:(0.5 * M_PI) endAngle:(1.5 * M_PI) clockwise:YES];
    
    XQShapeLayer *leftEllipseLayer = [[XQShapeLayer alloc]initWithFrame:frame Color:color Path:leftSemiPath];
    [self.layer addSublayer:leftEllipseLayer];
    
    //中间管道
    
}

@end
