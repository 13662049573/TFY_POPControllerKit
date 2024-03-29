//
//  CatViewController.m
//  TFY_Navigation
//
//  Created by 田风有 on 2020/8/23.
//  Copyright © 2020 恋机科技. All rights reserved.
//

#import "CatViewController.h"

@interface CatViewController ()

@end

@implementation CatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];

    self.navigationItem.title = @"Cat";
    
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"left"] style:UIBarButtonItemStylePlain target:self action:@selector(imageClick)];
    
    self.contentSizeInPop = CGSizeMake(CGRectGetWidth([UIScreen mainScreen].bounds) - 60, 330);
    self.contentSizeInPopWhenLandscape = CGSizeMake(315, 300);

    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_cat"]];

    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:@"Dismiss" forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont boldSystemFontOfSize:30];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(didTapToDismiss) forControlEvents:UIControlEventTouchUpInside];
    button.backgroundColor = [UIColor colorWithRed:0.000 green:0.590 blue:1.000 alpha:1.00];
    button.layer.masksToBounds = YES;
    button.layer.cornerRadius = 6.f;

    [self.view addSubview:imageView];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(30);
        make.center.equalTo(self.view).offset(0);
    }];
    
    [self.view addSubview:button];
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(15);
        make.right.bottom.equalTo(self.view).offset(-15);
        make.height.mas_equalTo(60);
    }];
}
- (void)imageClick {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didTapToDismiss {
    [self dismissViewControllerAnimated:YES completion:NULL];
}
@end
