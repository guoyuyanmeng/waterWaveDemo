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
    
    CGFloat R; // base shape 大圆半径
    CGFloat r; // animation shape 大圆半径
    CGFloat space;// baseShape 和animation shape 间距
    
    CGFloat b; // begin x 动画行进过程中起点x坐标（动态变化）
    CGFloat e; // end x  动画行进过程中终点x坐标（动态变化）
    CGFloat d; // displacement x位移量
    
    CGFloat tubeH; // tube 高度
    
}
@property (nonatomic, assign) double a;                             /// 大圆、小圆圆心连线与x轴的夹角
@property (nonatomic, assign) double increment;                     /// d的增量，如每帧移动4point
@property (nonatomic, assign) double uber_w;                        /// 挤压完成，开始拉伸的距离
@property (nonatomic, assign) double uber_rate;                     /// uber_w段中的速率，默认1.5x
@property (nonatomic, assign) double tube_w;                        /// 挤压开始，到达出口的距离，即管道长度
@property (nonatomic, assign) double tube_rate;                     /// tube_w 段中的速率，默认3x
@property (nonatomic, assign) double mainRect_w;                    /// 主体矩形的宽度

@property (nonatomic, strong) XQShapeLayer *leftSemiShape;          /// 左边圆弧
@property (nonatomic, strong) XQShapeLayer *leftRectShape;          /// 主体矩形区域
@property (nonatomic, strong) XQShapeLayer *leftVolcanoShape;       /// 火山形状
@property (nonatomic, strong) XQShapeLayer *leftCircleShape;        /// 快完全进入时，使用该形状代替整体形状
@property (nonatomic, strong) XQShapeLayer *rightSemiShape;         /// 左边圆弧
@property (nonatomic, strong) XQShapeLayer *rightRectShape;         /// 主体矩形区域
@property (nonatomic, strong) XQShapeLayer *rightVolcanoShape;      /// 火山形状
@property (nonatomic, strong) XQShapeLayer *rightCircleShape;       /// 快完全进入时，使用该形状代替整体形状
@property (nonatomic, strong) XQShapeLayer *tubeShape;              /// 管道形状矩形区域


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

//    [self test];
}

//初始化各shape
- (void)initAnimationShapes
{
    [self.layer addSublayer:self.leftSemiShape];
    [self.layer addSublayer:self.leftRectShape];
    [self.layer addSublayer:self.leftCircleShape];
    [self.layer addSublayer:self.leftVolcanoShape];
    
    [self.layer addSublayer:self.rightSemiShape];
    [self.layer addSublayer:self.rightRectShape];
    [self.layer addSublayer:self.rightCircleShape];
    [self.layer addSublayer:self.rightVolcanoShape];
    [self.layer addSublayer:self.tubeShape];

}


#pragma mark - 设置
- (void) initData {
    
    //    R = self.frame.size.height/2 - 4;
    R = self.frame.size.height/2;
    r = R - 2;
    space = R - r;
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
    
    d = 0;
    
    tubeH = r * (3*sinx(_a) - 1);
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

#pragma mark left
- (CAShapeLayer *) leftSemiShape {

    if (!_leftSemiShape) {
        _leftSemiShape = [[XQShapeLayer alloc]initWithFrame:self.shapeFrame Color:self.shapeColor];
    }
    
    return _leftSemiShape;
}

- (CAShapeLayer *) leftRectShape {
    
    if (!_leftRectShape) {
        _leftRectShape = [[XQShapeLayer alloc]initWithFrame:self.shapeFrame Color:self.shapeColor];
    }
    
    return _leftRectShape;
}

- (CAShapeLayer *) leftCircleShape {
    
    if (!_leftCircleShape) {
        _leftCircleShape = [[XQShapeLayer alloc]initWithFrame:self.shapeFrame Color:self.shapeColor];
    }
    
    return _leftCircleShape;
}

- (CAShapeLayer *) leftVolcanoShape {
    
    if (!_leftVolcanoShape) {
        _leftVolcanoShape = [[XQShapeLayer alloc]initWithFrame:self.shapeFrame Color:self.shapeColor];
    }
    
    return _leftVolcanoShape;
}

#pragma mark right

- (CAShapeLayer *) rightSemiShape {
    
    if (!_rightSemiShape) {
        _rightSemiShape = [[XQShapeLayer alloc]initWithFrame:self.shapeFrame Color:self.shapeColor];
    }
    
    return _rightSemiShape;
}

- (CAShapeLayer *) rightRectShape {
    
    if (!_rightRectShape) {
        _rightRectShape = [[XQShapeLayer alloc]initWithFrame:self.shapeFrame Color:self.shapeColor];
    }
    
    return _rightRectShape;
}

- (CAShapeLayer *) rightCircleShape {
    
    if (!_rightCircleShape) {
        _rightCircleShape = [[XQShapeLayer alloc]initWithFrame:self.shapeFrame Color:self.shapeColor];
    }
    
    return _rightCircleShape;
}

- (CAShapeLayer *) rightVolcanoShape {
    
    if (!_rightVolcanoShape) {
        _rightVolcanoShape = [[XQShapeLayer alloc]initWithFrame:self.shapeFrame Color:self.shapeColor];
    }
    
    return _rightVolcanoShape;
}

#pragma mark tube
- (CAShapeLayer *) tubeShape {
    
    if (!_tubeShape) {
        _tubeShape = [[XQShapeLayer alloc]initWithFrame:self.shapeFrame Color:self.shapeColor];
    }
    
    return _tubeShape;
}

#pragma mark director
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
    [leftVocalnoPath addArcWithCenter:O5 radius:R/2 startAngle:(M_PI * 0.5) endAngle:(M_PI * ((180 - _a)/180)) clockwise:YES];
    [leftVocalnoPath addArcWithCenter:O6 radius:R/2 startAngle:((180 + _a)/180 *M_PI) endAngle:(1.5 *M_PI) clockwise:YES];
    XQShapeLayer *leftVocalnoShape = [[XQShapeLayer alloc]initWithFrame:self.shapeFrame Color:self.baseColor Path:leftVocalnoPath];
    [self.layer addSublayer:leftVocalnoShape];
    
    UIBezierPath *rightVocalnoPath = [UIBezierPath bezierPath];
    [rightVocalnoPath addArcWithCenter:O7 radius:R/2 startAngle:(M_PI * _a/180) endAngle:(M_PI * 0.5) clockwise:YES];
    [rightVocalnoPath addArcWithCenter:O8 radius:R/2 startAngle:(M_PI * 1.5) endAngle:((360 - _a)/180 * M_PI) clockwise:YES];
    XQShapeLayer *righVocalnoShape = [[XQShapeLayer alloc]initWithFrame:self.shapeFrame Color:self.baseColor Path:rightVocalnoPath];
    [self.layer addSublayer:righVocalnoShape];
}


