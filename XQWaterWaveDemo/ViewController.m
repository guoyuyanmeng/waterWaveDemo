//
//  ViewController.m
//  XQWaterWaveDemo
//
//  Created by kang on 2016/10/14.
//  Copyright © 2016年 kang. All rights reserved.
//

#import "ViewController.h"
#import "XQWtaerWaveView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self setUp];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)setUp
{
    XQWtaerWaveView *waterWaveView = [[XQWtaerWaveView alloc]initWithFrame:CGRectMake(0, 200, self.view.frame.size.width, 200)];
    [self.view addSubview:waterWaveView];
}


@end
