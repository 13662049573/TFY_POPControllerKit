//
//  UIView+POP.m
//  POP
//
//  Created by 田风有 on 2021/8/7.
//

#import "UIView+POP.h"

@implementation UIView (POP)

- (void)setPop_X:(CGFloat)pop_X {
    CGRect frame = self.frame;
    frame.origin.x = pop_X;
    self.frame = frame;
}

- (CGFloat)pop_X {
    return self.frame.origin.x;
}

- (void)setPop_Y:(CGFloat)pop_Y {
    CGRect frame = self.frame;
    frame.origin.y = pop_Y;
    self.frame = frame;
}

- (CGFloat)pop_Y {
    return self.frame.origin.y;
}

- (void)setPop_Width:(CGFloat)pop_Width {
    CGRect frame = self.frame;
    frame.size.width = pop_Width;
    self.frame = frame;
}

- (CGFloat)pop_Width {
    return self.frame.size.width;
}

- (void)setPop_Height:(CGFloat)pop_Height {
    CGRect frame = self.frame;
    frame.size.height = pop_Height;
    self.frame = frame;
}

- (CGFloat)pop_Height {
    return self.frame.size.height;
}

- (void)setPop_Size:(CGSize)pop_Size {
    CGRect frame = self.frame;
    frame.size = pop_Size;
    self.frame = frame;
}

- (CGSize)pop_Size {
    return self.frame.size;
}

- (void)setPop_CenterX:(CGFloat)pop_CenterX {
    CGPoint center = self.center;
    center.x = pop_CenterX;
    self.center = center;
}

- (CGFloat)pop_CenterX {
    return self.center.x;
}

- (void)setPop_CenterY:(CGFloat)pop_CenterY {
    CGPoint center = self.center;
    center.y = pop_CenterY;
    self.center = center;
}

- (CGFloat)pop_CenterY {
    return self.center.y;
}

- (void)setPop_Top:(CGFloat)pop_Top {
    CGRect newframe = self.frame;
    newframe.origin.y = pop_Top;
    self.frame = newframe;
}

- (CGFloat)pop_Top {
    return self.frame.origin.y;
}

- (void)setPop_Left:(CGFloat)pop_Left {
    CGRect newframe = self.frame;
    newframe.origin.x = pop_Left;
    self.frame = newframe;
}

- (CGFloat)pop_Left {
    return self.frame.origin.x;
}

- (void)setPop_Bottom:(CGFloat)pop_Bottom {
    CGRect newframe = self.frame;
    newframe.origin.y = pop_Bottom - self.frame.size.height;
    self.frame = newframe;
}

- (CGFloat)pop_Bottom {
    return self.frame.origin.y + self.frame.size.height;
}

- (void)setPop_Right:(CGFloat)pop_Right {
    CGFloat delta = pop_Right - (self.frame.origin.x + self.frame.size.width);
    CGRect newframe = self.frame;
    newframe.origin.x += delta ;
    self.frame = newframe;
}

- (CGFloat)pop_Right {
    return self.frame.origin.x + self.frame.size.width;
}

/** 是否是苹果X系列(刘海屏系列) */
BOOL pop_IsIphoneX_ALL(void) {
    BOOL isPhoneX = NO;
    if (@available(iOS 11.0, *)) {
        isPhoneX = [[UIApplication sharedApplication] delegate].window.safeAreaInsets.bottom > 0.0;
    }
    return isPhoneX;
}

CGSize pop_ScreenSize(void) {
    CGSize size = [UIScreen mainScreen].bounds.size;
    return size;
}

CGFloat pop_ScreenWidth(void) {
    CGSize size = [UIScreen mainScreen].bounds.size;
    return size.width;
}

CGFloat pop_ScreenHeight(void) {
    CGSize size = [UIScreen mainScreen].bounds.size;
    return size.height;
}


@end
