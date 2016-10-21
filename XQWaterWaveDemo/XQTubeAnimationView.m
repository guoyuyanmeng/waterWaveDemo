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

@property (nonatomic, strong) UIView *wholeShapeView;               /// 背景整体形状所在view
@property (nonatomic, strong) UIView *animationShapeView;           /// 动画过程形状所在view


@property (nonatomic, assign) double r1;
@property (nonatomic, assign) double r2;
@property (nonatomic, assign) double d;                             /// 平移距离，输入值
@property (nonatomic, assign) double chosen_d;

@end

@implementation XQTubeAnimationView
{
    CGPoint _pointO;
    CGPoint _pointQ;
    CGPoint _pointQ2;
    CGPoint _pointO2;
    CGPoint _pointP;
    CGPoint _pointP2;
    CGPoint _pointR;
    CGPoint _pointA;
    CGPoint _pointB;
    CGPoint _pointC;
    CGPoint _pointD;
    double  _tube_h;
    double  _dynamic_Q_d;
    double  _dynamic_Q2_d;
    double _pointOx;
    BOOL _finished;
}

#pragma mark - 初始化
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.layer.masksToBounds = YES;
    }
    return self;
}

- (instancetype)initTubeViewWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self initParams];
        
        [self setBaseShape];
        
        [self initShapes];
        
        [self drawWithParams];
    }
    return self;
}


- (instancetype)initAnimationViewWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self initData];
        [self drawLeftShapes];
    }
    return self;
}

#pragma mark - 设置

- (void)initParams
{
    _finished = NO;
    
    _r1 = self.frame.size.height/2 - 4;
    _r2 = _r1/2;
    _a = 27.0;     //角度制
    _d = 0;
    _increment = 2;
    _mainRect_w = _r1 * 2;
    _pointOx = _r1 + _mainRect_w + 5;
    
    
    //左块右圆圆心
    _pointO = CGPointMake(_pointOx, self.frame.size.height/2);
    //动态圆圆心
    _pointQ = _pointO;
    //形状右圆圆心
    _pointQ2 = _pointQ;
    //左方右上角圆心
    _pointP = CGPointMake(1.5*_r1*cosx(_a) + _pointO.x, -1.5*_r1*sinx(_a) + _pointO.y);
    
    _uber_w = _pointP.x - _pointO.x;
    _tube_w = self.frame.size.width - _pointOx * 2 - _uber_w * 2 ;
    
    //右块左圆圆心
    _pointO2 = CGPointMake(_pointO.x + _tube_w + 2 * _uber_w, _pointO.y);
    //右方左上角圆心
    _pointP2 = CGPointMake(_pointP.x + _tube_w, _pointP.y);
    
    //左方右上角圆与主体右圆上交点
    _pointA = CGPointMake(_r1*cosx(_a) + _pointO.x, -_r1*sinx(_a) + _pointO.y);
    _pointB = CGPointMake(_pointA.x, _pointO.y + (_pointO.y - _pointA.y ));
    _pointC = CGPointMake(_pointP.x, _pointP.y + _r2);
    _tube_h = 2* ( _pointO.y - _pointC.y );
    _pointD = CGPointMake(_pointC.x, _pointC.y + _tube_h);
    
    _dynamic_Q_d = 0;
    _dynamic_Q2_d = 0;
    
    _uber_rate = 2.5f;
    _tube_rate = 6.0f;
}

#pragma mark - setter
/**
 设置背景两个红色椭圆和管道
 */
