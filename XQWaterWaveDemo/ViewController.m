//
//  ViewController.m
//  XQWaterWaveDemo
//
//  Created by kang on 2016/10/14.
//  Copyright © 2016年 kang. All rights reserved.
//

#import "ViewController.h"
#import "XQWtaerWaveView.h"
#import "XQCGPathView.h"
#import "XQTubeView.h"

@interface ViewController ()
@property (nonatomic, strong) XQWtaerWaveView *waterWaveView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self setWaterWaveView];
    
    [self setTubeView];
    
//    [self drawPath];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void) setWaterWaveView
{
    _waterWaveView = [[XQWtaerWaveView alloc]initWithFrame:CGRectMake(0, 75, self.view.frame.size.width, 200)];
    [self.view addSubview:_waterWaveView];
}

- (void) setTubeView {

    XQTubeView *tubeView = [[XQTubeView alloc]initWithFrame:CGRectMake(0, 375, self.view.frame.size.width, 200)];
    [self.view addSubview:tubeView];
}

- (void) drawPath {

    XQCGPathView *pathView  = [[XQCGPathView alloc]initWithFrame:CGRectMake(0, 375, self.view.frame.size.width, 200)];
    pathView.backgroundColor = [UIColor colorWithRed:251/255.0f green:91/255.0f blue:91/255.0f alpha:1];
    [self.view addSubview:pathView];
    
}





@end
