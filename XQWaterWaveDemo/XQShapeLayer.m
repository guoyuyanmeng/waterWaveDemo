//
//  XQShapeLayer.m
//  XQWaterWaveDemo
//
//  Created by kang on 2016/10/18.
//  Copyright © 2016年 kang. All rights reserved.
//

#import "XQShapeLayer.h"

@implementation XQShapeLayer

- (instancetype)initWithFrame:(CGRect)frame Color:(UIColor *)color Path:(UIBezierPath *)path
{
    self = [super init];
    if (self) {
        self.frame = frame;
        self.fillColor = color.CGColor;
        self.path = path.CGPath;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame Color:(UIColor *)color
{
    self = [super init];
    if (self) {
        self.frame = frame;
        self.fillColor = color.CGColor;
    }
    return self;
}

@end
