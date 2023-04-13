//
//  TFY_PopTimer.m
//  TFY_POPControllerKit
//
//  Created by 田风有 on 2023/4/13.
//

#import "TFY_PopTimer.h"

#define TFYPopViewTimerPath(name)  [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:[NSString stringWithFormat:@"TFY_PopTimer_%@_Timer",name]]

@interface TFY_PopViewTimerModel : NSObject

/** 毫秒为单位计算 */
@property (nonatomic, assign) NSTimeInterval time;
/** 原始开始时间 毫秒 */
@property (nonatomic, assign) NSTimeInterval oriTime;
/** 进度单位 */
@property (nonatomic, assign) NSTimeInterval unit;
/** 定时器执行block */

/** 是否本地持久化保存定时数据 */
@property (nonatomic,assign) BOOL isDisk;
/** 是否暂停 */
@property (nonatomic,assign) BOOL isPause;
/** 标识 */
@property (nonatomic, copy) NSString *identifier;
/** 通知名称 */
@property (nonatomic, copy) NSString *NFName;
/** 通知类型 0.不发通知 1.毫秒通知 2.秒通知 */
@property (nonatomic, assign) TimerSecondChangeNFType NFType;


@property (nonatomic, copy) TimerChangeBlock handleBlock;
/** 定时器执行block */
@property (nonatomic, copy) TimerFinishBlock finishBlock;
/** 定时器执行block */
@property (nonatomic, copy) TimerPauseBlock pauseBlock;

+ (instancetype)timeInterval:(NSInteger)timeInterval;

@end

@implementation TFY_PopViewTimerModel

+ (instancetype)timeInterval:(NSInteger)timeInterval {
    TFY_PopViewTimerModel *object = [TFY_PopViewTimerModel new];
    object.time = timeInterval*1000;
    object.oriTime = timeInterval*1000;
    return object;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeDouble:self.time forKey:@"timeInterval"];
    [aCoder encodeDouble:self.oriTime forKey:@"oriTime"];
    [aCoder encodeDouble:self.unit forKey:@"unit"];
    [aCoder encodeBool:self.isDisk forKey:@"isDisk"];
    [aCoder encodeBool:self.isPause forKey:@"isPause"];
    [aCoder encodeObject:self.identifier forKey:@"identifier"];
    [aCoder encodeBool:self.NFType forKey:@"NFType"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.time = [aDecoder decodeDoubleForKey:@"timeInterval"];
        self.oriTime = [aDecoder decodeDoubleForKey:@"oriTime"];
        self.unit = [aDecoder decodeDoubleForKey:@"unit"];
        self.isDisk = [aDecoder decodeBoolForKey:@"isDisk"];
        self.isPause = [aDecoder decodeBoolForKey:@"isPause"];
        self.identifier = [aDecoder decodeObjectForKey:@"identifier"];
        self.NFType = [aDecoder decodeBoolForKey:@"NFType"];
    }
    return self;
}

@end

@interface TFY_PopTimer ()
@property (nonatomic, strong) NSTimer * _Nullable showTimer;
/** 储存多个计时器数据源 */
@property (nonatomic, strong) NSMutableDictionary<NSString *, TFY_PopViewTimerModel *> *timerMdic;
@end

@implementation TFY_PopTimer
static TFY_PopTimer *_instance;

TFY_PopTimer *popTimerM(void) {
    return [TFY_PopTimer sharedInstance];
}

+ (instancetype)sharedInstance {
    if (!_instance) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _instance = [[self alloc] init];
        });
    }
    return _instance;
}


+ (id)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
    });
    return _instance;
}

/// 设置倒计时任务的通知回调
///  name 通知名
///  identifier 倒计时任务的标识
///  type 倒计时变化通知类型
+ (void)setNotificationForName:(NSString *)name identifier:(NSString *)identifier changeNFType:(TimerSecondChangeNFType)type  {
    if (identifier.length<=0) {
        NSLog(@"计时器标识不能为空");
        return;
    }
    TFY_PopViewTimerModel *model = popTimerM().timerMdic[identifier];
    if (model) {
        model.NFType = type;
        model.NFName = name;
        return;
    }else {
        NSLog(@"找不到计时器任务");
        return;
    }
}


