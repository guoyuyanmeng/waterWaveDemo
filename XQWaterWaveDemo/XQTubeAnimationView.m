//
//  XQTubeAnimationView.m
//  XQWaterWaveDemo
//
//  Created by kang on 2016/10/19.
//  Copyright © 2016年 kang. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "XQTubeAnimationView.h"
#import "XQShapeLayer.h"

@interface XQTubeAnimationView ()
{
    CGPoint O1; //左边形状左半圆圆心
    CGPoint O2; //左边形状有半圆圆心
    
    CGPoint O3; //右边形状左半圆圆心
    CGPoint O4; //右边性转有半圆圆心
    
    CGPoint O5; // 左边火山口形状上圆心
    CGPoint O6; // 左边火山口形状下圆心
    CGPoint O7; // 右边火山口形状上圆心
    CGPoint O8; // 右边火山口形状下圆心
    
    CGFloat R; // 大圆半径
    CGFloat r; // 小圆半径
    
    CGFloat d; // displacement x位移量
    
}
@property (nonatomic, assign) double a;                             /// 大圆、小圆圆心连线与x轴的夹角
@property (nonatomic, assign) double increment;                     /// d的增量，如每帧移动4point
@property (nonatomic, assign) double uber_w;                        /// 挤压完成，开始拉伸的距离
@property (nonatomic, assign) double uber_rate;                     /// uber_w段中的速率，默认1.5x
@property (nonatomic, assign) double tube_w;                        /// 挤压开始，到达出口的距离，即管道长度
@property (nonatomic, assign) double tube_rate;                     /// tube_w 段中的速率，默认3x
@property (nonatomic, assign) double mainRect_w;                    /// 主体矩形的宽度

@property (nonatomic, strong) XQShapeLayer *leftSemiShape;          /// 左边圆弧
@property (nonatomic, strong) XQShapeLayer *maintubeShape;          /// 主体矩形区域
@property (nonatomic, strong) XQShapeLayer *volcanoShape;           /// 火山形状
@property (nonatomic, strong) XQShapeLayer *rightCircleShape;       /// 右边圆形形状
@property (nonatomic, strong) XQShapeLayer *tailCircleShape;        /// 快完全进入时，使用该形状代替整体形状
@property (nonatomic, strong) XQShapeLayer *tubeShape;              /// 管道形状矩形区域
@property (nonatomic, strong) XQShapeLayer *wholeShape;             /// 整体行进过程形状

@property (nonatomic, assign) CGRect shapeFrame;                    /// 动画布景frame
@property (nonatomic, strong) UIColor *shapeColor;                  /// 动画颜色
@property (nonatomic, strong) UIColor *baseColor;                  /// 动画颜色
@property (nonatomic, strong) CADisplayLink *displayLink;

//@property (nonatomic, assign) double r1;
//@property (nonatomic, assign) double r2;
//@property (nonatomic, assign) double d;                             /// 平移距离，输入值
//@property (nonatomic, assign) double chosen_d;

@end

@implementation XQTubeAnimationView

#pragma mark - 初始化
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.layer.masksToBounds = YES;
        
        [self initData];
        
        [self initBaseShapes];
        
        [self initAnimationShapes];
        
    }
    return self;
}

- (void) initBaseShapes {
    
    [self drawLeftSemiShapes];
    [self drawRectShapes];
    [self drawRightSemiShapes];
    [self drawVocalnoShapes];
    [self drawTubeShapes];
    
}

