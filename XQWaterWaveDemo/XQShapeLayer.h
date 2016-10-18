//
//  XQShapeLayer.h
//  XQWaterWaveDemo
//
//  Created by kang on 2016/10/18.
//  Copyright © 2016年 kang. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

@interface XQShapeLayer : CAShapeLayer

- (instancetype)initWithFrame:(CGRect)frame Color:(UIColor *)color;

- (instancetype)initWithFrame:(CGRect)frame Color:(UIColor *)color Path:(UIBezierPath *)path;

@end
