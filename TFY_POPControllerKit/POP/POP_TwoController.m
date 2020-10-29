//
//  POP_TwoController.m
//  TFY_Navigation
//
//  Created by 田风有 on 2020/8/23.
//  Copyright © 2020 恋机科技. All rights reserved.
//

#import "POP_TwoController.h"
#import "CatViewController.h"
#import "POP_PickTypeViewController.h"
@interface POP_TwoController ()<UITableViewDataSource, UITableViewDelegate, PickTypeViewControllerDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, copy) NSArray *headTitles;

@property (nonatomic, assign) PopType popType;
@property (nonatomic, assign) DismissType dismissType;
@property (nonatomic, assign) PopPosition position;
@end

@implementation POP_TwoController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Animation Style";
    self.view.backgroundColor = [UIColor whiteColor];

    [self.view addSubview:self.tableView];
    [self.tableView tfy_AutoSize:0 top:0 right:0 bottom:0];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(UITableViewCell.class) forIndexPath:indexPath];
    switch (indexPath.section) {
        case 0:
            cell.textLabel.text = stringWithPopType(self.popType);
            break;
        case 1:
            cell.textLabel.text = stringWithDismissType(self.dismissType);
            break;
        case 2:
            cell.textLabel.text = stringWithPositionType(self.position);
            break;
        default:
            break;
    }
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.headTitles.count;
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.headTitles[section];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    POP_PickTypeViewController *pickTypeViewController = [POP_PickTypeViewController new];
    pickTypeViewController.pickType = (PickType) indexPath.section;
    pickTypeViewController.indexPath = indexPath;
    pickTypeViewController.delegate = self;
    [self.navigationController pushViewController:pickTypeViewController animated:YES];
}

- (void)showPopup {
    TFY_PopController *popController = [[TFY_PopController alloc] initWithViewController:[CatViewController new]];
    popController.popType = self.popType;
    popController.dismissType = self.dismissType;
    popController.popPosition = self.position;

    [popController presentInViewController:self];
}

#pragma mark - HWPickTypeViewControllerDelegate

- (void)pickTypeViewController:(POP_PickTypeViewController *)pickTypeVc currentType:(PickType)pickType pickValue:(NSInteger)pickValue {
    switch (pickType) {
        case PickTypePop:
            self.popType = (PopType) pickValue;
            break;
        case PickTypeDismiss:
            self.dismissType = (DismissType) pickValue;
            break;
        case PickTypePosition:
            self.position = (PopPosition) pickValue;
            break;
        default:
            break;
    }
    [self.tableView reloadRowsAtIndexPaths:@[pickTypeVc.indexPath] withRowAnimation:UITableViewRowAnimationRight];
}


#pragma mark - Getter


- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.estimatedRowHeight = 0;
        _tableView.estimatedSectionHeaderHeight = 0;
        _tableView.estimatedSectionFooterHeight = 0;
        _tableView.rowHeight = 60;
        [_tableView registerClass:UITableViewCell.class forCellReuseIdentifier:NSStringFromClass(UITableViewCell.class)];

        UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 56)];

        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(30, 0, CGRectGetWidth(footer.bounds) - 60, 56);
        [button setTitle:@"Pop up" forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont boldSystemFontOfSize:30];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(showPopup) forControlEvents:UIControlEventTouchUpInside];
        button.backgroundColor = [UIColor colorWithRed:0.000 green:0.590 blue:1.000 alpha:1.00];
        button.layer.masksToBounds = YES;
        button.layer.cornerRadius = 6.f;

        [footer addSubview:button];
        _tableView.tableFooterView = footer;

        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}

- (NSArray *)headTitles {
    if (!_headTitles) {
        _headTitles = @[@"Pop Style", @"Dismiss Style", @"Pop Position"];
    }
    return _headTitles;
}


@end