//初始化各shape
- (void)initAnimationShapes
{
    //    self.shapeFrame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    //    self.shapeColor = [UIColor whiteColor];
    
    //    self.leftSemiShape = [[XQShapeLayer alloc]initWithFrame:frame Color:color];
    //    self.volcanoShape = [[XQShapeLayer alloc]initWithFrame:frame Color:color];
    //    self.rightCircleShape = [[XQShapeLayer alloc]initWithFrame:frame Color:color];
    //    self.tubeShape = [[XQShapeLayer alloc]initWithFrame:frame Color:color];
    //    self.maintubeShape = [[XQShapeLayer alloc]initWithFrame:frame Color:color];
    //    self.tailCircleShape = [[XQShapeLayer alloc]initWithFrame:frame Color:color];
    //    self.wholeShape = [[XQShapeLayer alloc]initWithFrame:frame Color:color];
    
    [self.layer addSublayer:self.leftSemiShape];
    [self.layer addSublayer:self.maintubeShape];
    [self.layer addSublayer:self.rightCircleShape];
    [self.layer addSublayer:self.tubeShape];
    [self.layer addSublayer:self.tailCircleShape];
    //    [self.layer addSublayer:self.leftSemiShape];
    //    [self.layer addSublayer:self.leftSemiShape];
    //    [self.layer addSublayer:self.leftSemiShape];
    
}


#pragma mark - 设置

- (void) initData {
    
    //    R = self.frame.size.height/2 - 4;
    R = self.frame.size.height/2;
    r = R/2;
    _a = 35;
    
    O1 = CGPointMake(R, self.frame.size.height/2);
    O2 = CGPointMake(R*3, self.frame.size.height/2);
    
    O3 = CGPointMake(self.frame.size.width - R*3, self.frame.size.height/2);
    O4 = CGPointMake(self.frame.size.width - R, self.frame.size.height/2);
    
    CGFloat ox = O2.x + 1.5*R*cosx(_a); // 左边两个小圆的圆心x坐标
    //    CGFloat offsetX = 1.5*R*cosx(_a); // 小圆的圆心x坐标偏移量
    CGFloat offsetY = 1.5*R*sinx(_a); // 小圆的圆心y坐标偏移量
    
    //左方右上角圆心
    O5 = CGPointMake(ox , self.frame.size.height/2 - offsetY);
    O6 = CGPointMake(ox , self.frame.size.height/2 + offsetY);
    
    //左方右上角圆心
    O7 = CGPointMake(self.frame.size.width - ox , self.frame.size.height/2 - offsetY);
    O8 = CGPointMake(self.frame.size.width - ox , self.frame.size.height/2 + offsetY);
    
    d = 0.3;
}

#pragma mark - getter

- (CGRect) shapeFrame {
    
    if (CGRectEqualToRect(_shapeFrame ,CGRectZero)) {
        _shapeFrame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    }
    return _shapeFrame;
}

- (UIColor *) baseColor {

    if (!_baseColor) {
        _baseColor = RGB(225, 65, 67);
    }
    
    return _baseColor;
}

- (UIColor *) shapeColor {
    
    if (!_shapeColor) {
        _shapeColor = [UIColor whiteColor];
    }
    return _shapeColor;
}


- (CAShapeLayer *) leftSemiShape {

    if (!_leftSemiShape) {
        _leftSemiShape = [[XQShapeLayer alloc]initWithFrame:self.shapeFrame Color:self.shapeColor];
    }
    
    return _leftSemiShape;
}


- (CAShapeLayer *) maintubeShape {
    
    if (!_maintubeShape) {
        _maintubeShape = [[XQShapeLayer alloc]initWithFrame:self.shapeFrame Color:self.shapeColor];
    }
    
    return _maintubeShape;
}


- (CAShapeLayer *) rightCircleShape {
    
    if (!_rightCircleShape) {
        _rightCircleShape = [[XQShapeLayer alloc]initWithFrame:self.shapeFrame Color:self.shapeColor];
    }
    
    return _rightCircleShape;
}


- (CAShapeLayer *) volcanoShape {
    
    if (!_volcanoShape) {
        _volcanoShape = [[XQShapeLayer alloc]initWithFrame:self.shapeFrame Color:self.shapeColor];
    }
    
    return _volcanoShape;
}


