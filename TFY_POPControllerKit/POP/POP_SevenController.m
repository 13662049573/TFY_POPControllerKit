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
    
    [self.view addSubview:self.contentView];
    [self.contentView addSubview:self.label];
    [self.contentView addSubview:self.growButton];

    self.contentView.tfy_LeftSpace(0).tfy_TopSpace(0).tfy_BottomSpace(0).tfy_Width(self.contentSizeInPop.width);
    
    self.label.tfy_LeftSpace(15).tfy_RightSpace(15).tfy_TopSpace(10).tfy_HeightAuto();
    
    self.growButton.tfy_LeftSpace(15).tfy_RightSpace(15).tfy_Height(50).tfy_TopSpaceToView(20, self.label);
    
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