/** 添加定时器并开启计时 */
+ (void)addTimerForTime:(NSTimeInterval)time handle:(TimerChangeBlock)handle {
    [self initTimerForForTime:time identifier:nil ForIsDisk:NO unit:0 handle:handle finish:nil pause:nil];
}
/** 添加定时器并开启计时 */
+ (void)addTimerForTime:(NSTimeInterval)time
             identifier:(NSString *)identifier
                 handle:(TimerChangeBlock)handle {
    
     [self initTimerForForTime:time
                    identifier:identifier
                     ForIsDisk:NO
                          unit:-1
                        handle:handle
                        finish:nil
                         pause:nil];
}
/** 添加定时器并开启计时 */
+ (void)addTimerForTime:(NSTimeInterval)time
             identifier:(NSString *)identifier
                 handle:(TimerChangeBlock)handle
                 finish:(TimerFinishBlock)finishBlock
                  pause:(TimerPauseBlock)pauseBlock {
    
     [self initTimerForForTime:time
                    identifier:identifier
                     ForIsDisk:NO
                          unit:-1
                        handle:handle
                        finish:finishBlock
                         pause:pauseBlock];
}

/** 添加定时器并开启计时 */
+ (void)addDiskTimerForTime:(NSTimeInterval)time
                 identifier:(NSString *)identifier
                     handle:(TimerChangeBlock)handle {
    
     [self initTimerForForTime:time
                    identifier:identifier
                     ForIsDisk:YES
                          unit:-1
                        handle:handle
                        finish:nil
                         pause:nil];
}

/** 添加定时器并开启计时 */
+ (void)addDiskTimerForTime:(NSTimeInterval)time
                 identifier:(NSString *)identifier
                     handle:(TimerChangeBlock)handle
                     finish:(TimerFinishBlock)finishBlock
                      pause:(TimerPauseBlock)pauseBlock {
    
     [self initTimerForForTime:time
                    identifier:identifier
                     ForIsDisk:YES
                          unit:-1
                        handle:handle
                        finish:finishBlock
                         pause:pauseBlock];
}


/** 添加定时器并开启计时 */
+ (void)addMinuteTimerForTime:(NSTimeInterval)time handle:(TimerChangeBlock)handle {
     [self initTimerForForTime:time identifier:nil ForIsDisk:NO unit:1000 handle:handle finish:nil pause:nil];
}
/** 添加定时器并开启计时 */
+ (void)addMinuteTimerForTime:(NSTimeInterval)time
                   identifier:(NSString *)identifier
                       handle:(TimerChangeBlock)handle {
    
     [self initTimerForForTime:time
                    identifier:identifier
                     ForIsDisk:NO
                          unit:1000
                        handle:handle
                        finish:nil
                         pause:nil];
}

/** 添加定时器并开启计时 */
+ (void)addMinuteTimerForTime:(NSTimeInterval)time
                   identifier:(NSString *)identifier
                       handle:(TimerChangeBlock)handle
                       finish:(TimerFinishBlock)finishBlock
                        pause:(TimerPauseBlock)pauseBlock {
    
     [self initTimerForForTime:time
                    identifier:identifier
                     ForIsDisk:NO
                          unit:1000
                        handle:handle
                        finish:finishBlock
                         pause:pauseBlock];
}

/** 添加定时器并开启计时 */
+ (void)addDiskMinuteTimerForTime:(NSTimeInterval)time
                       identifier:(NSString *)identifier
                           handle:(TimerChangeBlock)handle
                           finish:(TimerFinishBlock)finishBlock
                            pause:(TimerPauseBlock)pauseBlock {
    
     [self initTimerForForTime:time
                    identifier:identifier
                     ForIsDisk:YES
                          unit:1000
                        handle:handle
                        finish:finishBlock
                         pause:pauseBlock];
}