- (CAShapeLayer *) tubeShape {
    
    if (!_tubeShape) {
        _tubeShape = [[XQShapeLayer alloc]initWithFrame:self.shapeFrame Color:self.shapeColor];
    }
    
    return _tubeShape;
}


- (CAShapeLayer *) tailCircleShape {
    
    if (!_tailCircleShape) {
        _tailCircleShape = [[XQShapeLayer alloc]initWithFrame:self.shapeFrame Color:self.shapeColor];
    }
    
    return _tailCircleShape;
}

- (CADisplayLink *)displayLink
{
    if (!_displayLink) {
        _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(drawAnimationShapes)];
    }
    return _displayLink;
}




#pragma mark - base shapes
/**
 细管道图形两边半挂形状的左侧半圆
 */
- (void) drawLeftSemiShapes {
    
    UIBezierPath *leftSemiPath = [UIBezierPath bezierPath];
    [leftSemiPath addArcWithCenter:O1 radius:R startAngle:(0.5 * M_PI) endAngle:(1.5 * M_PI) clockwise:YES];
    XQShapeLayer *leftSemiShape = [[XQShapeLayer alloc]initWithFrame:self.shapeFrame Color:self.baseColor Path:leftSemiPath];
    [self.layer addSublayer:leftSemiShape];
    
    UIBezierPath *leftSemiPath2 = [UIBezierPath bezierPath];
    [leftSemiPath2 addArcWithCenter:O4 radius:R startAngle:(0.5 * M_PI) endAngle:(1.5 * M_PI) clockwise:NO];
    XQShapeLayer *leftSemiShape2 = [[XQShapeLayer alloc]initWithFrame:self.shapeFrame Color:self.baseColor Path:leftSemiPath2];
    [self.layer addSublayer:leftSemiShape2];
}


/**
 细管道图形两边半挂形状的中间矩形
 */
- (void) drawRectShapes {
    
    UIBezierPath *leftMainRecPath = [UIBezierPath bezierPath];
    [leftMainRecPath moveToPoint:CGPointMake(O1.x, O1.y - R)];
    [leftMainRecPath addLineToPoint:CGPointMake(O1.x, O1.y + R)];
    [leftMainRecPath addLineToPoint:CGPointMake(O2.x , O2.y+R)];
    [leftMainRecPath addLineToPoint:CGPointMake(O2.x, O2.y - R)];
    XQShapeLayer *leftRectShape = [[XQShapeLayer alloc]initWithFrame:self.shapeFrame Color:self.baseColor Path:leftMainRecPath];
    [self.layer addSublayer:leftRectShape];
    
    UIBezierPath *rightMainRecPath = [UIBezierPath bezierPath];
    [rightMainRecPath moveToPoint:CGPointMake(O4.x , O4.y - R)];
    [rightMainRecPath addLineToPoint:CGPointMake(O4.x , O4.y + R)];
    [rightMainRecPath addLineToPoint:CGPointMake(O3.x , O3.y+R)];
    [rightMainRecPath addLineToPoint:CGPointMake(O3.x , O3.y - R)];
    XQShapeLayer *rightRectShape = [[XQShapeLayer alloc]initWithFrame:self.shapeFrame Color:self.baseColor Path:rightMainRecPath];
    [self.layer addSublayer:rightRectShape];
}


/**
 细管道图形两边半挂形状的右侧半圆
 */
- (void) drawRightSemiShapes {

    UIBezierPath *rightSemiPath = [UIBezierPath bezierPath];
    [rightSemiPath addArcWithCenter:O2 radius:R startAngle:(1.5 * M_PI) endAngle:(0.5 * M_PI) clockwise:YES];
    XQShapeLayer *rightSemiShape = [[XQShapeLayer alloc]initWithFrame:self.shapeFrame Color:self.baseColor Path:rightSemiPath];
    [self.layer addSublayer:rightSemiShape];
    
    UIBezierPath *rightSemiPath2 = [UIBezierPath bezierPath];
    [rightSemiPath2 addArcWithCenter:O3 radius:R startAngle:(1.5 * M_PI) endAngle:(0.5 * M_PI) clockwise:NO];
    XQShapeLayer *rightSemiShape2 = [[XQShapeLayer alloc]initWithFrame:self.shapeFrame Color:self.baseColor Path:rightSemiPath2];
    [self.layer addSublayer:rightSemiShape2];
}


