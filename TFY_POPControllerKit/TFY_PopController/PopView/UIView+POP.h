//
//  UIView+POP.h
//  POP
//
//  Created by 田风有 on 2021/8/7.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (POP)
/** 获取/设置view的x坐标 */
@property (nonatomic, assign) CGFloat pop_X;
/** 获取/设置view的x坐标 */
@property (nonatomic, assign) CGFloat pop_Y;
/** 获取/设置view的x坐标 */
@property (nonatomic, assign) CGFloat pop_Width;
/** 获取/设置view的x坐标 */
@property (nonatomic, assign) CGFloat pop_Height;
/** 获取/设置view的x坐标 */
@property (nonatomic, assign) CGFloat pop_CenterX;
/** 获取/设置view的x坐标 */
@property (nonatomic, assign) CGFloat pop_CenterY;
/** 获取/设置view的x坐标 */
@property (nonatomic, assign) CGFloat pop_Top;
/** 获取/设置view的左边坐标 */
@property (nonatomic, assign) CGFloat pop_Left;
/** 获取/设置view的底部坐标Y */
@property (nonatomic, assign) CGFloat pop_Bottom;
/** 获取/设置view的右边坐标 */
@property (nonatomic, assign) CGFloat pop_Right;
/** 获取/设置view的size */
@property (nonatomic, assign) CGSize pop_Size;


/** 是否是苹果X系列(刘海屏系列) */
BOOL pop_IsIphoneX_ALL(void);
/** 屏幕大小 */
CGSize pop_ScreenSize(void);
/** 屏幕宽度 */
CGFloat pop_ScreenWidth(void);
/** 屏幕高度 */
CGFloat pop_ScreenHeight(void);

@end

NS_ASSUME_NONNULL_END
