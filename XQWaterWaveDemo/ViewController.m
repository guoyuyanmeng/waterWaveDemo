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
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self setUp];
    
    [self drawPath];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void)setUp
{
    XQWtaerWaveView *waterWaveView = [[XQWtaerWaveView alloc]initWithFrame:CGRectMake(0, 100, self.view.frame.size.width, 200)];
    [self.view addSubview:waterWaveView];
}


- (void) drawPath {

    XQCGPathView *pathView  = [[XQCGPathView alloc]initWithFrame:CGRectMake(([UIScreen mainScreen].bounds.size.width - 200)/2, 350, 200, 200)];
    [self.view addSubview:pathView];
    
}


@end
