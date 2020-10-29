//
//  POP_PickTypeViewController.m
//  TFY_Navigation
//
//  Created by 田风有 on 2020/8/23.
//  Copyright © 2020 恋机科技. All rights reserved.
//

#import "POP_PickTypeViewController.h"
#import "POP_TwoController.h"
@interface POP_PickTypeViewController ()

@end

@implementation POP_PickTypeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.rowHeight = 50;
    [self.tableView registerClass:UITableViewCell.class forCellReuseIdentifier:NSStringFromClass(UITableViewCell.class)];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger rows = 0;
    if (self.pickType == PickTypePosition) {
        rows = 3;
    } else {
        rows = 13;
    }
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(UITableViewCell.class) forIndexPath:indexPath];
    switch (self.pickType) {
        case PickTypePop:{
            cell.textLabel.text = stringWithPopType((PopType) indexPath.row);
        }
            break;
        case PickTypeDismiss:{
            cell.textLabel.text = stringWithDismissType((DismissType) indexPath.row);
        }
            break;
        case PickTypePosition:{
            cell.textLabel.text = stringWithPositionType((PopPosition) indexPath.row);
        }
            break;
        default:
            break;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.navigationController popViewControllerAnimated:YES];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(pickTypeViewController:currentType:pickValue:)]) {
            [self.delegate pickTypeViewController:self currentType:self.pickType pickValue:indexPath.row];
        }
    });
    
}


@end