- (void) setBaseShape {
    
    CGRect frame = CGRectMake(0, 0, 270, self.frame.size.height);
    UIColor *color = RGB(225, 65, 67);
    double r1 = _r1 + 2;
    
    //----------------------------------------leftSemiShape(左圆形状)-----------------------------------------
    UIBezierPath *leftSemiPath = [UIBezierPath bezierPath];
    CGPoint pointR = CGPointMake(_pointO.x - _mainRect_w, _pointO.y);
    [leftSemiPath addArcWithCenter:pointR radius:_r1+2 startAngle:(0.5 * M_PI) endAngle:(1.5 * M_PI) clockwise:YES];
    
    XQShapeLayer *leftSemiShape = [[XQShapeLayer alloc]initWithFrame:frame Color:color Path:leftSemiPath];
    
    //----------------------------------------maintubeShape(主体矩形形状)-----------------------------------------
    UIBezierPath *mainRecPath = [UIBezierPath bezierPath];
    [mainRecPath moveToPoint:CGPointMake(pointR.x - 0.2, pointR.y - r1)];
    [mainRecPath addLineToPoint:CGPointMake(pointR.x - 0.2, pointR.y + r1)];
    [mainRecPath addLineToPoint:CGPointMake(_pointO.x + 0.2, _pointO.y + r1)];
    [mainRecPath addLineToPoint:CGPointMake(_pointO.x + 0.2, _pointO.y - r1)];
    
    XQShapeLayer *maintubeShape = [[XQShapeLayer alloc]initWithFrame:frame Color:color Path:mainRecPath];
    
    //-----------------------------------------rightSemiShape(右圆形状)-----------------------------------------
    UIBezierPath *rightSemiPath = [UIBezierPath bezierPath];
    [rightSemiPath addArcWithCenter:_pointO radius:r1 startAngle:(1.5 * M_PI) endAngle:(0.5 * M_PI) clockwise:YES];
    
    XQShapeLayer *rightSemiShape = [[XQShapeLayer alloc]initWithFrame:frame Color:color Path:rightSemiPath];
    
    //-------------------------------------------volcanoPath(火山形状)-----------------------------------------
    
    UIBezierPath *vocalnoPath = [UIBezierPath bezierPath];
    [vocalnoPath addArcWithCenter:CGPointMake(_pointP.x , _pointP.y) radius:_r2-2 startAngle:(M_PI * 0.5) endAngle:(M_PI * ((180 - _a)/180)) clockwise:YES];
    [vocalnoPath addArcWithCenter:CGPointMake(_pointP.x , _pointO.y + (_pointO.y - _pointP.y)) radius:_r2-2 startAngle:((180 + _a)/180 *M_PI) endAngle:(1.5 *M_PI) clockwise:YES];
    
    XQShapeLayer *vocalnoShape = [[XQShapeLayer alloc]initWithFrame:frame Color:color Path:vocalnoPath];
    
    //---------------------------------------------recPath(管道形状)-----------------------------------------
    double tube_h = _tube_h + 4;
    UIBezierPath *recPath = [UIBezierPath bezierPath];
    [recPath moveToPoint:CGPointMake(_pointO.x , _pointO.y - tube_h/2)];
    [recPath addLineToPoint:CGPointMake(_pointO.x , _pointO.y + tube_h/2)];
    [recPath addLineToPoint:CGPointMake(_pointO.x + _tube_w + _uber_w * 2, _pointO.y + tube_h/2)];
    [recPath addLineToPoint:CGPointMake(_pointO.x + _tube_w + _uber_w * 2, _pointO.y - tube_h/2)];
    [recPath addLineToPoint:CGPointMake(_pointO.x, _pointO.y - tube_h/2)];
    [recPath closePath];
    
    XQShapeLayer *tubeShape = [[XQShapeLayer alloc]initWithFrame:frame Color:color Path:recPath];
    
    //----------------------------------------r_leftSemiShape(右方左圆形状)-----------------------------------------
    UIBezierPath *r_leftSemiPath = [UIBezierPath bezierPath];
    CGPoint pointR2 = CGPointMake(_pointO.x + _uber_w * 2 + _tube_w, _pointO.y);
    [r_leftSemiPath addArcWithCenter:pointR2 radius:_r1+2 startAngle:(0.5 * M_PI) endAngle:(1.5 * M_PI) clockwise:YES];
    
    XQShapeLayer *r_leftSemiShape = [[XQShapeLayer alloc]initWithFrame:frame Color:color Path:r_leftSemiPath];
    
    //----------------------------------------r_maintubeShape(主体矩形形状)-----------------------------------------
    UIBezierPath *r_mainRecPath = [UIBezierPath bezierPath];
    [r_mainRecPath moveToPoint:CGPointMake(pointR2.x - 0.35, pointR2.y - r1)];
    [r_mainRecPath addLineToPoint:CGPointMake(pointR2.x - 0.35, pointR2.y + r1)];
    [r_mainRecPath addLineToPoint:CGPointMake(pointR2.x + _mainRect_w + 0.3, pointR2.y + r1)];
    [r_mainRecPath addLineToPoint:CGPointMake(pointR2.x + _mainRect_w + 0.3, pointR2.y - r1)];
    
    XQShapeLayer *r_maintubeShape = [[XQShapeLayer alloc]initWithFrame:frame Color:color Path:r_mainRecPath];
    //
    //-----------------------------------------r_rightSemiShape(右圆形状)-----------------------------------------
    UIBezierPath *r_rightSemiPath = [UIBezierPath bezierPath];
    [r_rightSemiPath addArcWithCenter:CGPointMake(pointR2.x + _mainRect_w, pointR2.y) radius:r1 startAngle:(1.5 * M_PI) endAngle:(0.5 * M_PI) clockwise:YES];
    
    XQShapeLayer *r_rightSemiShape = [[XQShapeLayer alloc]initWithFrame:frame Color:color Path:r_rightSemiPath];
    //
    //-------------------------------------------r_volcanoPath(火山形状)-----------------------------------------
    
    UIBezierPath *r_vocalnoPath = [UIBezierPath bezierPath];
    [r_vocalnoPath addArcWithCenter:CGPointMake(_pointO2.x - _uber_w, _pointP.y) radius:_r2-2 startAngle:(((_a)/180) * M_PI) endAngle:(M_PI * 0.5) clockwise:YES];
    [r_vocalnoPath addArcWithCenter:CGPointMake(_pointO2.x - _uber_w, _pointO.y + (_pointO.y - _pointP.y)) radius:_r2-2 startAngle:(1.5 * M_PI) endAngle:(((360 - _a)/180) * M_PI) clockwise:YES];
    
    
    XQShapeLayer *r_vocalnoShape = [[XQShapeLayer alloc]initWithFrame:frame Color:color Path:r_vocalnoPath];
    
    [self.layer addSublayer:leftSemiShape];
    [self.layer addSublayer:maintubeShape];
    [self.layer addSublayer:rightSemiShape];
    [self.layer addSublayer:vocalnoShape];
    [self.layer addSublayer:tubeShape];
    [self.layer addSublayer:r_leftSemiShape];
    [self.layer addSublayer:r_maintubeShape];
    [self.layer addSublayer:r_rightSemiShape];
    [self.layer addSublayer:r_vocalnoShape];
}