/**
 两个椭圆之间的细长管道
 */
- (void) drawTubeShapes {
    
    UIBezierPath *recPath = [UIBezierPath bezierPath];
    [recPath moveToPoint:CGPointMake(O5.x , O5.y + R/2)];
    [recPath addLineToPoint:CGPointMake(O6.x , O6.y - R/2)];
    [recPath addLineToPoint:CGPointMake(O8.x , O8.y - R/2)];
    [recPath addLineToPoint:CGPointMake(O7.x , O7.y + R/2)];
//    [recPath addLineToPoint:CGPointMake(O5.x , O5.y + R/2)];
    [recPath closePath];
    XQShapeLayer *tubeShape = [[XQShapeLayer alloc]initWithFrame:self.shapeFrame Color:self.baseColor Path:recPath];
    [self.layer addSublayer:tubeShape];
}

#pragma mark - animation shapes

/**
 动画初始状态
 */
- (void) drawAnimationBeginState {
    
    UIBezierPath *leftSemiPath = [UIBezierPath bezierPath];
    [leftSemiPath addArcWithCenter:CGPointMake(O1.x , O1.y) radius:r startAngle:(0.5 * M_PI) endAngle:(1.5 * M_PI) clockwise:YES];
   
    UIBezierPath *leftMainRecPath = [UIBezierPath bezierPath];
    [leftMainRecPath moveToPoint:CGPointMake(O1.x , O1.y - r)];
    [leftMainRecPath addLineToPoint:CGPointMake(O1.x, O1.y + r)];
    [leftMainRecPath addLineToPoint:CGPointMake(O2.x  , O2.y+r)];
    [leftMainRecPath addLineToPoint:CGPointMake(O2.x, O2.y - r)];
    
    
    UIBezierPath *rightSemiPath = [UIBezierPath bezierPath];
    [rightSemiPath addArcWithCenter:CGPointMake(O2.x , O2.y) radius:r startAngle:(1.5 * M_PI) endAngle:(0.5 * M_PI) clockwise:YES];
    
    [leftSemiPath appendPath:leftMainRecPath];
    [leftSemiPath appendPath:rightSemiPath];
    
    self.leftSemiShape.path = leftSemiPath.CGPath;
}


