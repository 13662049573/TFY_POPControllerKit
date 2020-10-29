//
//  POP_TwoController.h
//  TFY_Navigation
//
//  Created by 田风有 on 2020/8/23.
//  Copyright © 2020 恋机科技. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

static inline NSString *stringWithPopType(PopType popType) {
    NSArray *array = @[@"None", @"FadeIn", @"GroupIn", @"ShrinkIn", @"SlideInFromTop", @"SlideInFromBottom", @"SlideInFromLeft", @"SlideInFromRight", @"BounceIn", @"BounceInFromTop", @"BounceInFromBottom", @"BounceInFromLeft", @"BounceInFromRight"];
    return array[popType];
}

static inline NSString *stringWithDismissType(DismissType dismissType) {
    NSArray *array = @[@"None", @"FadeOut", @"GroupOut", @"ShrinkOut", @"SlideOutFromTop", @"SlideOutFromBottom", @"SlideOutFromLeft", @"SlideOutFromRight", @"BounceOut", @"BounceOutFromTop", @"BounceOutFromBottom", @"BounceOutFromLeft", @"BounceOutFromRight"];
    return array[dismissType];
}

static inline NSString *stringWithPositionType(PopPosition position) {
    NSArray *array = @[@"Center", @"Top", @"Bottom"];
    return array[position];
}


@interface POP_TwoController : UIViewController

@end

NS_ASSUME_NONNULL_END