//总初始化入口
+ (void)initTimerForForTime:(NSTimeInterval)time
                 identifier:(NSString *)identifier
                  ForIsDisk:(BOOL)isDisk
                       unit:(NSTimeInterval)unit
                     handle:(TimerChangeBlock)handle
                     finish:(TimerFinishBlock)finishBlock
                      pause:(TimerPauseBlock)pauseBlock {
    
    if (identifier.length<=0) {
        TFY_PopViewTimerModel *model = [TFY_PopViewTimerModel timeInterval:time];
        model.isDisk = isDisk;
        model.identifier = [NSString stringWithFormat:@"%p",model];
        model.unit = unit;
        model.handleBlock = handle;
        model.finishBlock = finishBlock;
        model.pauseBlock = pauseBlock;
        [popTimerM().timerMdic setObject:model forKey:model.identifier];
        if (model.handleBlock) {
            NSInteger totalSeconds = model.time/1000.0;
            NSString *days = [NSString stringWithFormat:@"%zd", totalSeconds/60/60/24];
            NSString *hours =  [NSString stringWithFormat:@"%zd", totalSeconds/60/60%24];
            NSString *minute = [NSString stringWithFormat:@"%zd", (totalSeconds/60)%60];
            NSString *second = [NSString stringWithFormat:@"%zd", totalSeconds%60];
            CGFloat sss = ((NSInteger)(model.time))%1000/10;
            NSString *ss = [NSString stringWithFormat:@"%.lf", sss];
            
            if (hours.integerValue < 10) {
                hours = [NSString stringWithFormat:@"0%@", hours];
            }
            if (minute.integerValue < 10) {
                minute = [NSString stringWithFormat:@"0%@", minute];
            }
            if (second.integerValue < 10) {
                second = [NSString stringWithFormat:@"0%@", second];
            }
            if (ss.integerValue < 10) {
                ss = [NSString stringWithFormat:@"0%@", ss];
            }
            model.handleBlock(days,hours,minute,second,ss);
          
        }
        // 发出通知
        if (model.NFType != TimerSecondChangeNFTypeNone) {
            [[NSNotificationCenter defaultCenter] postNotificationName:model.NFName object:nil userInfo:nil];
        }
        if (model.isDisk) {
             [self savaForTimerModel:model];
        }
        [self initTimer];
        return;
    }
    
        
    BOOL isTempDisk = [TFY_PopTimer timerIsExistInDiskForIdentifier:identifier];//磁盘有任务
    BOOL isRAM = popTimerM().timerMdic[identifier]?YES:NO;//内存有任务
    
    if (!isRAM && !isTempDisk) {//新任务
        TFY_PopViewTimerModel *model = [TFY_PopViewTimerModel timeInterval:time];
        model.handleBlock = handle;
        model.isDisk = isDisk;
        model.identifier = identifier;
        model.unit = unit;
        model.finishBlock = finishBlock;
        model.pauseBlock = pauseBlock;
        [popTimerM().timerMdic setObject:model forKey:identifier];
        if (model.handleBlock) {
            
            NSInteger totalSeconds = model.time/1000.0;
            NSString *days = [NSString stringWithFormat:@"%zd", totalSeconds/60/60/24];
            NSString *hours =  [NSString stringWithFormat:@"%zd", totalSeconds/60/60%24];
            NSString *minute = [NSString stringWithFormat:@"%zd", (totalSeconds/60)%60];
            NSString *second = [NSString stringWithFormat:@"%zd", totalSeconds%60];
            CGFloat sss = ((NSInteger)(model.time))%1000/10;
            NSString *ss = [NSString stringWithFormat:@"%.lf", sss];
            
            if (hours.integerValue < 10) {
                hours = [NSString stringWithFormat:@"0%@", hours];
            }
            if (minute.integerValue < 10) {
                minute = [NSString stringWithFormat:@"0%@", minute];
            }
            if (second.integerValue < 10) {
                second = [NSString stringWithFormat:@"0%@", second];
            }
            if (ss.integerValue < 10) {
                ss = [NSString stringWithFormat:@"0%@", ss];
            }
            if (model.isDisk) {
                [self savaForTimerModel:model];
            }
            model.handleBlock(days,hours,minute,second,ss);
            
        }
        // 发出通知
        if (model.NFType != TimerSecondChangeNFTypeNone) {
            [[NSNotificationCenter defaultCenter] postNotificationName:model.NFName object:nil userInfo:nil];
        }
        [self initTimer];
    }
    
    
    if (isRAM && !isTempDisk) {//内存任务
        TFY_PopViewTimerModel *model = popTimerM().timerMdic[identifier];
        model.isPause = NO;
        model.handleBlock = handle;
        model.isDisk = isDisk;
        model.finishBlock = finishBlock;
        model.pauseBlock = pauseBlock;
        if (model.isDisk) {
            [self savaForTimerModel:model];
        }
//         [self initTimer];
    }
    
    if (!isRAM && isTempDisk) {//硬盘的任务
        TFY_PopViewTimerModel *model = [TFY_PopTimer getTimerModelForIdentifier:identifier];
        if (isDisk == NO) {
            [TFY_PopTimer deleteForIdentifier:identifier];
        }
        model.isPause = NO;
        model.isDisk = isDisk;
        model.handleBlock = handle;
        model.finishBlock = finishBlock;
        model.pauseBlock = pauseBlock;
        [popTimerM().timerMdic setObject:model forKey:identifier];
        if (model.handleBlock) {
            NSInteger totalSeconds = model.time/1000.0;
            NSString *days = [NSString stringWithFormat:@"%zd", totalSeconds/60/60/24];
            NSString *hours =  [NSString stringWithFormat:@"%zd", totalSeconds/60/60%24];
            NSString *minute = [NSString stringWithFormat:@"%zd", (totalSeconds/60)%60];
            NSString *second = [NSString stringWithFormat:@"%zd", totalSeconds%60];
            CGFloat sss = ((NSInteger)(model.time))%1000/10;
            NSString *ss = [NSString stringWithFormat:@"%.lf", sss];
            
            if (hours.integerValue < 10) {
                hours = [NSString stringWithFormat:@"0%@", hours];
            }
            if (minute.integerValue < 10) {
                minute = [NSString stringWithFormat:@"0%@", minute];
            }
            if (second.integerValue < 10) {
                second = [NSString stringWithFormat:@"0%@", second];
            }
            if (ss.integerValue < 10) {
                ss = [NSString stringWithFormat:@"0%@", ss];
            }
            model.handleBlock(days,hours,minute,second,ss);
           
        }
        // 发出通知
        if (model.NFType != TimerSecondChangeNFTypeNone) {
            [[NSNotificationCenter defaultCenter] postNotificationName:model.NFName object:nil userInfo:nil];
        }
        if (model.isDisk) {
            [self savaForTimerModel:model];
        }
        [self initTimer];
    }
    
    if (isRAM && isTempDisk) {//硬盘的任务
        TFY_PopViewTimerModel *model = [TFY_PopTimer getTimerModelForIdentifier:identifier];
        model.isPause = NO;
        if (isDisk == NO) {
            [TFY_PopTimer deleteForIdentifier:identifier];
        }
        model.isDisk = isDisk;
        model.handleBlock = handle;
        model.finishBlock = finishBlock;
        model.pauseBlock = pauseBlock;
        [popTimerM().timerMdic setObject:model forKey:identifier];
        if (model.handleBlock) {
            NSInteger totalSeconds = model.time/1000.0;
            NSString *days = [NSString stringWithFormat:@"%zd", totalSeconds/60/60/24];
            NSString *hours =  [NSString stringWithFormat:@"%zd", totalSeconds/60/60%24];
            NSString *minute = [NSString stringWithFormat:@"%zd", (totalSeconds/60)%60];
            NSString *second = [NSString stringWithFormat:@"%zd", totalSeconds%60];
            CGFloat sss = ((NSInteger)(model.time))%1000/10;
            NSString *ss = [NSString stringWithFormat:@"%.lf", sss];
            
            if (hours.integerValue < 10) {
                hours = [NSString stringWithFormat:@"0%@", hours];
            }
            if (minute.integerValue < 10) {
                minute = [NSString stringWithFormat:@"0%@", minute];
            }
            if (second.integerValue < 10) {
                second = [NSString stringWithFormat:@"0%@", second];
            }
            if (ss.integerValue < 10) {
                ss = [NSString stringWithFormat:@"0%@", ss];
            }
            model.handleBlock(days,hours,minute,second,ss);
            
        }
        // 发出通知
        if (model.NFType != TimerSecondChangeNFTypeNone) {
            [[NSNotificationCenter defaultCenter] postNotificationName:model.NFName object:nil userInfo:nil];
        }
        if (model.isDisk) {
            [self savaForTimerModel:model];
        }
//        [self initTimer];
    }
    
}

