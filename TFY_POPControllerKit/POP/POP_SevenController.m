//
//  POP_SevenController.m
//  TFY_Navigation
//
//  Created by 田风有 on 2020/8/23.
//  Copyright © 2020 恋机科技. All rights reserved.
//

#import "POP_SevenController.h"

@interface POP_SevenController ()
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UIButton *growButton;
@end

@implementation POP_SevenController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.contentSizeInPop = CGSizeMake([UIScreen mainScreen].bounds.size.width - 80, 150);
    
    self.contentView.makeChain
    .addToSuperView(self.view)
    .makeMasonry(^(MASConstraintMaker * _Nonnull make) {
        make.left.top.bottom.equalTo(self.view).offset(0);
        make.width.mas_equalTo(self.contentSizeInPop.width);
    });
    
    self.label.makeChain
    .addToSuperView(self.view)
    .makeMasonry(^(MASConstraintMaker * _Nonnull make) {
        make.left.equalTo(self.view).offset(15);
        make.right.equalTo(self.view).offset(-15);
        make.top.equalTo(self.view).offset(10);
        make.height.mas_greaterThanOrEqualTo(0);
    });
    
    [self.contentView addSubview:self.growButton];
    self.growButton.makeChain
    .addToSuperView(self.contentView)
    .makeMasonry(^(MASConstraintMaker * _Nonnull make) {
        make.left.equalTo(self.view).offset(15);
        make.right.equalTo(self.view).offset(-15);
        make.height.mas_equalTo(50);
        make.top.equalTo(self.label.mas_bottom).offset(20);
    });

    [self.view layoutIfNeeded];
    
    CGFloat height = CGRectGetMaxY(self.growButton.frame) + 10;
    
    self.contentSizeInPop = CGSizeMake(self.contentSizeInPop.width, height);
}

- (void)growAction {
    self.label.text = [NSString stringWithFormat:@"%@%@", self.label.text, @"\nShow Me the Code."];

    [self.view layoutIfNeeded];
    CGFloat height = CGRectGetMaxY(self.growButton.frame) + 10;
    self.contentSizeInPop = CGSizeMake(self.contentSizeInPop.width, height);
}

#pragma mark - Getter

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [UIView new];
    }
    
    return _contentView;
}

- (UILabel *)label {
    if (!_label) {
        _label = [UILabel new];
        _label.textAlignment = NSTextAlignmentCenter;
        _label.numberOfLines = 0;
        _label.text = @"The UIViewController class defines the shared behavior that is common to all view controllers. You rarely create instances of the UIViewController class directly. Instead, you subclass UIViewController and add the methods and properties needed to manage the view controller's view hierarchy.";
    }
    return _label;
}

- (UIButton *)growButton {
    if (!_growButton) {
        _growButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_growButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_growButton setTitle:@"Grow" forState:UIControlStateNormal];
        [_growButton setBackgroundColor:[UIColor colorWithRed:0.000 green:0.590 blue:1.000 alpha:1.00]];
        _growButton.titleLabel.font = [UIFont boldSystemFontOfSize:20];
        _growButton.layer.masksToBounds = YES;
        _growButton.layer.cornerRadius = 6;
        [_growButton addTarget:self action:@selector(growAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _growButton;
}

@end
