//
//  POP_FourController.m
//  TFY_Navigation
//
//  Created by 田风有 on 2020/8/23.
//  Copyright © 2020 恋机科技. All rights reserved.
//

#import "POP_FourController.h"

@interface POP_FourController ()

@end

@implementation POP_FourController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.contentSizeInPop = CGSizeMake([UIScreen mainScreen].bounds.size.width - 50, 88);
    self.view.backgroundColor = [UIColor colorWithRed:0.397 green:0.859 blue:0.066 alpha:1.00];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapToDismiss)];
    [self.view addGestureRecognizer:tapGestureRecognizer];

    UILabel *label = [UILabel new];
    label.text = @"ME, Like a Notification";
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];

    [self.view addSubview:label];
    
    label.tfy_Center(0, 0).tfy_size(200, 40);
}

- (void)didTapToDismiss {
    [self.popController dismiss];
}


@end