/**
 半圆和细管道无缝平滑连接的火山口形状
 */
- (void) drawVocalnoShapes {
    
    UIBezierPath *leftVocalnoPath = [UIBezierPath bezierPath];
    [leftVocalnoPath addArcWithCenter:O5 radius:r startAngle:(M_PI * 0.5) endAngle:(M_PI * ((180 - _a)/180)) clockwise:YES];
    [leftVocalnoPath addArcWithCenter:O6 radius:r startAngle:((180 + _a)/180 *M_PI) endAngle:(1.5 *M_PI) clockwise:YES];
    XQShapeLayer *leftVocalnoShape = [[XQShapeLayer alloc]initWithFrame:self.shapeFrame Color:self.baseColor Path:leftVocalnoPath];
    [self.layer addSublayer:leftVocalnoShape];
    
    UIBezierPath *rightVocalnoPath = [UIBezierPath bezierPath];
    [rightVocalnoPath addArcWithCenter:O7 radius:r startAngle:(M_PI * _a/180) endAngle:(M_PI * 0.5) clockwise:YES];
    [rightVocalnoPath addArcWithCenter:O8 radius:r startAngle:(M_PI * 1.5) endAngle:((360 - _a)/180 * M_PI) clockwise:YES];
    XQShapeLayer *righVocalnoShape = [[XQShapeLayer alloc]initWithFrame:self.shapeFrame Color:self.baseColor Path:rightVocalnoPath];
    [self.layer addSublayer:righVocalnoShape];
}


/**
 两个椭圆之间的细长管道
 */
- (void) drawTubeShapes {
    
    UIBezierPath *recPath = [UIBezierPath bezierPath];
    [recPath moveToPoint:CGPointMake(O5.x , O5.y + r)];
    [recPath addLineToPoint:CGPointMake(O6.x , O6.y - r)];
    [recPath addLineToPoint:CGPointMake(O8.x , O8.y - r)];
    [recPath addLineToPoint:CGPointMake(O7.x , O7.y + r)];
//    [recPath addLineToPoint:CGPointMake(O5.x , O5.y + r)];
    [recPath closePath];
    XQShapeLayer *tubeShape = [[XQShapeLayer alloc]initWithFrame:self.shapeFrame Color:self.baseColor Path:recPath];
    [self.layer addSublayer:tubeShape];
}

#pragma mark - animation shapes

- (void) drawAnimationSemi {

    if (d <= R) {
        
        UIBezierPath *leftSemiPath = [UIBezierPath bezierPath];
        [leftSemiPath addArcWithCenter:CGPointMake(O1.x+d, O1.y) radius:R-3 startAngle:(0.5 * M_PI) endAngle:(1.5 * M_PI) clockwise:YES];
        self.leftSemiShape.path = leftSemiPath.CGPath;
        
    }else if (d <= R*2){
        
        UIBezierPath *leftSemiPath = [UIBezierPath bezierPath];
        [leftSemiPath addArcWithCenter:CGPointMake(O4.x - 2*R + d, O1.y) radius:R-3 startAngle:(0.5 * M_PI) endAngle:(1.5 * M_PI) clockwise:NO];
        self.leftSemiShape.path = leftSemiPath.CGPath;
        
    }
}


#pragma mark - Response

- (void) drawAnimationShapes {
    
    
    [self drawAnimationSemi];
    d += 3;
}


- (void) pause {
    [self.displayLink removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

- (void) resume {
    [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}



@end