+ (NSTimeInterval)getTimeIntervalForIdentifier:(NSString *)identifier {
    if (identifier.length<=0) {
        return 0.0;
    }
    
    BOOL isTempDisk = [TFY_PopTimer timerIsExistInDiskForIdentifier:identifier];//磁盘有任务
    BOOL isRAM = popTimerM().timerMdic[identifier]?YES:NO;//内存有任务
    
    
    if (isTempDisk) {
        TFY_PopViewTimerModel *model = [TFY_PopTimer loadTimerForIdentifier:identifier];
        return model.oriTime - model.time;
    }else if (isRAM) {
        TFY_PopViewTimerModel *model = popTimerM().timerMdic[identifier];
        return model.oriTime - model.time;
    }else {
        NSLog(@"找不到计时任务");
        return 0.0;
    }
    
}

+ (BOOL)pauseTimerForIdentifier:(NSString *)identifier {
    if (identifier.length<=0) {
        NSLog(@"计时器标识不能为空");
        return NO;
    }
    TFY_PopViewTimerModel *model = popTimerM().timerMdic[identifier];
    
    if (model) {
        model.isPause = YES;
        if (model.pauseBlock) { model.pauseBlock(model.identifier); }
        return YES;
    }else {
        NSLog(@"找不到计时器任务");
        return NO;
    }
}