- (void) drawAnimationBeginWithSemi {

    UIBezierPath *leftSemiPath = [UIBezierPath bezierPath];
    [leftSemiPath addArcWithCenter:CGPointMake(O1.x  + b, O1.y) radius:r startAngle:(0.5 * M_PI) endAngle:(1.5 * M_PI) clockwise:YES];
    self.leftSemiShape.path = leftSemiPath.CGPath;
    
    UIBezierPath *leftMainRecPath = [UIBezierPath bezierPath];
    [leftMainRecPath moveToPoint:CGPointMake(O1.x + b, O1.y - r)];
    [leftMainRecPath addLineToPoint:CGPointMake(O1.x + b, O1.y + r)];
    [leftMainRecPath addLineToPoint:CGPointMake(O2.x  , O2.y+r)];
    [leftMainRecPath addLineToPoint:CGPointMake(O2.x, O2.y - r)];
    self.leftRectShape.path = leftMainRecPath.CGPath;
    
    UIBezierPath *leftCirclePath = [UIBezierPath bezierPath];
    [leftCirclePath addArcWithCenter:CGPointMake(O2.x , O2.y) radius:r startAngle:(1.5 * M_PI) endAngle:(0.5 * M_PI) clockwise:YES];
    self.leftCircleShape.path = leftCirclePath.CGPath;
    
    CGFloat ox = O2.x + 1.5*r*cosx(_a); // 左边两个小圆的圆心x坐标
    CGFloat offsetY = 1.5*r*sinx(_a); // 小圆的圆心y坐标偏移量
    
    UIBezierPath *leftVocalnoPath = [UIBezierPath bezierPath];
    [leftVocalnoPath addArcWithCenter:CGPointMake(ox, O2.y - offsetY) radius:r/2 startAngle:(M_PI * 0.5) endAngle:(M_PI * ((180 - _a)/180)) clockwise:YES];
    [leftVocalnoPath addArcWithCenter:CGPointMake(ox, O2.y + offsetY) radius:r/2 startAngle:((180 + _a)/180 *M_PI) endAngle:(1.5 *M_PI) clockwise:YES];
    self.leftVolcanoShape.path = leftVocalnoPath.CGPath;

    CGFloat beginX = O2.x + 1.5*r*cosx(_a);
    CGFloat tubeW = (2*b)/(3*sinx(_a) - 1);
    
    UIBezierPath *tubePath = [UIBezierPath bezierPath];
    [tubePath moveToPoint:CGPointMake(beginX, O2.y - tubeH/2)];
    [tubePath addLineToPoint:CGPointMake(beginX, O2.y + tubeH/2)];
    [tubePath addLineToPoint:CGPointMake(beginX +tubeW  , O2.y+tubeH/2)];
    [tubePath addLineToPoint:CGPointMake(beginX +tubeW, O2.y - tubeH/2)];
    self.tubeShape.path = tubePath.CGPath;
    
    NSLog(@"tubeH:%f",tubeH);
}

- (void) drawAnimationBeginWithCircle {
    
    self.leftSemiShape.path = [UIBezierPath bezierPath].CGPath;
    
    CGFloat circleR = r-(b -2*R)/2;
    UIBezierPath *leftCirclePath = [UIBezierPath bezierPath];
    [leftCirclePath addArcWithCenter:CGPointMake(O2.x + b -2*R , O2.y) radius:circleR startAngle:(0 * M_PI) endAngle:(2 * M_PI) clockwise:YES];
    self.leftCircleShape.path = leftCirclePath.CGPath;
    
    CGFloat ox = O2.x + 1.5*r*cosx(_a); // 左边两个小圆的圆心x坐标
    CGFloat offsetY = 1.5*r*sinx(_a); // 小圆的圆心y坐标偏移量
    
    UIBezierPath *leftVocalnoPath = [UIBezierPath bezierPath];
    [leftVocalnoPath addArcWithCenter:CGPointMake(ox, O2.y - offsetY) radius:r/2 startAngle:(M_PI * 0.5) endAngle:(M_PI * ((180 - _a)/180)) clockwise:YES];
    [leftVocalnoPath addArcWithCenter:CGPointMake(ox, O2.y + offsetY) radius:r/2 startAngle:((180 + _a)/180 *M_PI) endAngle:(1.5 *M_PI) clockwise:YES];
    self.leftVolcanoShape.path = leftVocalnoPath.CGPath;
    
    CGFloat beginX = O2.x + 1.5*r*cosx(_a);
    CGFloat tubeW = ((2*r*r) + M_PI *(r*r -circleR*circleR))/tubeH;
    
    UIBezierPath *tubePath = [UIBezierPath bezierPath];
    [tubePath moveToPoint:CGPointMake(beginX, O2.y - tubeH/2)];
    [tubePath addLineToPoint:CGPointMake(beginX, O2.y + tubeH/2)];
    [tubePath addLineToPoint:CGPointMake(beginX +tubeW  , O2.y+tubeH/2)];
    [tubePath addLineToPoint:CGPointMake(beginX +tubeW, O2.y - tubeH/2)];
    self.tubeShape.path = tubePath.CGPath;
    
    NSLog(@"tubeW:%f",tubeW);
}


#pragma mark - Response

- (void) drawAnimationShapes {
    
    if (b == 0) {
        [self drawAnimationBeginState];
    }else if (b <= R*2) {
        [self drawAnimationBeginWithSemi];
    }else if (b <= R*2 + r*cosx(_a)) {
        [self drawAnimationBeginWithCircle];
    }
    
    
    b += 0.5;
}


- (void) pause {
    [self.displayLink removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

- (void) resume {
    
    b = 0;
    [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}


-(void)test {

    CGFloat Ssector = 1/2 *R*R * (_a/180)*M_PI; //大扇形面积。扇形面积计算公式：1/2×弧长×半径。弧长公式：弧长=半径×弧度
    CGFloat Striangle = R*R*sinx(_a)*cosx(_a);
    
    CGFloat Sarc = Ssector - Striangle;
    
    NSLog(@"大圆弧面积:%f",Sarc);
    
    
}


@end
