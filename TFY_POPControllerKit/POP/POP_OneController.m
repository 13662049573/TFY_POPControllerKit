//
//  POP_OneController.m
//  TFY_Navigation
//
//  Created by 田风有 on 2020/8/23.
//  Copyright © 2020 恋机科技. All rights reserved.
//

#import "POP_OneController.h"
#import "POP_TwoController.h"
#import "POP_ThreeController.h"
#import "POP_FourController.h"
#import "POP_FiveController.h"
#import "POP_SixController.h"
#import "POP_SevenController.h"
#import "POP_EightController.h"
#import "POP_NavViewController.h"
@interface POP_OneController ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, copy) NSArray *titles;
@end

@implementation POP_OneController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.makeChain
    .addToSuperView(self.view)
    .makeMasonry(^(MASConstraintMaker * _Nonnull make) {
        make.top.equalTo(self.view).offset(TFY_kNavBarHeight());
        make.left.right.bottom.equalTo(self.view).offset(0);
    });
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.rowHeight = 55;
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass(UITableViewCell.class)];
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}

- (NSArray *)titles {
    if (!_titles) {
        _titles = @[@"Pop Animation Style", @"Bottom Sheet", @"Top Bar", @"Full Dialog", @"Center", @"AutoSize", @"Navigation"];
    }
    return _titles;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.titles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(UITableViewCell.class) forIndexPath:indexPath];
    cell.textLabel.text = self.titles[indexPath.row];
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0:{
            POP_TwoController *vc1 = [POP_TwoController new];
            [self.navigationController pushViewController:vc1 animated:YES];
        }
            break;
        case 1:{
            POP_ThreeController *bottomAuthVC = [POP_ThreeController new];
            TFY_PopController *popController = [[TFY_PopController alloc] initWithViewController:bottomAuthVC];
            popController.popPosition = PopPositionBottom;
            popController.popType = PopTypeBounceInFromBottom;
            popController.dismissType = DismissTypeSlideOutToBottom;
            popController.shouldDismissOnBackgroundTouch = NO;
            [popController presentInViewController:self];
        }
            break;
        case 2:{
            POP_FourController *topBarVC = [POP_FourController new];
            TFY_PopController *popController = [[TFY_PopController alloc] initWithViewController:topBarVC];
            popController.backgroundAlpha = 0;
            popController.popPosition = PopPositionTop;
            popController.popType = PopTypeBounceInFromTop;
            popController.dismissType = DismissTypeSlideOutToTop;
            [popController presentInViewController:self];
        }
            break;
        case 3:{
            POP_FiveController *fullDialogViewController = [POP_FiveController new];
            [fullDialogViewController popupWithPopType:PopTypeShrinkIn dismissType:DismissTypeSlideOutToBottom];
        }
            break;
        case 4:{
            POP_SixController *centerViewController = [POP_SixController new];
            [centerViewController popup];
        }
            break;
        case 5:{
            POP_SevenController *autoSizeVC = [POP_SevenController new];
            [autoSizeVC popup];
        }
            break;
        case 6:{
            POP_NavViewController *navVC = [[POP_NavViewController alloc] initWithRootViewController:[POP_EightController new]];
            [navVC popupWithPopType:PopTypeSlideInFromTop dismissType:DismissTypeSlideOutToBottom];
        }
            break;
        default:
            break;
    }
}

@end