+ (void)pauseAllTimer {
    [popTimerM().timerMdic enumerateKeysAndObjectsUsingBlock:^(NSString *key, TFY_PopViewTimerModel *obj, BOOL *stop) {
        obj.isPause = YES;
        if (obj.pauseBlock) { obj.pauseBlock(obj.identifier); }
    }];
}

+ (BOOL)restartTimerForIdentifier:(NSString *)identifier {
    if (identifier.length<=0) {
        NSLog(@"计时器标识不能为空");
        return NO;
    }
    
    //只有内存任务才能重启, 硬盘任务只能调用addTimer系列方法重启
    BOOL isRAM = popTimerM().timerMdic[identifier]?YES:NO;//内存有任务
    if (isRAM) {
        TFY_PopViewTimerModel *model = popTimerM().timerMdic[identifier];
        model.isPause = NO;
        return YES;
    }else {
        NSLog(@"找不到计时器任务");
        return NO;
    }
    
    
}
+ (void)restartAllTimer {
    
    if (popTimerM().timerMdic.count<=0) {
        return;
    }
    
    [popTimerM().timerMdic enumerateKeysAndObjectsUsingBlock:^(NSString *key, TFY_PopViewTimerModel *obj, BOOL *stop) {
        obj.isPause = NO;
    }];
}

+ (BOOL)resetTimerForIdentifier:(NSString *)identifier {
    if (identifier.length<=0) {
        NSLog(@"计时器标识不能为空");
        return NO;
    }
    
    //只有内存任务才能重启, 硬盘任务只能调用addTimer系列方法重启
    BOOL isRAM = popTimerM().timerMdic[identifier]?YES:NO;//内存有任务
    if (isRAM) {
        TFY_PopViewTimerModel *model = popTimerM().timerMdic[identifier];
        model.isPause = NO;
        model.time = model.oriTime;
        if (model.handleBlock) {
            NSInteger totalSeconds = model.time/1000.0;
            NSString *days = [NSString stringWithFormat:@"%zd", totalSeconds/60/60/24];
            NSString *hours =  [NSString stringWithFormat:@"%zd", totalSeconds/60/60%24];
            NSString *minute = [NSString stringWithFormat:@"%zd", (totalSeconds/60)%60];
            NSString *second = [NSString stringWithFormat:@"%zd", totalSeconds%60];
            CGFloat sss = ((NSInteger)(model.time))%1000/10;
            NSString *ss = [NSString stringWithFormat:@"%.lf", sss];
            
            if (hours.integerValue < 10) {
                hours = [NSString stringWithFormat:@"0%@", hours];
            }
            if (minute.integerValue < 10) {
                minute = [NSString stringWithFormat:@"0%@", minute];
            }
            if (second.integerValue < 10) {
                second = [NSString stringWithFormat:@"0%@", second];
            }
            if (ss.integerValue < 10) {
                ss = [NSString stringWithFormat:@"0%@", ss];
            }
            model.handleBlock(days,hours,minute,second,ss);
            
        }
        return YES;
    }else {
        NSLog(@"找不到计时器任务");
        return NO;
    }
}