//初始化各shape
- (void)initShapes
{
    CGRect frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    UIColor *color = [UIColor whiteColor];
    
    self.leftSemiShape = [[XQShapeLayer alloc]initWithFrame:frame Color:color];
    self.volcanoShape = [[XQShapeLayer alloc]initWithFrame:frame Color:color];
    self.rightCircleShape = [[XQShapeLayer alloc]initWithFrame:frame Color:color];
    self.tubeShape = [[XQShapeLayer alloc]initWithFrame:frame Color:color];
    self.maintubeShape = [[XQShapeLayer alloc]initWithFrame:frame Color:color];
    self.tailCircleShape = [[XQShapeLayer alloc]initWithFrame:frame Color:color];
    self.wholeShape = [[XQShapeLayer alloc]initWithFrame:frame Color:color];
    
    self.wholeShapeView = [[UIView alloc]initWithFrame:frame];
    self.animationShapeView = [[UIView alloc]initWithFrame:frame];
    
    [self.animationShapeView.layer addSublayer:self.wholeShape];
    [self.animationShapeView.layer addSublayer:self.leftSemiShape];
    [self.animationShapeView.layer addSublayer:self.maintubeShape];
    [self.animationShapeView.layer addSublayer:self.volcanoShape];
    [self.animationShapeView.layer addSublayer:self.rightCircleShape];
    [self.animationShapeView.layer addSublayer:self.tubeShape];
    [self.animationShapeView.layer addSublayer:self.tailCircleShape];
    
    [self addSubview:self.wholeShapeView];
    [self addSubview:self.animationShapeView];
}

