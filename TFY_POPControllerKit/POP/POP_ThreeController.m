//
//  POP_ThreeController.m
//  TFY_Navigation
//
//  Created by 田风有 on 2020/8/23.
//  Copyright © 2020 恋机科技. All rights reserved.
//

#import "POP_ThreeController.h"

@interface POP_ThreeController ()
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UIButton *confirmButton;
@property (nonatomic, strong) UILabel *tipLabel;
@end

@implementation POP_ThreeController

- (void)viewDidLoad {
    [super viewDidLoad];
    CGRect screenFrame = [UIScreen mainScreen].bounds;
    self.contentSizeInPop = CGSizeMake(CGRectGetWidth(screenFrame) - 40, CGRectGetHeight(screenFrame) * 0.6);
    [self setupView];
}

- (void)setupView {
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.closeButton];
    [self.view addSubview:self.tipLabel];
    [self.view addSubview:self.confirmButton];

    [self setupViewConstraints];
}

- (void)setupViewConstraints {
    self.confirmButton.tfy_LeftSpace(30).tfy_RightSpace(30).tfy_BottomSpace(15).tfy_Height(60);
    
    self.closeButton.tfy_RightSpace(5).tfy_TopSpace(5).tfy_size(30, 30);
   
    self.tipLabel.tfy_LeftSpace(15).tfy_RightSpace(15).tfy_CenterY(0).tfy_Height(40);

}

- (void)dismiss {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Getter

- (UIButton *)closeButton {
    if (!_closeButton) {
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeButton setImage:[UIImage imageNamed:@"btn_close_black"] forState:UIControlStateNormal];
        [_closeButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeButton;
}

- (UIButton *)confirmButton {
    if (!_confirmButton) {
        _confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_confirmButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_confirmButton setTitle:@"Confirm" forState:UIControlStateNormal];
        [_confirmButton setBackgroundColor:[UIColor colorWithRed:0.000 green:0.590 blue:1.000 alpha:1.00]];
        _confirmButton.titleLabel.font = [UIFont boldSystemFontOfSize:30];
        _confirmButton.layer.masksToBounds = YES;
        _confirmButton.layer.cornerRadius = 6;
        [_confirmButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    }
    return _confirmButton;
}

- (UILabel *)tipLabel {
    if (!_tipLabel) {
        _tipLabel = [UILabel new];
        _tipLabel.text = @"Allow App to use you Camera.";
        _tipLabel.font = [UIFont boldSystemFontOfSize:24];
        _tipLabel.textAlignment = NSTextAlignmentCenter;
        _tipLabel.numberOfLines = 0;
    }
    return _tipLabel;
}



@end
