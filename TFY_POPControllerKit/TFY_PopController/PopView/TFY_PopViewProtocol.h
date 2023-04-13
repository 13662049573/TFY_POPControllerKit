//
//  TFY_PopViewProtocol.h
//  TFY_POPControllerKit
//
//  Created by 田风有 on 2023/4/13.
//

#import <Foundation/Foundation.h>

@class TFY_PopView;

NS_ASSUME_NONNULL_BEGIN

#ifdef DEBUG
#define TFYPopLog(format, ...) printf("class: <%p %s:(第%d行) > method: %s \n%s\n", self, [[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String], __LINE__, __PRETTY_FUNCTION__, [[NSString stringWithFormat:(format), ##__VA_ARGS__] UTF8String] )
#else
#define TFYPopLog(format, ...)
#endif

typedef void (^ _Nullable Block_Void)(void);
typedef void (^ _Nullable Block_Point)(CGPoint point);
typedef void (^ _Nullable Block_AlertCountDown)(TFY_PopView * _Nonnull popView,NSTimeInterval timeInterval);
typedef void (^ _Nullable Block_KeyBoardChange)(CGRect beginFrame,CGRect endFrame,CGFloat duration);
typedef UIView * _Nonnull (^ _Nullable Block_View_Void)(void);

/** 调试日志类型 */
typedef NS_ENUM(NSInteger, PopViewLogStyle) {
    PopViewLogStyleNO = 0,          // 关闭调试信息(窗口和控制台日志输出)
    PopViewLogStyleWindow,          // 开启左上角小窗
    PopViewLogStyleConsole,         // 开启控制台日志输出
    PopViewLogStyleALL              // 开启小窗和控制台日志
};

/** 显示动画样式 */
typedef NS_ENUM(NSInteger, PopStyle) {
    PopStyleFade = 0,               // 默认 渐变出现
    PopStyleNO,                     // 无动画
    PopStyleScale,                  // 缩放 先放大 后恢复至原大小
    PopStyleSmoothFromTop,          // 顶部 平滑淡入动画
    PopStyleSmoothFromLeft,         // 左侧 平滑淡入动画
    PopStyleSmoothFromBottom,       // 底部 平滑淡入动画
    PopStyleSmoothFromRight,        // 右侧 平滑淡入动画
    PopStyleSpringFromTop,          // 顶部 平滑淡入动画 带弹簧
    PopStyleSpringFromLeft,         // 左侧 平滑淡入动画 带弹簧
    PopStyleSpringFromBottom,       // 底部 平滑淡入动画 带弹簧
    PopStyleSpringFromRight,        // 右侧 平滑淡入动画 带弹簧
    PopStyleCardDropFromLeft,       // 顶部左侧 掉落动画
    PopStyleCardDropFromRight,      // 顶部右侧 掉落动画
};
/** 消失动画样式 */
typedef NS_ENUM(NSInteger, DismissStyle) {
    DismissStyleFade = 0,             // 默认 渐变消失
    DismissStyleNO,                   // 无动画
    DismissStyleScale,                // 缩放
    DismissStyleSmoothToTop,          // 顶部 平滑淡出动画
    DismissStyleSmoothToLeft,         // 左侧 平滑淡出动画
    DismissStyleSmoothToBottom,       // 底部 平滑淡出动画
    DismissStyleSmoothToRight,        // 右侧 平滑淡出动画
    DismissStyleCardDropToLeft,       // 卡片从中间往左侧掉落
    DismissStyleCardDropToRight,      // 卡片从中间往右侧掉落
    DismissStyleCardDropToTop,        // 卡片从中间往顶部移动消失
};
/** 主动动画样式(开发中) */
typedef NS_ENUM(NSInteger, ActivityStyle) {
    ActivityStyleNO = 0,               /// 无动画
    ActivityStyleScale,                /// 缩放
    ActivityStyleShake,                /// 抖动
};
/** 弹窗位置 */
typedef NS_ENUM(NSInteger, HemStyle) {
    HemStyleCenter = 0,   //居中
    HemStyleTop,          //贴顶
    HemStyleLeft,         //贴左
    HemStyleBottom,       //贴底
    HemStyleRight,        //贴右
    HemStyleTopLeft,      //贴顶和左
    HemStyleBottomLeft,   //贴底和左
    HemStyleBottomRight,  //贴底和右
    HemStyleTopRight      //贴顶和右
};
/** 拖拽方向 */
typedef NS_ENUM(NSInteger, DragStyle) {
    DragStyleNO = 0,  //默认 不能拖拽窗口
    DragStyleX_Positive = 1<<0,   //X轴正方向拖拽
    DragStyleX_Negative = 1<<1,   //X轴负方向拖拽
    DragStyleY_Positive = 1<<2,   //Y轴正方向拖拽
    DragStyleY_Negative = 1<<3,   //Y轴负方向拖拽
    DragStyleX = (DragStyleX_Positive|DragStyleX_Negative),   //X轴方向拖拽
    DragStyleY = (DragStyleY_Positive|DragStyleY_Negative),   //Y轴方向拖拽
    DragStyleAll = (DragStyleX|DragStyleY)   //全向拖拽
};
///** 可轻扫消失的方向 */
typedef NS_ENUM(NSInteger, SweepStyle) {
    SweepStyleNO = 0,  //默认 不能拖拽窗口
    SweepStyleX_Positive = 1<<0,   //X轴正方向拖拽
    SweepStyleX_Negative = 1<<1,   //X轴负方向拖拽
    SweepStyleY_Positive = 1<<2,   //Y轴正方向拖拽
    SweepStyleY_Negative = 1<<3,   //Y轴负方向拖拽
    SweepStyleX = (SweepStyleX_Positive|SweepStyleX_Negative),   //X轴方向拖拽
    SweepStyleY = (SweepStyleY_Positive|SweepStyleY_Negative),   //Y轴方向拖拽
    SweepStyleALL = (SweepStyleX|SweepStyleY)   //全向轻扫
};

