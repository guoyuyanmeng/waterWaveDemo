//
//  XQBaseView.h
//  XQWaterWaveDemo
//
//  Created by kang on 2016/10/18.
//  Copyright © 2016年 kang. All rights reserved.
//

#import <UIKit/UIKit.h>

#define colorWithRGB(r,g,b,a) [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a]

@interface XQBaseView : UIView

- (void) startAnimation:(id) sender;

- (void) resumeAnimation:(id) sender;

- (void) pauseAnimation:(id) sender;

@end
