//
//  POP_NavViewController.m
//  TFY_Navigation
//
//  Created by 田风有 on 2020/8/23.
//  Copyright © 2020 恋机科技. All rights reserved.
//

#import "POP_NavViewController.h"

@interface POP_NavViewController ()

@end

@implementation POP_NavViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    self.contentSizeInPop = CGSizeMake(screenSize.width - 60, screenSize.height * 0.6);
    self.contentSizeInPopWhenLandscape = CGSizeMake(screenSize.height - 100, screenSize.width * 0.6);
    
    self.navigationBar.translucent = NO;
}


@end