/**
   可轻扫消失动画类型 对单向横扫 设置有效
   SweepDismissStyleSmooth: 自动适应选择以下其一
   DismissStyleSmoothToTop,
   DismissStyleSmoothToLeft,
   DismissStyleSmoothToBottom ,
   DismissStyleSmoothToRight
 */
typedef NS_ENUM(NSInteger, SweepDismissStyle) {
    SweepDismissStyleVelocity = 0,  //默认加速度 移除
    SweepDismissStyleSmooth = 1     //平顺移除
};


@protocol TFY_PopViewProtocol <NSObject>

/** 点击弹窗 回调 */
- (void)tfy_PopViewBgClickForPopView:(TFY_PopView *)popView;
/** 长按弹窗 回调 */
- (void)tfy_PopViewBgLongPressForPopView:(TFY_PopView *)popView;

// ****** 生命周期 ******
/** 将要显示 */
- (void)tfy_PopViewWillPopForPopView:(TFY_PopView *)popView;
/** 已经显示完毕 */
- (void)tfy_PopViewDidPopForPopView:(TFY_PopView *)popView;
/** 倒计时进行中 timeInterval:时长  */
- (void)tfy_PopViewCountDownForPopView:(TFY_PopView *)popView forCountDown:(NSTimeInterval)timeInterval;
/** 倒计时倒计时完成  */
- (void)tfy_PopViewCountDownFinishForPopView:(TFY_PopView *)popView;
/** 将要开始移除 */
- (void)tfy_PopViewWillDismissForPopView:(TFY_PopView *)popView;
/** 已经移除完毕 */
- (void)tfy_PopViewDidDismissForPopView:(TFY_PopView *)popView;
//***********************

@end

NS_ASSUME_NONNULL_END
