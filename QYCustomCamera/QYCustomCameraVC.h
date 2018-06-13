//
//  QYCustomCameraVC.h
//  QYCustomCamera
//
//  Created by Zhang jiyong on 2018/6/13.
//  Copyright © 2018年 PasserbyQ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QYCustomCameraVC : UIViewController
//完成采集回调
@property(nonatomic , strong) void(^finishBlock)(UIImage *image);
//界面消失回调
@property(nonatomic , strong) void(^dismissBlock)();

@end
