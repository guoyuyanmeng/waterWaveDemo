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
    
    CGFloat dynamic_x1;
    CGFloat dynamic_x2;
    
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
@property (nonatomic, strong) CADisplayLink *rightDisplayLink;
@property (nonatomic, strong) CADisplayLink *leftDisplayLink;

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

    
    //[self drawLiletCicle];
}


#pragma mark - 设置
- (void) initData {
    
    //    R = self.frame.size.height/2 - 4;
    R = self.frame.size.height/2; //背景大圆半径
    r = R - 4; // 动画大圆半径
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
    
//    b = 2;
    
    b = O2.x - r;
    
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
- (CADisplayLink *)rightDisplayLink
{
    if (!_rightDisplayLink) {
        _rightDisplayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(rightDisplayLinkAction)];
    }
    return _rightDisplayLink;
}

- (CADisplayLink *)leftDisplayLink
{
    if (!_leftDisplayLink) {
        _leftDisplayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(leftDisplayLinkAction)];
    }
    return _leftDisplayLink;
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

/******************************************  Semi  *****************************************/

- (void) drawLeftSemiWithDynamic_CenterX:(CGFloat) dynamic_x {
    
    if (dynamic_x <= O1.x) {
        UIBezierPath *leftSemiPath = [UIBezierPath bezierPath];
        [leftSemiPath addArcWithCenter:O1 radius:r startAngle:(0.5 * M_PI) endAngle:(1.5 * M_PI) clockwise:YES];
        self.leftSemiShape.path = leftSemiPath.CGPath;
    }else if (dynamic_x <= O2.x) {
        
        UIBezierPath *leftSemiPath = [UIBezierPath bezierPath];
        [leftSemiPath addArcWithCenter:CGPointMake( dynamic_x , O1.y) radius:r startAngle:(0.5 * M_PI) endAngle:(1.5 * M_PI) clockwise:YES];
        self.leftSemiShape.path = leftSemiPath.CGPath;
    }else {
        self.leftSemiShape.path = [UIBezierPath bezierPath].CGPath;
    }
}


- (void) drawRightSemiWithDynamic_CenterX:(CGFloat) dynamic_x {
    
    if ( dynamic_x >= O4.x ) {
        UIBezierPath *rightSemiPath = [UIBezierPath bezierPath];
        [rightSemiPath addArcWithCenter:O4 radius:r startAngle:(1.5 * M_PI) endAngle:(0.5 * M_PI) clockwise:YES];
        self.rightSemiShape.path = rightSemiPath.CGPath;
    }else if (dynamic_x >= O3.x ) {
        
        UIBezierPath *rightSemiPath = [UIBezierPath bezierPath];
        [rightSemiPath addArcWithCenter:CGPointMake( dynamic_x , O1.y) radius:r startAngle:(1.5 * M_PI) endAngle:(0.5 * M_PI) clockwise:YES];
        self.rightSemiShape.path = rightSemiPath.CGPath;
    }else {
        
        self.rightSemiShape.path = [UIBezierPath bezierPath].CGPath;
    }
}

/******************************************  Rect  *****************************************/

- (void) drawLeftRectWithDynamic_BeginX:(CGFloat) dynamic_x {
//    NSLog(@"point+r=%f, O2.x=%f",pointX +r, O2.x);
    if (dynamic_x <= O1.x) {
        
        UIBezierPath *leftMainRecPath = [UIBezierPath bezierPath];
        [leftMainRecPath moveToPoint:CGPointMake(O1.x, O1.y - r)];
        [leftMainRecPath addLineToPoint:CGPointMake(O1.x, O1.y + r)];
        [leftMainRecPath addLineToPoint:CGPointMake(O2.x, O2.y + r)];
        [leftMainRecPath addLineToPoint:CGPointMake(O2.x, O2.y - r)];
        self.leftRectShape.path = leftMainRecPath.CGPath;
        
    }else if(dynamic_x <= O2.x) {
    
        UIBezierPath *leftMainRecPath = [UIBezierPath bezierPath];
        [leftMainRecPath moveToPoint:CGPointMake(dynamic_x, O1.y - r)];
        [leftMainRecPath addLineToPoint:CGPointMake(dynamic_x, O1.y + r)];
        [leftMainRecPath addLineToPoint:CGPointMake(O2.x, O2.y + r)];
        [leftMainRecPath addLineToPoint:CGPointMake(O2.x, O2.y - r)];
        self.leftRectShape.path = leftMainRecPath.CGPath;

    }else {
    
        self.leftRectShape.path = [UIBezierPath bezierPath].CGPath;
    }
   
}

