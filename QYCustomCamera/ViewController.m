//
//  ViewController.m
//  QYCustomCamera
//
//  Created by Zhang jiyong on 2018/6/13.
//  Copyright © 2018年 PasserbyQ. All rights reserved.
//

#import "ViewController.h"
#import "QYCustomCameraVC.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)takePhoto:(id)sender {
    QYCustomCameraVC *vc = [[QYCustomCameraVC alloc]init];
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
