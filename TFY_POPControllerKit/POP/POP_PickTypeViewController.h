//
//  POP_PickTypeViewController.h
//  TFY_Navigation
//
//  Created by 田风有 on 2020/8/23.
//  Copyright © 2020 恋机科技. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class POP_PickTypeViewController;

typedef NS_ENUM(NSInteger, PickType) {
    PickTypePop,
    PickTypeDismiss,
    PickTypePosition,
};

@protocol PickTypeViewControllerDelegate <NSObject>

- (void)pickTypeViewController:(POP_PickTypeViewController *)pickTypeVC currentType:(PickType)pickType pickValue:(NSInteger)pickValue;

@end

@interface POP_PickTypeViewController : UITableViewController
@property (nonatomic, assign) PickType pickType;
@property (nonatomic, strong) NSIndexPath *indexPath;

@property (nonatomic, weak) id<PickTypeViewControllerDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
