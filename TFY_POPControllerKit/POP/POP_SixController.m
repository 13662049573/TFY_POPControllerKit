//
//  POP_SixController.m
//  TFY_Navigation
//
//  Created by 田风有 on 2020/8/23.
//  Copyright © 2020 恋机科技. All rights reserved.
//

#import "POP_SixController.h"

@interface POP_SixController ()
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *doneButton;
@property (nonatomic, strong) UIButton *cancelButton;
@end

@implementation POP_SixController

- (void)viewDidLoad {
    [super viewDidLoad];
 
    self.contentSizeInPop = CGSizeMake(220, 100);
    self.view.backgroundColor = [UIColor whiteColor];

    [self setupView];
}


- (void)setupView {
    [self.view addSubview:self.titleLabel];
    [self.view addSubview:self.cancelButton];
    [self.view addSubview:self.doneButton];
    [self setupViewConstraints];
}

- (void)setupViewConstraints {
    self.titleLabel.tfy_CenterX(0).tfy_TopSpace(10).tfy_size(200, 30);
    
    self.cancelButton.tfy_size(80, 40).tfy_BottomSpace(10).tfy_LeftSpace(8);
    
    self.doneButton.tfy_LeftSpaceToView(20, self.cancelButton).tfy_BottomSpaceEqualView(self.cancelButton).tfy_RightSpace(8);
}

- (void)didTapToDismiss {
    [self.popController dismiss];
}

#pragma mark - Getter

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [UILabel new];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = [UIFont systemFontOfSize:16];
        _titleLabel.text = @"Show Me The Code!";
    }
    return _titleLabel;
}

- (UIButton *)doneButton {
    if (!_doneButton) {
        _doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_doneButton setTitle:@"OK" forState:UIControlStateNormal];
        [_doneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_doneButton setBackgroundColor:[UIColor colorWithRed:0.000 green:0.588 blue:1.000 alpha:1.00]];
        _doneButton.layer.cornerRadius = 4;
        _doneButton.layer.masksToBounds = YES;
        [_doneButton addTarget:self action:@selector(didTapToDismiss) forControlEvents:UIControlEventTouchUpInside];
    }
    return _doneButton;
}

- (UIButton *)cancelButton {
    if (!_cancelButton) {
        _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
        [_cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_cancelButton setBackgroundColor:[UIColor colorWithRed:0.000 green:0.588 blue:1.000 alpha:1.00]];
        _cancelButton.layer.cornerRadius = 4;
        _cancelButton.layer.masksToBounds = YES;
        [_cancelButton addTarget:self action:@selector(didTapToDismiss) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelButton;
}


@end
