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
    
    self.closeButton.makeChain
    .addToSuperView(self.view)
    .makeMasonry(^(MASConstraintMaker * _Nonnull make) {
        make.left.equalTo(self.view).offset(30);
        make.right.equalTo(self.view).offset(-30);
        make.bottom.equalTo(self.view).offset(-15);
        make.height.mas_equalTo(60);
    });
    
    self.tipLabel.makeChain
    .addToSuperView(self.view)
    .makeMasonry(^(MASConstraintMaker * _Nonnull make) {
        make.left.equalTo(self.view).offset(15);
        make.right.equalTo(self.view).offset(-15);
        make.centerY.equalTo(self.view).offset(0);
        make.height.mas_equalTo(40);
    });
    
     self.confirmButton.makeChain
    .addToSuperView(self.view)
    .makeMasonry(^(MASConstraintMaker * _Nonnull make) {
        make.left.equalTo(self.view).offset(30);
        make.right.equalTo(self.view).offset(-30);
        make.bottom.equalTo(self.view).offset(-15);
        make.height.mas_equalTo(40);
    });

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
