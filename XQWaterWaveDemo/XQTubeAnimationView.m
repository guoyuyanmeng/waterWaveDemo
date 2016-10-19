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

@property (nonatomic, assign) double a;                             /// 大圆、小圆圆心连线与x轴的夹角
@property (nonatomic, assign) double increment;                     /// d的增量，如每帧移动4point
@property (nonatomic, assign) double uber_w;                        /// 挤压完成，开始拉伸的距离
@property (nonatomic, assign) double uber_rate;                     /// uber_w段中的速率，默认1.5x
@property (nonatomic, assign) double tube_w;                        /// 挤压开始，到达出口的距离，即管道长度
@property (nonatomic, assign) double tube_rate;                     /// tube_w 段中的速率，默认3x
@property (nonatomic, assign) double mainRect_w;                    /// 主体矩形的宽度


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
        
        

        [self initParams];
        
        [self setBaseShape];
    }
    return self;
}


- (void)initParams
{
    _finished = NO;
    
    _r1 = self.frame.size.height/2 - 4;
    _r2 = _r1/2;
    _a = 27.0;      //角度制
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




@end
