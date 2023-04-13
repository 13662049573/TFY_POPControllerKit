//
//  TFY_PopTimer.h
//  TFY_POPControllerKit
//
//  Created by 田风有 on 2023/4/13.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^TimerChangeBlock)(NSString * _Nonnull day, NSString *_Nonnull hour, NSString *_Nonnull minute, NSString *_Nonnull second, NSString *_Nonnull ms);
typedef void(^TimerFinishBlock)(NSString *_Nonnull identifier);
typedef void(^TimerPauseBlock)(NSString *_Nonnull identifier);


/** 倒计时变化通知类型 */
typedef NS_ENUM(NSInteger, TimerSecondChangeNFType) {
    TimerSecondChangeNFTypeNone = 0,
    TimerSecondChangeNFTypeMS,        //每100ms(毫秒) 发出一次
    TimerSecondChangeNFTypeSecond,    //每1s(秒) 发出一次
};

@interface TFY_PopTimer : NSObject

/** 单例 */
TFY_PopTimer *popTimerM(void);

#pragma mark - ***** 配置计时任务通知回调 *****
/// 设置倒计时任务的通知回调
///  name 通知名
///  identifier 倒计时任务的标识
///  type 倒计时变化通知类型
+ (void)setNotificationForName:(NSString *)name identifier:(NSString *)identifier changeNFType:(TimerSecondChangeNFType)type;

#pragma mark - ***** 添加计时任务(100ms回调一次) *****
/// 添加计时任务
///  time 时间长度
///  handle 每100ms回调一次
+ (void)addTimerForTime:(NSTimeInterval)time handle:(TimerChangeBlock)handle;
/// 添加计时任务
///  time 时间长度
///  identifier 计时任务标识
///  handle 每100ms回调一次
+ (void)addTimerForTime:(NSTimeInterval)time
             identifier:(NSString *)identifier
                 handle:(TimerChangeBlock)handle;
/// 添加计时任务
///  time 时间长度
///  identifier 计时任务标识
///  handle 每100ms回调一次
///  finishBlock 计时完成回调
///  pauseBlock 计时暂停回调
+ (void)addTimerForTime:(NSTimeInterval)time
             identifier:(NSString *)identifier
                 handle:(TimerChangeBlock)handle
                 finish:(TimerFinishBlock)finishBlock
                  pause:(TimerPauseBlock)pauseBlock;
/// 添加计时任务,持久化到硬盘
///  time 时间长度
///  identifier 计时任务标识
///  handle 每100ms回调一次
+ (void)addDiskTimerForTime:(NSTimeInterval)time
                 identifier:(NSString *)identifier
                     handle:(TimerChangeBlock)handle;
/// 添加计时任务,持久化到硬盘
///  time 添加计时任务,持久化到硬盘
///  identifier 计时任务标识
///  handle 每100ms回调一次
///  finishBlock 计时完成回调
///  pauseBlock 计时暂停回调
+ (void)addDiskTimerForTime:(NSTimeInterval)time
                 identifier:(NSString *)identifier
                     handle:(TimerChangeBlock)handle
                     finish:(TimerFinishBlock)finishBlock
                      pause:(TimerPauseBlock)pauseBlock;



#pragma mark - ***** 添加计时任务(1s回调一次) *****
/// 添加计时任务
///  time 时间长度
///  handle 计时任务标识
+ (void)addMinuteTimerForTime:(NSTimeInterval)time handle:(TimerChangeBlock)handle;
/// 添加计时任务
///  time 时间长度
///  identifier 计时任务标识
///  handle 每100ms回调一次
+ (void)addMinuteTimerForTime:(NSTimeInterval)time
                   identifier:(NSString *)identifier
                       handle:(TimerChangeBlock)handle;

/// 添加计时任务
///  time 时间长度
///  identifier 计时任务标识
///  handle 每100ms回调一次
///  finishBlock 计时完成回调
///  pauseBlock 计时暂停回调
+ (void)addMinuteTimerForTime:(NSTimeInterval)time
                   identifier:(NSString *)identifier
                       handle:(TimerChangeBlock)handle
                       finish:(TimerFinishBlock)finishBlock
                        pause:(TimerPauseBlock)pauseBlock;

/// 添加计时任务
///  time 时间长度
///  identifier 计时任务标识
///  handle 每100ms回调一次
///  finishBlock 计时完成回调
///  pauseBlock 计时暂停回调
+ (void)addDiskMinuteTimerForTime:(NSTimeInterval)time
                       identifier:(NSString *)identifier
                           handle:(TimerChangeBlock)handle
                           finish:(TimerFinishBlock)finishBlock
                            pause:(TimerPauseBlock)pauseBlock;


#pragma mark - ***** 获取计时任务时间间隔 *****
/// 通过任务标识获取 计时任务 间隔(毫秒)
///  identifier 计时任务标识
+ (NSTimeInterval)getTimeIntervalForIdentifier:(NSString *)identifier;


#pragma mark - ***** 暂停计时任务 *****
/// 通过标识暂停计时任务
///  identifier 计时任务标识
+ (BOOL)pauseTimerForIdentifier:(NSString *)identifier;
/// 暂停所有计时任务
+ (void)pauseAllTimer;

#pragma mark - ***** 重启计时任务 *****
/// 通过标识重启 计时任务
///  identifier 计时任务标识
+ (BOOL)restartTimerForIdentifier:(NSString *)identifier;
/// 重启所有计时任务
+ (void)restartAllTimer;

#pragma mark - ***** 重置计时任务(恢复初始状态) *****
/// 通过标识重置 计时任务
///  identifier 计时任务标识
+ (BOOL)resetTimerForIdentifier:(NSString *)identifier;
/// 重置所有计时任务
+ (void)resetAllTimer;

#pragma mark - ***** 移除计时任务 *****
/// 通过标识移除计时任务
///  identifier 计时任务标识
+ (BOOL)removeTimerForIdentifier:(NSString *)identifier;
/// 移除所有计时任务
+ (void)removeAllTimer;

#pragma mark - ***** 格式化时间 *****
/// 将毫秒数 格式化成  时:分:秒:毫秒
///  time 时间长度(毫秒单位)
///  handle 格式化完成回调
+ (void)formatDateForTime:(NSTimeInterval)time handle:(TimerChangeBlock)handle;


@end

NS_ASSUME_NONNULL_END