#pragma mark 绘制方法
- (void)drawWithParams
{
    //主体左圆圆心
    _pointR = CGPointMake(_pointO.x - _mainRect_w + _d, _pointO.y);
    
    //形状右方的圆行进距离，用来在最后进管道当做尾巴
    if (_dynamic_Q2_d <= _uber_w)
    {
        if (_d <= _mainRect_w) {
            _dynamic_Q2_d = 0;
        }else{
            _dynamic_Q2_d += _uber_rate * _increment;
        }
    }
    else if (_dynamic_Q2_d <= _tube_w + _uber_w)
    {
        _dynamic_Q2_d += _tube_rate * _increment;
    }
    else if (_dynamic_Q2_d <  _uber_w + _tube_w + _uber_w)
    {
        _dynamic_Q2_d += _uber_rate * _increment;
        if (_dynamic_Q2_d >= _uber_w + _tube_w + _uber_w) {
            _dynamic_Q2_d = _uber_w + _tube_w + _uber_w;
        }
    }
    else
    {
        _dynamic_Q2_d = _uber_w + _tube_w + _uber_w;
    }
    
    _pointQ2 = CGPointMake(_pointO.x + _dynamic_Q2_d, _pointO.y);
    
    //动态圆弧行进距离
    if (_dynamic_Q_d <= _uber_w)
    {
        _dynamic_Q_d += _uber_rate * _increment;
    }
    else if (_dynamic_Q_d < _uber_w + _tube_w)
    {
        _dynamic_Q_d += _tube_rate * _increment;
        if (_dynamic_Q_d > _tube_w + _uber_w)
        {
            _dynamic_Q_d = _tube_w + _uber_w;
        }
    }
    else if (_dynamic_Q_d <= _uber_w + _tube_w + _uber_w)
    {
        _dynamic_Q_d += _uber_rate * _increment;
    }
    else if(_dynamic_Q_d <= _uber_w + _tube_w + _uber_w + _mainRect_w)
    {   //到右方后原速行驶
        _dynamic_Q_d += _increment;
        if (_dynamic_Q_d > _uber_w + _tube_w + _uber_w + _mainRect_w)
        {
            _dynamic_Q_d = _uber_w + _tube_w + _uber_w + _mainRect_w;
            
//            if (!_finished) {
//                _finished = !_finished;
//                [self animationDidfinish];
//                if (self.towardsType == TowardRight) {
//                    if ([self.delegate respondsToSelector:@selector(didTurnedToRight)]) {
//                        [self.delegate didTurnedToRight];
//                    }
//                }else if([self.delegate respondsToSelector:@selector(didTurnedToLeft)]){
//                    [self.delegate didTurnedToLeft];
//                }
//            }
        }
    }
    //动态圆弧的圆心
    _pointQ = CGPointMake(_pointO.x + _dynamic_Q_d, _pointO.y);
    
    //动态圆弧端-圆心与y轴的夹角
    double c;
    
    if (_dynamic_Q_d <= _uber_w)
    {
        c = atan((_pointP.x - _pointO.x - _dynamic_Q_d)/(_pointO.y - _pointP.y))*180/M_PI;
    }
    else if (_dynamic_Q_d <= _uber_w + _tube_w)
    {
        c = 0;
    }
    else if (_dynamic_Q_d <= _uber_w + _tube_w + _uber_w)
    {
        c = atan((_pointQ.x - _pointP2.x)/(_pointO.y - _pointP.y))*180/M_PI;
    }
    else{
        c = 90 - _a;
    }
    
    //动态圆的半径
    double r3 = (_pointO.y - _pointP.y)/cosx(c) - _r2;
    
    //----------------------------------------------分部画path-----------------------------------------
    
    //----------------------------------------leftSemiShape(左圆弧形状)-----------------------------------------
    
    UIBezierPath *leftSemiPath = [UIBezierPath bezierPath];
    if (_d <= _mainRect_w) {
        [leftSemiPath addArcWithCenter:_pointR radius:_r1 startAngle:(0.5 * M_PI) endAngle:(1.5 * M_PI) clockwise:YES];
    }
    else if(_dynamic_Q_d >= _uber_w + _tube_w + _uber_w)
    {    //减去0.25是为了严密贴合，因为double计算最终结果稍有偏差
        [leftSemiPath addArcWithCenter:CGPointMake(_pointQ.x - 0.3, _pointQ.y) radius:_r1 startAngle:(1.5 * M_PI) endAngle:(0.5 * M_PI) clockwise:YES];
    }
    self.leftSemiShape.path = leftSemiPath.CGPath;
    
    //----------------------------------------maintubeShape(主体矩形形状)-----------------------------------------
    
    UIBezierPath *maintubeShape = [UIBezierPath bezierPath];
    if (_d <= _mainRect_w)
    {
        [maintubeShape moveToPoint:CGPointMake(_pointR.x, _pointR.y - _r1)];
        [maintubeShape addLineToPoint:CGPointMake(_pointR.x, _pointR.y + _r1)];
        [maintubeShape addLineToPoint:CGPointMake(_pointO.x, _pointO.y + _r1)];
        [maintubeShape addLineToPoint:CGPointMake(_pointO.x, _pointO.y - _r1)];
    }
    else if(_dynamic_Q_d >= _uber_w + _tube_w + _uber_w )
    {
        [maintubeShape moveToPoint:CGPointMake(_pointO2.x, _pointO2.y - _r1)];
        [maintubeShape addLineToPoint:CGPointMake(_pointO2.x, _pointO2.y + _r1)];
        [maintubeShape addLineToPoint:CGPointMake(_pointQ.x, _pointQ.y + _r1)];
        [maintubeShape addLineToPoint:CGPointMake(_pointQ.x, _pointQ.y - _r1)];
    }
    self.maintubeShape.path = maintubeShape.CGPath;
    
    //-------------------------------------------volcanoPath(火山形状)-----------------------------------------
    
    UIBezierPath *vocalnoPath = [UIBezierPath bezierPath];
    if(_d <= _mainRect_w)
    {   //形状左圆行驶到开始压缩之前
        double temC = c;
        if (c <= 0 ) {
            temC = 0;
        }
        [vocalnoPath addArcWithCenter:_pointP radius:_r2 startAngle:(M_PI * ((90 + temC)/180)) endAngle:(M_PI * ((180 - _a)/180)) clockwise:YES];
        [vocalnoPath addArcWithCenter:CGPointMake(_pointP.x, _pointO.y + (_pointO.y - _pointP.y)) radius:_r2 startAngle:((180 + _a)/180 *M_PI) endAngle:(((270 - temC)/180) *M_PI) clockwise:YES];
    }
    else if(_dynamic_Q2_d <= _uber_w)
    {
        double temC = atan((_pointP.x - _pointO.x - _dynamic_Q2_d)/(_pointO.y - _pointP.y))*180/M_PI;
        
        [vocalnoPath addArcWithCenter:_pointP radius:_r2 startAngle:(0.5 * M_PI) endAngle:(((90 + temC)/180) * M_PI) clockwise:YES];
        [vocalnoPath addArcWithCenter:CGPointMake(_pointP.x, _pointO.y + (_pointO.y - _pointP.y)) radius:_r2 startAngle:((270 - temC)/180 *M_PI) endAngle:(1.5 *M_PI) clockwise:YES];
    }
    else if (_dynamic_Q_d >= _tube_w + _uber_w && _dynamic_Q2_d <= _tube_w + _uber_w )
    {
        //左滑到右，另一边的火山形状
        double temC = atan(((_pointQ.x - _pointO.x) - _uber_w - _tube_w)/(_pointO.y - _pointP.y))*180/M_PI;
        
        [vocalnoPath addArcWithCenter:_pointP2 radius:_r2 startAngle:(((90 - temC)/180) * M_PI) endAngle:(M_PI * 0.5) clockwise:YES];
        [vocalnoPath addArcWithCenter:CGPointMake(_pointP2.x, _pointO.y + (_pointO.y - _pointP.y)) radius:_r2 startAngle:(1.5 * M_PI) endAngle:(((270 + temC)/180) * M_PI) clockwise:YES];
    }
    else if (_dynamic_Q2_d < _uber_w + _tube_w + _uber_w && _dynamic_Q2_d >= _uber_w + _tube_w )
    {
        double temC = atan((_pointQ2.x - _pointP2.x)/(_pointO.y - _pointP.y))*180/M_PI;
        [vocalnoPath addArcWithCenter:_pointP2 radius:_r2 startAngle:(((_a)/180) * M_PI) endAngle:(M_PI * ((90 - temC)/180)) clockwise:YES];
        [vocalnoPath addArcWithCenter:CGPointMake(_pointP2.x, _pointO.y + (_pointO.y - _pointP.y)) radius:_r2 startAngle:(((270 + temC)/180) * M_PI) endAngle:(((360 - _a)/180) * M_PI) clockwise:YES];
    }
    self.volcanoShape.path = vocalnoPath.CGPath;
    
    //-------------------------------------------rightSemiCircle(右边圆形状)-----------------------------------------
    
    UIBezierPath *semiPath = [UIBezierPath bezierPath];
    
    if (_dynamic_Q_d <= _uber_w + _tube_w + _uber_w) {
        [semiPath addArcWithCenter:CGPointMake(_pointQ.x , _pointQ.y) radius:r3 startAngle:(0 * M_PI) endAngle:(2*M_PI) clockwise:YES];
    }else{
        [semiPath addArcWithCenter:CGPointMake(_pointO2.x , _pointQ.y) radius:r3 startAngle:(0 * M_PI) endAngle:(2*M_PI) clockwise:YES];
    }
    
    self.rightCircleShape.path  = semiPath.CGPath;
    
    //----------------------------------------tailCircleShape(完全进入时左圆形状)-----------------------------------------
    
    UIBezierPath *leftPath = [UIBezierPath bezierPath];
    if (_d <= _mainRect_w)
    {
        [leftPath addArcWithCenter:_pointO radius:_r1 startAngle:(0 * M_PI) endAngle:(2.0 * M_PI) clockwise:YES];
    }
    else if(_dynamic_Q2_d <= _uber_w)
    {
        double temC = atan((_pointP.x - _pointO.x - _dynamic_Q2_d)/(_pointO.y - _pointP.y))*180/M_PI;
        double temR3 = (_pointO.y - _pointP.y)/cosx(temC) - _r2;
        [leftPath addArcWithCenter:_pointQ2 radius:temR3 startAngle:(0 * M_PI) endAngle:(2.0 * M_PI) clockwise:YES];
    }
    else if (_dynamic_Q2_d <= _uber_w + _tube_w)
    {
        CGPoint tem_pointQ = CGPointMake(_pointO.x + _dynamic_Q2_d, _pointO.y);
        [leftPath addArcWithCenter:tem_pointQ radius:_tube_h/2 startAngle:(0 * M_PI) endAngle:(2.0 * M_PI) clockwise:YES];
    }
    else if (_dynamic_Q2_d <= _uber_w + _tube_w + _uber_w)
    {
        double temC = atan(((_pointQ2.x - _pointO.x) - _uber_w - _tube_w)/(_pointO.y - _pointP.y))*180/M_PI;
        double temR3 = (_pointO.y - _pointP.y)/cosx(temC) - _r2;
        [leftPath addArcWithCenter:_pointQ2 radius:temR3 startAngle:(0 * M_PI) endAngle:(2.0 * M_PI) clockwise:YES];
    }
    self.tailCircleShape.path = leftPath.CGPath;
    
    
    //---------------------------------------------recPath(管道形状)-----------------------------------------
    
    UIBezierPath *recPath = [UIBezierPath bezierPath];
    
    if(_d <= _tube_w + _uber_w)
    {
        [recPath moveToPoint:CGPointMake(_pointQ2.x , _pointC.y)];
        [recPath addLineToPoint:CGPointMake(_pointQ2.x , _pointD.y)];
        [recPath addLineToPoint:CGPointMake(_pointQ.x, _pointD.y)];
        [recPath addLineToPoint:CGPointMake(_pointQ.x, _pointC.y)];
        [recPath addLineToPoint:_pointC];
        [recPath closePath];
    }else {
        recPath = [UIBezierPath bezierPath];
    }
    self.tubeShape.path = recPath.CGPath;
    
    //------------------------------------------------设置绘制标示----------------------------------------------
    
    [self.leftSemiShape setNeedsDisplay];
    [self.maintubeShape setNeedsDisplay];
    [self.volcanoShape setNeedsDisplay];
    [self.rightCircleShape setNeedsDisplay];
    [self.tubeShape setNeedsDisplay];
    [self.tailCircleShape setNeedsDisplay];
}