- (void) drawRightRectWithDynamic_EndX:(CGFloat) dynamic_x {
    
    if (dynamic_x >=O4.x) {
        
        UIBezierPath *rightMainRecPath = [UIBezierPath bezierPath];
        [rightMainRecPath moveToPoint:CGPointMake(O3.x , O3.y - r)];
        [rightMainRecPath addLineToPoint:CGPointMake(O3.x, O3.y + r)];
        [rightMainRecPath addLineToPoint:CGPointMake(O4.x  , O4.y+r)];
        [rightMainRecPath addLineToPoint:CGPointMake(O4.x, O4.y - r)];
        self.rightRectShape.path = rightMainRecPath.CGPath;
        
    }else if(dynamic_x >=O3.x) {
        
        UIBezierPath *rightMainRecPath = [UIBezierPath bezierPath];
        [rightMainRecPath moveToPoint:CGPointMake(O3.x , O3.y - r)];
        [rightMainRecPath addLineToPoint:CGPointMake(O3.x, O3.y + r)];
        [rightMainRecPath addLineToPoint:CGPointMake(dynamic_x, O3.y + r)];
        [rightMainRecPath addLineToPoint:CGPointMake(dynamic_x, O3.y - r)];
        self.rightRectShape.path = rightMainRecPath.CGPath;
        
    }else {
        
        self.rightRectShape.path = [UIBezierPath bezierPath].CGPath;
    }
    
}

/*****************************************     circle     ********************************************/

- (void) drawLeftCircleWithDynamic_CenterX:(CGFloat) dynamic_x {
    
    if (dynamic_x  <= O2.x) {
        
        UIBezierPath *leftCirclePath = [UIBezierPath bezierPath];
        [leftCirclePath addArcWithCenter:O2 radius:r startAngle:(0) endAngle:(2 * M_PI) clockwise:YES];
        self.leftCircleShape.path = leftCirclePath.CGPath;
        
    }else if (dynamic_x <= 1.5*cosx(_a)*r +O2.x) {

        CGFloat dx = dynamic_x - O2.x;
        CGFloat constant_x = 1.5 *cosx(_a) *r;
        CGFloat circleR = r - (r - tubeH/2) *dx/constant_x;
        
        UIBezierPath *leftCirclePath = [UIBezierPath bezierPath];
        [leftCirclePath addArcWithCenter:CGPointMake( dynamic_x , O2.y) radius:circleR startAngle:(0 * M_PI) endAngle:(2 * M_PI) clockwise:YES];
        self.leftCircleShape.path = leftCirclePath.CGPath;
        
        NSLog(@"circleR=%f, tubeH=%f ",circleR,tubeH/2);
    }else {
        
        self.leftCircleShape.path = [UIBezierPath bezierPath].CGPath;
    }
}


- (void) drawRightCircleWithDynamic_CenterX:(CGFloat) dynamic_x {
    
    if (dynamic_x  >= O3.x) {
        
        UIBezierPath *rightCirclePath = [UIBezierPath bezierPath];
        [rightCirclePath addArcWithCenter:O3 radius:r startAngle:(0) endAngle:(2 * M_PI) clockwise:YES];
        self.rightCircleShape.path = rightCirclePath.CGPath;
        
    }else if (dynamic_x >= O3.x - 1.5*cosx(_a)*r) {
        
        CGFloat dx = O3.x - dynamic_x;
        CGFloat constant_x = 1.5 *cosx(_a) *r;
        CGFloat circleR = r - (r - tubeH/2) *dx/constant_x;
        
        UIBezierPath *rightCirclePath = [UIBezierPath bezierPath];
        [rightCirclePath addArcWithCenter:CGPointMake( dynamic_x , O3.y) radius:circleR startAngle:(0 * M_PI) endAngle:(2 * M_PI) clockwise:YES];
        self.rightCircleShape.path = rightCirclePath.CGPath;
        
    }else {
        
        self.rightCircleShape.path = [UIBezierPath bezierPath].CGPath;
    }
}


/*****************************************     Vocalno     ********************************************/

