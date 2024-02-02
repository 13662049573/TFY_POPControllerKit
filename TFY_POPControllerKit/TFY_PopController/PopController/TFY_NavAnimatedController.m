//
//  TFY_NavAnimatedController.m
//  TFY_Navigation
//
//  Created by 田风有 on 2020/10/26.
//  Copyright © 2020 浙江日报集团. All rights reserved.
//

#import "TFY_NavAnimatedController.h"
#import "TFY_NavAnimatedTransitioning.h"
#import "UIViewController+TFY_PopController.h"

@interface TFY_NavAnimatedController ()<UINavigationControllerDelegate>
@property (nonatomic, strong) TFY_NavAnimatedTransitioning *animatedTransitioning;
@property (nonatomic, assign) CGSize originContentSizeInPop;
@property (nonatomic, assign) CGSize originContentSizeInPopWhenLandscape;
@end

@implementation TFY_NavAnimatedController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.originContentSizeInPop = self.contentSizeInPop;
    self.originContentSizeInPopWhenLandscape = self.contentSizeInPopWhenLandscape;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.delegate = self;
}

- (void)adjustContentSizeBy:(UIViewController *)controller {
    switch ([UIApplication sharedApplication].windows.firstObject.windowScene.interfaceOrientation) {
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight: {
            CGSize contentSize = controller.contentSizeInPopWhenLandscape;
            if (!CGSizeEqualToSize(contentSize, CGSizeZero)) {
                self.contentSizeInPopWhenLandscape = contentSize;
            } else {
                self.contentSizeInPopWhenLandscape = self.originContentSizeInPopWhenLandscape;
            }
        }
            break;
        default: {
            CGSize contentSize = controller.contentSizeInPop;
            if (!CGSizeEqualToSize(contentSize, CGSizeZero)) {
                self.contentSizeInPop = contentSize;
            } else {
                self.contentSizeInPop = self.originContentSizeInPop;
            }
        }
            break;
    }

}

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC {
    [toVC view];
    [self adjustContentSizeBy:toVC];
    self.animatedTransitioning.state = operation == UINavigationControllerOperationPush ? PopStatePop : PopStateDismiss;
    return self.animatedTransitioning;
}

- (TFY_NavAnimatedTransitioning *)animatedTransitioning {
    if (!_animatedTransitioning) {
        _animatedTransitioning = [[TFY_NavAnimatedTransitioning alloc] initWithState:PopStatePop];
    }
    return _animatedTransitioning;
}
@end
