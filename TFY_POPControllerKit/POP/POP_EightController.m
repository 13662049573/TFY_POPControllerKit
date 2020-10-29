//
//  POP_EightController.m
//  TFY_Navigation
//
//  Created by 田风有 on 2020/8/23.
//  Copyright © 2020 恋机科技. All rights reserved.
//

#import "POP_EightController.h"
#import "CatViewController.h"

@interface POP_EightController ()
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *nextButton;
@end

@implementation POP_EightController

- (void)viewDidLoad {
    [super viewDidLoad];
     NSInteger index = [self.navigationController.viewControllers indexOfObject:self];
       self.navigationItem.title = [NSString stringWithFormat:@"Page %ld", (long)index + 1];
       if (self.navigationController.viewControllers.count > 1) {
           UIBarButtonItem *closeItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(closeAction)];
           self.navigationItem.rightBarButtonItem = closeItem;
       }

       [self setupView];
}

- (void)loadView {
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor whiteColor];
    self.view = view;
}

- (void)setupView {
    [self.view addSubview:self.titleLabel];
    [self.view addSubview:[self nextButton]];
    [self setupViewConstraints];
}

- (void)setupViewConstraints {
   
    self.titleLabel.tfy_LeftSpace(10).tfy_RightSpace(10).tfy_CenterY(0).tfy_HeightAuto();

    self.nextButton.tfy_LeftSpace(0).tfy_RightSpace(0).tfy_BottomSpace(0).tfy_Height(55);
}

#pragma mark - touch action

- (void)nextPage {
    CatViewController *catViewController = [CatViewController new];
    [self.navigationController pushViewController:catViewController animated:YES];
}

- (void)closeAction {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

#pragma mark - Getter

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [UILabel new];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.text = @"When you use UINavigationController in HWPopController, You can dynamic change the pop size.";
        _titleLabel.numberOfLines = 0;

    }
    return _titleLabel;
}

- (UIButton *)nextButton {
    if (!_nextButton) {
        _nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_nextButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_nextButton setTitle:@"Next" forState:UIControlStateNormal];
        [_nextButton setBackgroundColor:[UIColor colorWithRed:0.000 green:0.590 blue:1.000 alpha:1.00]];
        _nextButton.titleLabel.font = [UIFont boldSystemFontOfSize:20];
        _nextButton.layer.masksToBounds = YES;
        _nextButton.layer.cornerRadius = 6;
        [_nextButton addTarget:self action:@selector(nextPage) forControlEvents:UIControlEventTouchUpInside];
    }
    return _nextButton;
}

@end
