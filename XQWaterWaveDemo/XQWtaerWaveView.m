//
//  XQWtaerWaveView.m
//  XQWaterWaveDemo
//
//  Created by kang on 2016/10/14.
//  Copyright © 2016年 kang. All rights reserved.
//

#import "XQWtaerWaveView.h"

#define colorWithRGB(r,g,b,a) [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a]

@interface XQWtaerWaveView ()

@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic,strong) CAShapeLayer *waveShapeLayer;


@end

@implementation XQWtaerWaveView
{
    CGFloat _waveAmplitude;      //!< 振幅
    CGFloat _waveCycle;          //!< 周期
    CGFloat _waveSpeed;          //!< 速度
    CGFloat _waterWaveHeight;
    CGFloat _waterWaveWidth;
    CGFloat _wavePointY;
    CGFloat _waveOffsetX;            //!< 波浪x位移
    UIColor *_waveColor;             //!< 波浪颜色
    
    CGFloat _waveSpeed2;
}


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = colorWithRGB(251, 91, 91,1);
        self.layer.masksToBounds = YES;
        
        [self ConfigParams];
        
        [self drawWaveLayer];
    }
    return self;
}



#pragma mark - 配置参数
- (void)ConfigParams
{
    _waterWaveWidth = self.frame.size.width;
    _waterWaveHeight = 200;
    _waveColor = colorWithRGB(38, 53, 94,0.8);
    _waveSpeed = 0.25/M_PI;
    _waveSpeed2 = 0.3/M_PI;
    _waveOffsetX = 0;
    _wavePointY = _waterWaveHeight - 50;
    _waveAmplitude = 13;
    _waveCycle =  1.29 * M_PI / _waterWaveWidth;
}

#pragma mark - 加载layer ，绑定runloop 帧刷新
- (void)drawWaveLayer
{
    [self.layer addSublayer:self.waveShapeLayer];
    [self setWaveShapeLayerPath];
}


#pragma mark 三个shapeLayer动画
- (void)setWaveShapeLayerPath
{
    CGMutablePathRef path = CGPathCreateMutable();
    CGFloat y = _wavePointY;
    CGPathMoveToPoint(path, nil, 0, y);
    for (float x = 0.0f; x <= _waterWaveWidth; x ++) {
        y = _waveAmplitude * sin(_waveCycle * x + _waveOffsetX - 10) + _wavePointY + 10;
        CGPathAddLineToPoint(path, nil, x, y);
    }
    
    CGPathAddLineToPoint(path, nil, _waterWaveWidth, self.frame.size.height);
    CGPathAddLineToPoint(path, nil, 0, self.frame.size.height);
    CGPathCloseSubpath(path);
    
    self.waveShapeLayer.path = path;
    
    CGPathRelease(path);
}



#pragma mark - Get
- (CAShapeLayer *)waveShapeLayer
{
    if (!_waveShapeLayer) {
        _waveShapeLayer = [CAShapeLayer layer];
        _waveShapeLayer.fillColor = [_waveColor CGColor];
    }
    return _waveShapeLayer;
}

- (CADisplayLink *)displayLink
{
    if (!_displayLink) {
        _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(getCurrentWave)];
    }
    return _displayLink;
}

#pragma mark - Response
- (void)getCurrentWave
{
    _waveOffsetX += _waveSpeed *(1 + (arc4random() % (3)))/1.2;
    [self setWaveShapeLayerPath];
}

- (void) pause {
    [self.displayLink removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

- (void) resume {
    [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

#pragma mark - button response

- (void) startAnimation:(id) sender {
    
    [self resume];
    [super startAnimation:sender];
    
}

- (void) resumeAnimation:(id) sender {
    [self resume];
    [super resumeAnimation:sender];
}

- (void) pauseAnimation:(id) sender {
    [self pause];
    [super pauseAnimation:sender];
}


@end
