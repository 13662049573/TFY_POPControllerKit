//
//  POP_FiveController.m
//  TFY_Navigation
//
//  Created by 田风有 on 2020/8/23.
//  Copyright © 2020 恋机科技. All rights reserved.
//

#import "POP_FiveController.h"

@interface POP_FiveController ()
@property (nonatomic, strong) UIView *centerDialog;
@property (nonatomic, strong) UILabel *tipsLabel;
@property (nonatomic, strong) UIButton *closeButton;
@end

@implementation POP_FiveController

- (void)viewDidLoad {
    [super viewDidLoad];
     self.contentSizeInPop = [UIScreen mainScreen].bounds.size;
       self.popController.containerView.backgroundColor = [UIColor clearColor];
       [self setupView];
}

- (void)setupView {
    [self.view addSubview:self.centerDialog];
    [self.centerDialog addSubview:self.tipsLabel];
    [self.view addSubview:self.closeButton];
    [self setupViewConstraints];
}

- (void)setupViewConstraints {
    self.centerDialog.tfy_LeftSpace(30).tfy_RightSpace(30).tfy_CenterY(0).tfy_Height(300);
    
    self.tipsLabel.tfy_Center(0, 0).tfy_size(200, 30);
    
    self.closeButton.tfy_CenterX(0).tfy_TopSpaceToView(30, self.centerDialog).tfy_size(60, 60);
    
}

- (void)didTapToClose {
    [self dismissViewControllerAnimated:YES completion:^{

    }];
}

#pragma mark - Getter

- (UIView *)centerDialog {
    if (!_centerDialog) {
        _centerDialog = [UIView new];
        _centerDialog.backgroundColor = [UIColor colorWithRed:0.448 green:0.846 blue:0.906 alpha:1.00];
        _centerDialog.layer.cornerRadius = 6;
    }
    return _centerDialog;
}

- (UILabel *)tipsLabel {
    if (!_tipsLabel) {
        _tipsLabel = [UILabel new];
        _tipsLabel.textColor = [UIColor whiteColor];
        _tipsLabel.textAlignment = NSTextAlignmentCenter;
        _tipsLabel.font = [UIFont boldSystemFontOfSize:20];
        _tipsLabel.text = @"Make your own UI.";
    }
    return _tipsLabel;
}

- (UIButton *)closeButton {
    if (!_closeButton) {
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeButton setImage:[UIImage imageNamed:@"btn_close_circle_white"] forState:UIControlStateNormal];
        [_closeButton addTarget:self action:@selector(didTapToClose) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeButton;
}


@end