+ (void)resetAllTimer {
    if (popTimerM().timerMdic.count<=0) {
        return;
    }
    
    [popTimerM().timerMdic enumerateKeysAndObjectsUsingBlock:^(NSString *key, TFY_PopViewTimerModel *obj, BOOL *stop) {
        obj.isPause = NO;
        obj.time = obj.oriTime;
        if (obj.handleBlock) {
            NSInteger totalSeconds = obj.time/1000.0;
            NSString *days = [NSString stringWithFormat:@"%zd", totalSeconds/60/60/24];
            NSString *hours =  [NSString stringWithFormat:@"%zd", totalSeconds/60/60%24];
            NSString *minute = [NSString stringWithFormat:@"%zd", (totalSeconds/60)%60];
            NSString *second = [NSString stringWithFormat:@"%zd", totalSeconds%60];
            CGFloat sss = ((NSInteger)(obj.time))%1000/10;
            NSString *ss = [NSString stringWithFormat:@"%.lf", sss];
            
            if (hours.integerValue < 10) {
                hours = [NSString stringWithFormat:@"0%@", hours];
            }
            if (minute.integerValue < 10) {
                minute = [NSString stringWithFormat:@"0%@", minute];
            }
            if (second.integerValue < 10) {
                second = [NSString stringWithFormat:@"0%@", second];
            }
            if (ss.integerValue < 10) {
                ss = [NSString stringWithFormat:@"0%@", ss];
            }
            obj.handleBlock(days,hours,minute,second,ss);
          
        }
    }];
}

+ (BOOL)removeTimerForIdentifier:(NSString *)identifier {
    if (identifier.length<=0) {
        NSLog(@"计时器标识不能为空");
        return NO;
    }
    
    [popTimerM().timerMdic removeObjectForKey:identifier];
    if (popTimerM().timerMdic.count<=0) {//如果没有计时任务了 就销毁计时器
        [popTimerM().showTimer invalidate];
        popTimerM().showTimer = nil;
    }
    return YES;
}

+ (void)removeAllTimer {
    [popTimerM().timerMdic removeAllObjects];
    [popTimerM().showTimer invalidate];
    popTimerM().showTimer = nil;
}