#pragma mark - mine 

- (void) initData {
    
    R = self.frame.size.height/2 - 4;
    r = R/2;
    _a = 27;
    O1 = CGPointMake(R, self.frame.size.height/2);
    O2 = CGPointMake(R+R*2, self.frame.size.height/2);
    
    //左方右上角圆心
    O5 = CGPointMake(O2.x + 1.5*R*cosx(_a)  , O2.y - 1.5*R*sinx(_a));
    O6 = CGPointMake(O2.x + 1.5*R*cosx(_a)  , O2.y + 1.5*R*sinx(_a));
}

- (void) drawLeftShapes {

    CGRect frame = CGRectMake(0, 0, 270, self.frame.size.height);
    UIColor *color = RGB(225, 65, 67);
    
    //----------------------------------------leftSemiShape(左圆形状)-----------------------------------------
    UIBezierPath *leftSemiPath = [UIBezierPath bezierPath];
    [leftSemiPath addArcWithCenter:O1 radius:R startAngle:(0.5 * M_PI) endAngle:(1.5 * M_PI) clockwise:YES];
    XQShapeLayer *leftSemiShape = [[XQShapeLayer alloc]initWithFrame:frame Color:color Path:leftSemiPath];
    [self.layer addSublayer:leftSemiShape];
    
    
    //----------------------------------------maintubeShape(主体矩形形状)--------------------------------------
    UIBezierPath *mainRecPath = [UIBezierPath bezierPath];
    [mainRecPath moveToPoint:CGPointMake(O1.x, O1.y - R)];
    [mainRecPath addLineToPoint:CGPointMake(O1.x, O1.y + R)];
    [mainRecPath addLineToPoint:CGPointMake(O2.x , O2.y+R)];
    [mainRecPath addLineToPoint:CGPointMake(O2.x, O2.y - R)];
    
    XQShapeLayer *maintubeShape = [[XQShapeLayer alloc]initWithFrame:frame Color:color Path:mainRecPath];
    [self.layer addSublayer:maintubeShape];
    
    //-----------------------------------------rightSemiShape(右圆形状)----------------------------------------
    UIBezierPath *rightSemiPath = [UIBezierPath bezierPath];
    [rightSemiPath addArcWithCenter:O2 radius:R startAngle:(1.5 * M_PI) endAngle:(0.5 * M_PI) clockwise:YES];
    
    XQShapeLayer *rightSemiShape = [[XQShapeLayer alloc]initWithFrame:frame Color:color Path:rightSemiPath];
    [self.layer addSublayer:rightSemiShape];
    
    //-------------------------------------------volcanoPath(火山形状)-----------------------------------------
    UIBezierPath *vocalnoPath = [UIBezierPath bezierPath];
    [vocalnoPath addArcWithCenter:O5 radius:r startAngle:(M_PI * 0.5) endAngle:(M_PI * ((180 - _a)/180)) clockwise:YES];
    [vocalnoPath addArcWithCenter:O6 radius:r startAngle:((180 + _a)/180 *M_PI) endAngle:(1.5 *M_PI) clockwise:YES];
    
    XQShapeLayer *vocalnoShape = [[XQShapeLayer alloc]initWithFrame:frame Color:color Path:vocalnoPath];
    [self.layer addSublayer:vocalnoShape];
    
    
}


@end