- (void) drawLeftVocalnoWithDynamic_CenterX1:(CGFloat) beginX Dynamic_CenterX2:(CGFloat) endX {

    CGFloat ox = O2.x + 1.5*r*cosx(_a);
    CGFloat offy = 1.5*r*sinx(_a);
    
    CGFloat bx = O2.x;
    CGFloat ex = O2.x + 1.5*r*cosx(_a);
    
    if (endX >= bx && endX <= ex) {
        
        CGFloat tan_dynamic_a = 1.5*sinx(_a)*r / (ex - endX);
        CGFloat dynamic_a = atan(tan_dynamic_a);
        
        NSLog(@"Left endX dynamic_a=%f",dynamic_a/M_PI*180);
        UIBezierPath *leftVocalnoPath = [UIBezierPath bezierPath];
        [leftVocalnoPath addArcWithCenter:CGPointMake(ox, O2.y - offy) radius:r/2 startAngle:(M_PI - dynamic_a) endAngle:(M_PI * ((180 - _a)/180)) clockwise:YES];
        [leftVocalnoPath addArcWithCenter:CGPointMake(ox, O2.y + offy) radius:r/2 startAngle:((180 + _a)/180 *M_PI) endAngle:(M_PI + dynamic_a) clockwise:YES];
        self.leftVolcanoShape.path = leftVocalnoPath.CGPath;
        
    }else if (beginX > bx && beginX < ex) {
        
        CGFloat tan_dynamic_a = 1.5*sinx(_a)*r / (ex - beginX);
        CGFloat dynamic_a = atan(tan_dynamic_a);
        
        NSLog(@"Left beginX dynamic_a= %f",dynamic_a/M_PI*180);
        UIBezierPath *leftVocalnoPath = [UIBezierPath bezierPath];
        [leftVocalnoPath addArcWithCenter:CGPointMake(ox, O2.y - offy) radius:r/2 startAngle:(M_PI * 0.5) endAngle:(M_PI  -  dynamic_a) clockwise:YES];
        [leftVocalnoPath addArcWithCenter:CGPointMake(ox, O2.y + offy) radius:r/2 startAngle:(M_PI + dynamic_a) endAngle:(1.5 * M_PI) clockwise:YES];
        self.leftVolcanoShape.path = leftVocalnoPath.CGPath;
        
    }else if (beginX < bx && endX > ex) {
    
        UIBezierPath *leftVocalnoPath = [UIBezierPath bezierPath];
        [leftVocalnoPath addArcWithCenter:CGPointMake(ox, O2.y - offy) radius:r/2 startAngle:(M_PI * 0.5) endAngle:(M_PI * ((180 - _a)/180)) clockwise:YES];
        [leftVocalnoPath addArcWithCenter:CGPointMake(ox, O2.y + offy) radius:r/2 startAngle:((180 + _a)/180 *M_PI) endAngle:(1.5 *M_PI) clockwise:YES];
        self.leftVolcanoShape.path = leftVocalnoPath.CGPath;
        
//        NSLog(@"Left nornal volvano");
        
    }else {
        self.leftVolcanoShape.path = [UIBezierPath bezierPath].CGPath;
    }
}