/** increase YES: 递增 NO: 递减   */
+ (void)initTimer {
    
    if (popTimerM().showTimer) {
        return;
    }
    
    NSTimer *timer = [NSTimer timerWithTimeInterval:0.01f target:popTimerM() selector:@selector(timerChange) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    popTimerM().showTimer = timer;
    
}

- (void)timerChange {
    // 时间差+
    [popTimerM().timerMdic enumerateKeysAndObjectsUsingBlock:^(NSString *key, TFY_PopViewTimerModel *obj, BOOL *stop) {
        if (!obj.isPause) {
            
            obj.time = obj.time-10.0;
            
            if (obj.unit>-1) {
                obj.unit = obj.unit-10.0;
            }
            
            if (obj.time<0) {//计时结束
                obj.time = 0;
                obj.isPause = YES;
            }
            NSInteger totalSeconds = obj.time/1000.0;
            NSString *days = [NSString stringWithFormat:@"%zd", totalSeconds/60/60/24];
            NSString *hours =  [NSString stringWithFormat:@"%zd", totalSeconds/60/60%24];
            NSString *minute = [NSString stringWithFormat:@"%zd", (totalSeconds/60)%60];
            NSString *second = [NSString stringWithFormat:@"%zd", totalSeconds%60];
            CGFloat sss = ((NSInteger)(obj.time))%1000/10;
            NSString *ms = [NSString stringWithFormat:@"%.lf", sss];
            
            if (hours.integerValue < 10) {
                hours = [NSString stringWithFormat:@"0%@", hours];
            }
            if (minute.integerValue < 10) {
                minute = [NSString stringWithFormat:@"0%@", minute];
            }
            if (second.integerValue < 10) {
                second = [NSString stringWithFormat:@"0%@", second];
            }
            if (ms.integerValue < 10) {
                ms = [NSString stringWithFormat:@"0%@", ms];
            }
            
            
            
            if (obj.unit<=-1) {
                if (obj.handleBlock) {obj.handleBlock(days,hours,minute,second,ms);}
                
                if (obj.NFType == TimerSecondChangeNFTypeMS) {
                    // 发出通知
                    [[NSNotificationCenter defaultCenter] postNotificationName:obj.NFName object:nil userInfo:nil];
                }
            }else if (obj.unit == 0) {
                if (obj.handleBlock) {obj.handleBlock(days,hours,minute,second,ms);}
                obj.unit = 1000;
                if (obj.NFType == TimerSecondChangeNFTypeSecond) {
                    // 发出通知
                    [[NSNotificationCenter defaultCenter] postNotificationName:obj.NFName object:nil userInfo:nil];
                }
            }
            
            if (obj.isDisk) {
                [TFY_PopTimer savaForTimerModel:obj];
            }
            
            if (obj.time<=0) {//计时器计时完毕自动移除计时任务
                if (obj.finishBlock) { obj.finishBlock(obj.identifier); }
                [popTimerM().timerMdic removeObjectForKey:obj.identifier];
                [TFY_PopTimer deleteForIdentifier:obj.identifier];
            }
            
        }
    }];
  
}

- (NSMutableDictionary<NSString *,TFY_PopViewTimerModel *> *)timerMdic {
    if(_timerMdic) return _timerMdic;
    _timerMdic = [NSMutableDictionary dictionary];
    return _timerMdic;
}



#pragma mark - ***** other *****

+ (BOOL)timerIsExistInDiskForIdentifier:(NSString *)identifier {
    NSString *filePath = TFYPopViewTimerPath(identifier);
    BOOL isExist = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
    return isExist;
}

/** 格式化时间  */
+ (void)formatDateForTime:(NSTimeInterval)time handle:(TimerChangeBlock)handle {
    if (handle) {
        NSInteger totalSeconds = time/1000.0;
        NSString *days = [NSString stringWithFormat:@"%zd", totalSeconds/60/60/24];
        NSString *hours =  [NSString stringWithFormat:@"%zd", totalSeconds/60/60%24];
        NSString *minute = [NSString stringWithFormat:@"%zd", (totalSeconds/60)%60];
        NSString *second = [NSString stringWithFormat:@"%zd", totalSeconds%60];
        CGFloat sss = ((NSInteger)(time))%1000/10;
        NSString *ms = [NSString stringWithFormat:@"%.lf", sss];
        
        if (hours.integerValue < 10) {
            hours = [NSString stringWithFormat:@"0%@", hours];
        }
        if (minute.integerValue < 10) {
            minute = [NSString stringWithFormat:@"0%@", minute];
        }
        if (second.integerValue < 10) {
            second = [NSString stringWithFormat:@"0%@", second];
        }
        if (ms.integerValue < 10) {
            ms = [NSString stringWithFormat:@"0%@", ms];
        }
        
        handle(days,hours,minute,second,ms);
    }
}


+ (BOOL)savaForTimerModel:(TFY_PopViewTimerModel *)model {
    NSString *filePath = TFYPopViewTimerPath(model.identifier);
    NSError * error;
    NSData * data = [NSKeyedArchiver archivedDataWithRootObject:model requiringSecureCoding:YES error:&error];
    return [data writeToFile:filePath atomically:YES];
}

+ (TFY_PopViewTimerModel *)loadTimerForIdentifier:(NSString *)identifier{
    NSString *filePath = TFYPopViewTimerPath(identifier);
    NSError *error=nil;
    NSData * unData = [NSData dataWithContentsOfFile:filePath];
    id unarch;
    if (@available(iOS 14.0, *)) {
        unarch = [NSKeyedUnarchiver unarchivedArrayOfObjectsOfClass:TFY_PopViewTimerModel.class fromData:unData error:&error];
    } else {
        unarch = [NSKeyedUnarchiver unarchivedObjectOfClass:TFY_PopViewTimerModel.class fromData:unData error:&error];
    }
    return unarch;
}

+ (BOOL)deleteForIdentifier:(NSString *)identifier {
    NSString *filePath = TFYPopViewTimerPath(identifier);
    NSFileManager* fileManager = [NSFileManager defaultManager];
    BOOL isExist = [fileManager fileExistsAtPath:filePath];
    if (isExist) {
        return [fileManager removeItemAtPath:filePath error:nil];
    }
    return NO;
}

+ (TFY_PopViewTimerModel *)getTimerModelForIdentifier:(NSString *)identifier {
    if (identifier.length<=0) {
        return nil;
    }
    TFY_PopViewTimerModel *model = [TFY_PopTimer loadTimerForIdentifier:identifier];
    return model;
    
}

@end
