//
//  TRViewController.m
//  TRUI
//
//  Created by Mac on 2020/4/22.
//  Copyright © 2020 Mac. All rights reserved.
//

#import "TRViewController.h"
#import "TRUILog.h"

@interface TRViewController ()

@end

@implementation TRViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor redColor];
    
    TRUILog(@"测试",@"这是一个测试");
}

@end
