//
//  XQCGPathView.m
//  XQWaterWaveDemo
//
//  Created by kang on 2016/10/17.
//  Copyright © 2016年 kang. All rights reserved.
//

#import "XQCGPathView.h"

@interface XQCGPathView ()
@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic,strong) CAShapeLayer *waveShapeLayer;
@end
@implementation XQCGPathView

- (void) drawRect:(CGRect)rect {

    //获取当前绘图上下文
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    
    CGPoint center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    //创建圆角矩形路径
    CGPathRef pathRef = CGPathCreateWithRoundedRect(CGRectMake(center.x-50, center.y-50, 100, 100), 0, 0, nil);
    //将路径虚线化
    CGFloat floats[] = {10,5};
    pathRef = CGPathCreateCopyByDashingPath(pathRef, nil, 0, floats, 2);
    // 设置绘制颜色
    [[UIColor redColor] setStroke];
    //将路径添加到绘图上下文中
    CGContextAddPath(contextRef, pathRef);
    //进行绘制
    CGContextDrawPath(contextRef, kCGPathStroke);
    //内存释放
    CGPathRelease(pathRef);
    
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGFloat y = 150;
    CGFloat cycle =  1.29 * M_PI /200;
    CGPathMoveToPoint(path, nil, 0, 10 * sin(-10) + 150 + 10);
    for (float x = 0.0f; x <= 200; x ++) {
        y = 10 * sin(cycle * x + 0 - 10) + 150 + 10;
        CGPathAddLineToPoint(path, nil, x, y);
    }
    
    CGPathAddLineToPoint(path, nil, 200, 200);
    CGPathAddLineToPoint(path, nil, 0, 200);
    CGPathCloseSubpath(path);
    [colorWithRGBA(38, 53, 94,0.8) setStroke];
    //将路径添加到绘图上下文中s
    CGContextAddPath(contextRef, path);
    //进行绘制
    CGContextDrawPath(contextRef, kCGPathStroke);
    
    CGPathRelease(path);
    CGContextRelease(contextRef);
    
}



@end