- (void) drawRightVocalnoWithDynamic_CenterX1:(CGFloat) beginX Dynamic_CenterX2:(CGFloat) endX {
    
    CGFloat ox = O3.x - 1.5*r*cosx(_a);
    CGFloat offy = 1.5*r*sinx(_a);
    
    CGFloat ex = O3.x;
    CGFloat bx = O3.x - 1.5*r*cosx(_a);
    
    if (endX > bx && endX < ex) {
        
//        CGFloat dynamic_x = endX - (O3.x - 1.5*r*cosx(_a));
//        CGFloat constant_x = 0.5 *cosx(_a) *r;
//        CGFloat dynamic_a =  dynamic_x/constant_x *(90 -_a) /180 *M_PI;
        
        CGFloat tan_dynamic_a = 1.5*sinx(_a)*r / (endX - bx);
        CGFloat dynamic_a = atan(tan_dynamic_a);
        
        NSLog(@"Right beginX dynamic_a= %f",dynamic_a/M_PI*180);
        UIBezierPath *rightVocalnoPath = [UIBezierPath bezierPath];
        [rightVocalnoPath addArcWithCenter:CGPointMake(ox, O3.y - offy) radius:r/2 startAngle:(dynamic_a) endAngle:(M_PI * 0.5) clockwise:YES];
        [rightVocalnoPath addArcWithCenter:CGPointMake(ox, O3.y + offy) radius:r/2 startAngle:(M_PI *1.5) endAngle:( 2*M_PI - dynamic_a) clockwise:YES];

        self.rightVolcanoShape.path = rightVocalnoPath.CGPath;
        
    }else if (beginX > bx && beginX < ex) {
        
//        CGFloat dynamic_x = beginX - (O3.x - 1.5*r*cosx(_a));
//        CGFloat constant_x = 0.5 *cosx(_a) *r;
//        CGFloat dynamic_a =  (constant_x - dynamic_x)/constant_x *(90 -_a) /180 *M_PI;
        
        CGFloat tan_dynamic_a = 1.5*sinx(_a)*r / (beginX - bx);
        CGFloat dynamic_a = atan(tan_dynamic_a);
        
        NSLog(@"Right beginX dynamic_a= %f",dynamic_a/M_PI*180);
        
        UIBezierPath *rightVocalnoPath = [UIBezierPath bezierPath];
        [rightVocalnoPath addArcWithCenter:CGPointMake(ox, O3.y - offy) radius:r/2 startAngle:(M_PI * _a/180) endAngle:(dynamic_a) clockwise:YES];
        [rightVocalnoPath addArcWithCenter:CGPointMake(ox, O3.y + offy) radius:r/2 startAngle:(M_PI * 2 - dynamic_a) endAngle:(M_PI * (360 - _a)/180) clockwise:YES];
        self.rightVolcanoShape.path = rightVocalnoPath.CGPath;
        
    }else if (beginX < bx && endX > ex) {
        
//        NSLog(@"Right normal volvano");
        UIBezierPath *rightVocalnoPath = [UIBezierPath bezierPath];
        [rightVocalnoPath addArcWithCenter:CGPointMake(ox, O3.y - offy) radius:r/2 startAngle:(M_PI * _a/180) endAngle:(M_PI * 0.5) clockwise:YES];
        [rightVocalnoPath addArcWithCenter:CGPointMake(ox, O3.y + offy) radius:r/2 startAngle:(M_PI *1.5) endAngle:(M_PI * (360 - _a)/180) clockwise:YES];
        self.rightVolcanoShape.path = rightVocalnoPath.CGPath;
        
    }else {
        
        self.rightVolcanoShape.path = [UIBezierPath bezierPath].CGPath;
    }
}

/*****************************************     Tube animation     ********************************************/

- (void) drawTuberWithBeginPointX:(CGFloat) beginX EndPointX:(CGFloat) endX {

    CGFloat bx = O2.x + 1.5*r*cosx(_a);
    CGFloat ex = O3.x - 1.5*r*cosx(_a);
    
    if (beginX <= bx && endX >=bx && endX <= ex){
    
        UIBezierPath *tubePath = [UIBezierPath bezierPath];
        [tubePath moveToPoint:CGPointMake(bx, O2.y - tubeH/2)];
        [tubePath addLineToPoint:CGPointMake(bx, O2.y + tubeH/2)];
        
        [tubePath addLineToPoint:CGPointMake(endX, O2.y+tubeH/2)];
        [tubePath addLineToPoint:CGPointMake(endX, O2.y - tubeH/2)];
        
        self.tubeShape.path = tubePath.CGPath;
        
    }else if (beginX >=bx && beginX <= ex && endX >=ex) {
    
        UIBezierPath *tubePath = [UIBezierPath bezierPath];
        [tubePath moveToPoint:CGPointMake(beginX, O2.y - tubeH/2)];
        [tubePath addLineToPoint:CGPointMake(beginX, O2.y + tubeH/2)];
        [tubePath addLineToPoint:CGPointMake(ex, O2.y+tubeH/2)];
        [tubePath addLineToPoint:CGPointMake(ex, O2.y - tubeH/2)];
        self.tubeShape.path = tubePath.CGPath;
        
    }else if (beginX < bx && endX >=ex) {
        
        UIBezierPath *tubePath = [UIBezierPath bezierPath];
        [tubePath moveToPoint:CGPointMake(bx, O2.y - tubeH/2)];
        [tubePath addLineToPoint:CGPointMake(bx, O2.y + tubeH/2)];
        [tubePath addLineToPoint:CGPointMake(ex, O2.y+tubeH/2)];
        [tubePath addLineToPoint:CGPointMake(ex, O2.y - tubeH/2)];
        self.tubeShape.path = tubePath.CGPath;
        
    }else {
        
        self.tubeShape.path = [UIBezierPath bezierPath].CGPath;
    }
}

/**************************************************************************************************************/


#pragma mark - Response


- (void) drawAnimationShapsWithDynamicCenterX1:(CGFloat) centerX1 DynamicCenterX2:(CGFloat) centerX2 {

    [self drawLeftSemiWithDynamic_CenterX:centerX1];
    [self drawRightSemiWithDynamic_CenterX:centerX2];
//
    [self drawLeftRectWithDynamic_BeginX:centerX1];
    [self drawRightRectWithDynamic_EndX:centerX2];
    
    [self drawLeftCircleWithDynamic_CenterX:centerX1];
    [self drawRightCircleWithDynamic_CenterX:centerX2];
    
    [self drawLeftVocalnoWithDynamic_CenterX1:centerX1 Dynamic_CenterX2:centerX2];
    [self drawRightVocalnoWithDynamic_CenterX1:centerX1 Dynamic_CenterX2:centerX2];
//
    [self drawTuberWithBeginPointX:centerX1 EndPointX:centerX2];
    
}
- (void) rightDisplayLinkAction {
    
    [self drawAnimationShapsWithDynamicCenterX1:dynamic_x1 DynamicCenterX2:dynamic_x2];
    
    if (dynamic_x1 >= O3.x && dynamic_x2 >= O4.x) {
        
        [self pauseRightDisplayLink];
    }
    
    CGFloat dx = 1;
    
    if (dynamic_x1 <O2.x ) {
        dynamic_x1 += dx;
        dynamic_x2 += (O3.x - O2.x)/(O2.x -O1.x) *dx;
        
    }else if (dynamic_x1 >= O2.x ) {
        dynamic_x1 += (O3.x - O2.x)/(O2.x -O1.x) *dx;
        dynamic_x2 += dx;;
    }else {
        dynamic_x1 += dx;
        dynamic_x2 += dx;
    }
    
   
    
    if (dynamic_x1> O3.x) {
        dynamic_x1 = O3.x;
        dynamic_x2 = O4.x;
    }

}

- (void) leftDisplayLinkAction {
    
    [self drawAnimationShapsWithDynamicCenterX1:dynamic_x1 DynamicCenterX2:dynamic_x2];
    
    if (dynamic_x1 <= O1.x && dynamic_x2 <= O2.x) {
        
        [self pauseLeftDisplayLink];
    }
    
    CGFloat dx = 1;
    
    if (dynamic_x2 <= O3.x) {
        
        dynamic_x1 = dynamic_x1 - (O3.x - O2.x)/(O2.x -O1.x) *dx;
        dynamic_x2 = dynamic_x2 -(O3.x - O2.x)/(O2.x -O1.x) *dx;
        
    }else if ( dynamic_x2 <= O4.x) {
        dynamic_x2 = dynamic_x2 - dx;
        dynamic_x1 = dynamic_x1 - (O3.x - O2.x)/(O2.x -O1.x) *dx;
    }else {
        dynamic_x1 = dynamic_x1 - dx;
        dynamic_x2 = dynamic_x2 - dx;
    }
    
    
    
    
    if (dynamic_x2< O2.x) {
        dynamic_x1 = O1.x;
        dynamic_x2 = O2.x;
    }
    
}



- (void) pauseRightDisplayLink {
    
//    [self.rightDisplayLink setPaused:YES];
    [self.rightDisplayLink removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    
    //[self.leftDisplayLink setPaused:YES];
    
}

- (void) pauseLeftDisplayLink {
    
//    [self.leftDisplayLink setPaused:YES];
    [self.leftDisplayLink removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    //[self.rightDisplayLink setPaused:YES];
}



- (void) turnRight {
    
    //[self.rightDisplayLink setPaused:NO];
    dynamic_x1 = O1.x;
    dynamic_x2 = O2.x;
    
    [self.rightDisplayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

- (void) turnLeft {
    
    //[self.leftDisplayLink setPaused:NO];
    dynamic_x1 = O3.x;
    dynamic_x2 = O4.x;
    
    [self.leftDisplayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}



@end
