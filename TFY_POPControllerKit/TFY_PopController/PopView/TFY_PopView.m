//
//  TFY_PopView.m
//  TFY_POPControllerKit
//
//  Created by 田风有 on 2023/4/13.
//

#import "TFY_PopView.h"
#import <objc/runtime.h>
#import "TFY_PopTimer.h"

static NSString *const PopViewLogTitle = @"PopView日志 ---> :";
static PopViewLogStyle _logStyle;


@interface TFY_PopViewManager : NSObject

/** 单例 */
TFY_PopViewManager *PopViewM(void);

@end

@interface TFY_PopViewManager ()

/** 储存已经展示popView */
@property (nonatomic,strong) NSMutableArray *popViewMarr;
/** 按顺序弹窗顺序存储已显示的 popview  */
@property (nonatomic,strong) NSPointerArray *showList;
/** 储存待移除的popView  */
@property (nonatomic,strong) NSHashTable <TFY_PopView *> *removeList;
/** 内存信息View */
@property (nonatomic,strong) UILabel *infoView;

@end

@implementation TFY_PopViewManager

static TFY_PopViewManager *_instance;

TFY_PopViewManager *PopViewM(void) {
    return [TFY_PopViewManager sharedInstance];
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

+ (NSArray *)getAllPopView {
    return PopViewM().popViewMarr;
}
/** 获取当前页面所有popView */
+ (NSArray *)getAllPopViewForParentView:(UIView *)parentView {
    NSMutableArray *mArr = PopViewM().popViewMarr;
    NSMutableArray *resMarr = [NSMutableArray array];
    for (id obj in mArr) {
        TFY_PopView *popView = (TFY_PopView *)obj;
        if ([popView.parentView isEqual:parentView]) {
            [resMarr addObject:obj];
        }
    }
    return [NSArray arrayWithArray:resMarr];
}

/** 获取当前页面指定编队的所有popView */
+ (NSArray *)getAllPopViewForPopView:(TFY_PopView *)popView {
    NSArray *mArr = [self getAllPopViewForParentView:popView.parentView];
    NSMutableArray *resMarr = [NSMutableArray array];
    for (id obj in mArr) {
        TFY_PopView *tPopView = (TFY_PopView *)obj;
        
        if (popView.groupId == nil && tPopView.groupId == nil) {
            [resMarr addObject:obj];
            continue;
        }
        if ([tPopView.groupId isEqual:popView.groupId]) {
            [resMarr addObject:obj];
            continue;
        }
    }
    return [NSArray arrayWithArray:resMarr];
}

/** 读取popView */
+ (TFY_PopView *)getPopViewForKey:(NSString *)key {
    if (key.length<=0) { return nil; }
    NSMutableArray *mArr = PopViewM().popViewMarr;
    for (id obj in mArr) {
        TFY_PopView *popView = (TFY_PopView *)obj;
        if ([popView.identifier isEqualToString:key]) {
            return popView;
        }
    }
    return nil;
}

+ (void)savePopView:(TFY_PopView *)popView {
    [PopViewM().popViewMarr addObject:popView];
    
    //优先级排序
    [self sortingArr];
    
    if (_logStyle & PopViewLogStyleWindow) {
        [self setInfoData];
    }
    if (_logStyle & PopViewLogStyleConsole) {
        [self setConsoleLog];
    }
}

/** 移除popView */
+ (void)removePopView:(TFY_PopView *)popView {
    if (!popView) { return; }
    NSArray *arr = PopViewM().popViewMarr;
    for (id obj in arr) {
        TFY_PopView *tPopView = (TFY_PopView *)obj;
        
        if ([tPopView isEqual:popView]) {
            [tPopView dismissWithStyle:DismissStyleNO];
            break;
        }
    }
    
    if (_logStyle & PopViewLogStyleWindow) {
        [self setInfoData];
    }
    if (_logStyle & PopViewLogStyleConsole) {
        [self setConsoleLog];
    }
}

/** 移除popView */
+ (void)removePopViewForKey:(NSString *)key complete:(Block_Void)complete {
    if (key.length<=0) {
        complete ? complete() : nil;
        return;
    }
    
    NSArray *arr = PopViewM().popViewMarr;
    TFY_PopView *temp;
    for (id obj in arr) {
        TFY_PopView *tPopView = (TFY_PopView *)obj;
        
        if ([tPopView.identifier isEqualToString:key]) {
            temp = tPopView;
            tPopView.popViewDidDismissBlock = complete;
            [tPopView dismissWithStyle:DismissStyleNO];
            break;
        }
    }
    
    /// 此 key 没有对应的 popview. 也应该回调
    if (temp == nil) {
        complete ? complete() : nil;
    }
    
    if (_logStyle & PopViewLogStyleWindow) {
        [self setInfoData];
    }
    if (_logStyle & PopViewLogStyleConsole) {
        [self setConsoleLog];
    }
}

/** 移除所有popView */
+ (void)removeAllPopViewComplete:(Block_Void)complete {
    NSMutableArray *arr = PopViewM().popViewMarr;
    if (arr.count <= 0) {
        complete ? complete() : nil;
        return;
    }
    
    NSArray *popViewMarr = [NSArray arrayWithArray:PopViewM().popViewMarr];
    
    NSInteger index = popViewMarr.count;
    [popViewMarr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL * stop) {
        TFY_PopView *tPopView = (TFY_PopView *)obj;
        
        if (index == idx + 1) {
            if (tPopView) {
                tPopView.popViewDidDismissBlock = complete;
            }else {
                complete ? complete() : nil;
            }
        }
        
        [tPopView dismissWithStyle:DismissStyleNO];
    }];
    
    if (_logStyle & PopViewLogStyleWindow) {
        [self setInfoData];
    }
    if (_logStyle & PopViewLogStyleConsole) {
        [self setConsoleLog];
    }
}

+ (void)removeLastPopViewComplete:(Block_Void)complete {
    NSPointerArray *showList =  PopViewM().showList;
    if (showList.allObjects.count == 0) {
        complete ? complete() : nil;
        return;
    }
    
    for (NSInteger i = showList.count - 1; i >= 0; i --) {
        TFY_PopView *popView = [showList pointerAtIndex:i];
        if (popView) {
            popView.popViewDidDismissBlock = complete;
            [self removePopView:popView];
            [showList addPointer:NULL];
            [showList compact];
            break;
        }
    }
}

#pragma mark - ***** Other 其他 *****

+ (void)setInfoData {
    PopViewM().infoView.text = [NSString stringWithFormat:@"S:%zd R:%zd",PopViewM().popViewMarr.count,PopViewM().removeList.allObjects.count];
}

+ (void)setConsoleLog {
    TFYPopLog(@"%@ S:%zd个 R:%zd个",PopViewLogTitle,PopViewM().popViewMarr.count,PopViewM().removeList.allObjects.count);
}

//冒泡排序
+ (void)sortingArr {
    NSMutableArray *arr = PopViewM().popViewMarr;
    for (int i = 0; i < arr.count; i++) {
        for (int j = i+1; j < arr.count; j++) {
            TFY_PopView *iPopView = (TFY_PopView *)arr[i];
            
            TFY_PopView *jPopView = (TFY_PopView *)arr[j];
            
            if (iPopView.priority > jPopView.priority) {
                [arr exchangeObjectAtIndex:i withObjectAtIndex:j];
            }
        }
    }
}

/** 转移popView到待移除队列 */
+ (void)transferredToRemoveQueueWithPopView:(TFY_PopView *)popView {
    NSArray *popViewMarr = PopViewM().popViewMarr;
    
    [popViewMarr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL * stop) {
        TFY_PopView *tPopView = (TFY_PopView *)obj;
        
        if ([popView isEqual:tPopView]) {
            [PopViewM().removeList addObject:obj];
            [PopViewM().popViewMarr removeObject:obj];
        }
    }];
}

+ (void)destroyInRemoveQueue:(TFY_PopView *)popView {
    if (PopViewM().removeList.allObjects.count <= 0) {
        [self transferredToRemoveQueueWithPopView:popView];
    }
   
    if (_logStyle&PopViewLogStyleWindow) {
        [self setInfoData];
    }
    if (_logStyle&PopViewLogStyleConsole) {
        [self setConsoleLog];
    }
}

#pragma mark - ***** 懒加载 *****

- (UILabel *)infoView {
    if(_infoView) return _infoView;
    _infoView = [[UILabel alloc] init];
    _infoView.backgroundColor = UIColor.orangeColor;
    _infoView.textAlignment = NSTextAlignmentCenter;
    _infoView.font = [UIFont systemFontOfSize:11];
    _infoView.frame = CGRectMake(pop_ScreenWidth()-70, pop_IsIphoneX_ALL()? 40:20, 60, 10);
    _infoView.layer.cornerRadius = 1;
    _infoView.layer.masksToBounds = YES;
    UIView *superView = [UIApplication sharedApplication].keyWindow;
    [superView addSubview:_infoView];
    return _infoView;
}

- (NSMutableArray *)popViewMarr {
    if(_popViewMarr) return _popViewMarr;
    _popViewMarr = [NSMutableArray array];
    return _popViewMarr;
}

- (NSHashTable<TFY_PopView *> *)removeList {
    if (_removeList) return _removeList;
    _removeList = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
    return _removeList;
}

- (NSPointerArray *)showList {
    if (_showList) return _showList;
    _showList = [NSPointerArray pointerArrayWithOptions:(NSPointerFunctionsWeakMemory)];
    return _showList;
}

@end


static const NSTimeInterval PopViewDefaultDuration = -1.0f;
// 角度转弧度
#define TFY_DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)


@interface TFY_PopViewBgView : UIView

/** 是否隐藏背景 默认NO */
@property (nonatomic, assign) BOOL isHideBg;

@end

@implementation TFY_PopViewBgView

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    UIView *hitView = [super hitTest:point withEvent:event];
    if(hitView == self && self.isHideBg){
        return nil;
    }
    return hitView;
}

@end

@interface TFY_PopView ()<UIGestureRecognizerDelegate>
/** 弹窗容器 默认是app UIWindow 可指定view作为容器 */
@property (nonatomic, weak) UIView *container;
/** 背景层 */
@property (nonatomic, strong) TFY_PopViewBgView *backgroundView;
/** 自定义视图 */
@property (nonatomic,strong) UIView *customView;
/** 规避键盘偏移量 */
@property (nonatomic, assign) CGFloat avoidKeyboardOffset;
/** 代理池 */
@property (nonatomic, strong) NSHashTable <id<TFY_PopViewProtocol>> *delegates;
/** 背景点击手势 */
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
/** 自定义View滑动手势 */
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;
//当前正在拖拽的是否是tableView
@property (nonatomic, assign) BOOL isDragScrollView;
/** 标记popView中是否有UIScrollView, UITableView, UICollectionView */
@property (nonatomic, weak) UIScrollView *scrollerView;
/** 记录自定义view原始Frame */
@property (nonatomic, assign) CGRect originFrame;
/** 标记dragDismissStyle是否被复制 */
@property (nonatomic, assign) BOOL isDragDismissStyle;
/** 是否弹出键盘 */
@property (nonatomic,assign,readonly) BOOL isShowKeyboard;
/** 弹出键盘的高度 */
@property (nonatomic, assign) CGFloat keyboardY;

/// 关闭完成回调集
@property (nonatomic , strong) NSHashTable * popViewDidDismissBlocks;

@end

@implementation TFY_PopView

#pragma mark - ***** 初始化 *****

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initSubViews];
    }
    return self;
}

- (void)initSubViews {
    //初始化配置
    _isClickBgDismiss = NO;
    _isObserverScreenRotation = YES;
    _bgAlpha = 0.25;
    _popStyle = PopStyleFade;
    _dismissStyle = DismissStyleFade;
    _popDuration = PopViewDefaultDuration;
    _dismissDuration = PopViewDefaultDuration;
    _hemStyle = HemStyleCenter;
    _adjustX = 0;
    _adjustY = 0;
    _isClickFeedback = NO;
    _isAvoidKeyboard = YES;
    _avoidKeyboardSpace = 10;
    _bgColor = [UIColor blackColor];
    _identifier = @"";
    _isShowKeyboard = NO;
    _showTime = 0.0;
    _priority = 0;
    _isHideBg = NO;
    _isShowKeyboard = NO;
    _isImpactFeedback = NO;
    _rectCorners = UIRectCornerAllCorners;
    
    _isSingle = NO;
    
    //拖拽相关属性初始化
    _dragStyle = DragStyleNO;
    _dragDismissStyle = DismissStyleNO;
    _dragDistance = 0.0f;
    _dragReboundTime = 0.25;
    _dragDismissDuration = PopViewDefaultDuration;
    _swipeVelocity = 1000.0f;
    
    _isDragDismissStyle = NO;
}

+ (nullable instancetype)initWithCustomView:(UIView *_Nonnull)customView {
    return [self initWithCustomView:customView popStyle:PopStyleNO dismissStyle:DismissStyleNO];
}


+ (nullable instancetype)initWithCustomView:(UIView *_Nonnull)customView
                                   popStyle:(PopStyle)popStyle
                               dismissStyle:(DismissStyle)dismissStyle {
    
    return [self initWithCustomView:customView
                         parentView:nil
                           popStyle:popStyle
                       dismissStyle:dismissStyle];
}

+ (nullable instancetype)initWithCustomView:(UIView *_Nonnull)customView
                                 parentView:(UIView *)parentView
                                   popStyle:(PopStyle)popStyle
                               dismissStyle:(DismissStyle)dismissStyle {
    // 检测自定义视图是否存在(check customView is exist)
    if (!customView) { return nil; }
    if (![parentView isKindOfClass:[UIView class]] && parentView != nil) {
        TFYPopLog(@"parentView is error !!!");
        return nil;
    }
    
    CGRect popViewFrame = CGRectZero;
    if (parentView) {
        popViewFrame =  parentView.bounds;
    } else {
        popViewFrame =  CGRectMake(0, 0, pop_ScreenWidth(), pop_ScreenHeight());
    }
    
    TFY_PopView *popView = [[TFY_PopView alloc] initWithFrame:popViewFrame];
    popView.backgroundColor = [UIColor clearColor];

    popView.container = parentView? parentView : [UIApplication sharedApplication].keyWindow;

    popView.customView = customView;
    popView.backgroundView = [[TFY_PopViewBgView alloc] initWithFrame:popView.bounds];
    popView.backgroundView.backgroundColor = [UIColor clearColor];
    popView.popStyle = popStyle;
    popView.dismissStyle = dismissStyle;
    
    [popView addSubview:popView.backgroundView];
    [popView.backgroundView addSubview:customView];
    
    //背景添加手势
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:popView action:@selector(popViewBgViewTap:)];
    tap.delegate = popView;
    popView.tapGesture = tap;
    [popView.backgroundView addGestureRecognizer:tap];
    
    //添加拖拽手势
    popView.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:popView action:@selector(pan:)];
    popView.panGesture.delegate = popView;
    [popView.customView addGestureRecognizer:popView.panGesture];
    
    //    [popView.backgroundView addTarget:popView action:@selector(popViewBgViewTap:) forControlEvents:UIControlEventTouchUpInside];;
    
    
    //    UILongPressGestureRecognizer *customViewLP = [[UILongPressGestureRecognizer alloc] initWithTarget:popView action:@selector(bgLongPressEvent:)];
    //    [popView.backgroundView addGestureRecognizer:customViewLP];
    
    //    UITapGestureRecognizer *customViewTap = [[UITapGestureRecognizer alloc] initWithTarget:popView action:@selector(customViewClickEvent:)];
    //    [popView.customView addGestureRecognizer:customViewTap];
    
    //键盘将要显示
    [[NSNotificationCenter defaultCenter] addObserver:popView
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    //键盘显示完毕
    [[NSNotificationCenter defaultCenter] addObserver:popView
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    //键盘frame将要改变
    [[NSNotificationCenter defaultCenter] addObserver:popView
                                             selector:@selector(keyboardWillChangeFrame:)
                                                 name:UIKeyboardWillChangeFrameNotification
                                               object:nil];
    //键盘frame改变完毕
    [[NSNotificationCenter defaultCenter] addObserver:popView
                                             selector:@selector(keyboardDidChangeFrame:)
                                                 name:UIKeyboardDidChangeFrameNotification
                                               object:nil];
    //键盘将要收起
    [[NSNotificationCenter defaultCenter] addObserver:popView
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    //键盘收起完毕
    [[NSNotificationCenter defaultCenter] addObserver:popView
                                             selector:@selector(keyboardDidHide:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];
    //屏幕旋转
    [[NSNotificationCenter defaultCenter] addObserver:popView
                                             selector:@selector(statusBarOrientationChange:)
                                                 name:UIApplicationDidChangeStatusBarOrientationNotification
                                               object:nil];
    //监听customView frame
    [popView.customView addObserver:popView
                         forKeyPath:@"frame"
                            options:NSKeyValueObservingOptionOld
                            context:NULL];
    return popView;
}

- (void)dealloc {
    [self.customView removeObserver:self forKeyPath:@"frame"];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    //从待移除队列中销毁
    [TFY_PopViewManager destroyInRemoveQueue:self];
    [self tfy_PopViewDidDismissForPopView:self];
    
    for (Block_Void block in _popViewDidDismissBlocks.copy) {
        block ? block() : nil;
    }
    
    [_popViewDidDismissBlocks removeAllObjects];
}

- (void)removeFromSuperview {

    [super removeFromSuperview];
    
    [TFY_PopViewManager transferredToRemoveQueueWithPopView:self];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *hitView = [super hitTest:point withEvent:event];
    if (hitView != self.customView) {
        if(hitView == self && self.isHideBg){ return nil; }
    }
    return hitView;
}

#pragma mark - ***** 代理方法 *****
- (void)tfy_PopViewBgClickForPopView:(TFY_PopView *)popView {
    for (id<TFY_PopViewProtocol> delegate in _delegates.copy) {
        if ([delegate respondsToSelector:_cmd]) {
            [delegate tfy_PopViewBgClickForPopView:popView];
        }
    }
}

- (void)tfy_PopViewBgLongPressForPopView:(TFY_PopView *)popView {
    for (id<TFY_PopViewProtocol> delegate in _delegates.copy) {
        if ([delegate respondsToSelector:_cmd]) {
            [delegate tfy_PopViewBgLongPressForPopView:popView];
        }
    }
}

- (void)tfy_PopViewWillPopForPopView:(TFY_PopView *)popView {
    for (id<TFY_PopViewProtocol> delegate in _delegates.copy) {
        if ([delegate respondsToSelector:_cmd]) {
            [delegate tfy_PopViewWillPopForPopView:popView];
        }
    }
}

- (void)tfy_PopViewDidPopForPopView:(TFY_PopView *)popView {
    for (id<TFY_PopViewProtocol> delegate in _delegates.copy) {
        if ([delegate respondsToSelector:_cmd]) {
            [delegate tfy_PopViewDidPopForPopView:popView];
        }
    }
}

- (void)tfy_PopViewCountDownForPopView:(TFY_PopView *)popView forCountDown:(NSTimeInterval)timeInterval {
    for (id<TFY_PopViewProtocol> delegate in _delegates.copy) {
        if ([delegate respondsToSelector:_cmd]) {
            [delegate tfy_PopViewCountDownForPopView:popView forCountDown:timeInterval];
        }
    }
}

- (void)tfy_PopViewCountDownFinishForPopView:(TFY_PopView *)popView {
    for (id<TFY_PopViewProtocol> delegate in _delegates.copy) {
        if ([delegate respondsToSelector:_cmd]) {
            [delegate tfy_PopViewCountDownFinishForPopView:popView];
        }
    }
}

- (void)tfy_PopViewWillDismissForPopView:(TFY_PopView *)popView {
    for (id<TFY_PopViewProtocol> delegate in _delegates.copy) {
        if ([delegate respondsToSelector:_cmd]) {
            [delegate tfy_PopViewWillDismissForPopView:popView];
        }
    }
}

- (void)tfy_PopViewDidDismissForPopView:(TFY_PopView *)popView {
    for (id<TFY_PopViewProtocol> delegate in _delegates.copy) {
        if ([delegate respondsToSelector:_cmd]) {
            [delegate tfy_PopViewDidDismissForPopView:popView];
        }
    }
}

#pragma mark - ***** 界面布局 *****

- (void)setCustomViewFrameWithHeight:(CGFloat)height {
    
    CGFloat changeY = 0;
    switch (self.hemStyle) {
        case HemStyleTop ://贴顶
        {
            self.customView.pop_X = _backgroundView.pop_CenterX - _customView.pop_Size.width*0.5 + _adjustX;
            self.customView.pop_Y = _adjustY;
            changeY = _adjustY;
        }
            break;
        case HemStyleLeft ://贴左
        {
            self.customView.pop_X = _adjustX;
            self.customView.pop_Y = _backgroundView.pop_CenterY - _customView.pop_Size.height*0.5 + _adjustY;
            changeY = height*0.5;
        }
            break;
        case HemStyleBottom ://贴底
        {
            self.customView.pop_X = _backgroundView.pop_CenterX - _customView.pop_Size.width*0.5 + _adjustX;
            [self.customView layoutIfNeeded];
            self.customView.pop_Y = _backgroundView.pop_Height - _customView.pop_Height + _adjustY;
            changeY = height;
        }
            break;
        case HemStyleRight ://贴右
        {
            self.customView.pop_X = _backgroundView.pop_Width - _customView.pop_Width + _adjustX;
            self.customView.pop_Y = _backgroundView.pop_CenterY - _customView.pop_Size.height*0.5 + _adjustY;
            changeY = height*0.5;
        }
            break;
        case HemStyleTopLeft :///贴顶和左
        {
            self.customView.pop_X = _adjustX;
            self.customView.pop_Y = _adjustY;
            changeY = _adjustY;
        }
            break;
        case HemStyleBottomLeft ://贴底和左
        {
            self.customView.pop_X = _adjustX;
            [self.customView layoutIfNeeded];
            self.customView.pop_Y = _backgroundView.pop_Height - _customView.pop_Height + _adjustY;
            changeY = height;
        }
            break;
        case HemStyleBottomRight ://贴底和右
        {
            self.customView.pop_X = _backgroundView.pop_Width - _customView.pop_Width + _adjustX;
            [self.customView layoutIfNeeded];
            self.customView.pop_Y = _backgroundView.pop_Height - _customView.pop_Height + _adjustY;
            changeY = height;
        }
            break;
        case HemStyleTopRight ://贴顶和右
        {
            self.customView.pop_X = _backgroundView.pop_Width - _customView.pop_Width + _adjustX;
            self.customView.pop_Y = _adjustY;
            changeY = _adjustY;
        }
            break;
        default://居中
        {
            self.customView.pop_X = _backgroundView.pop_CenterX - _customView.pop_Size.width*0.5 + _adjustX;
            self.customView.pop_Y = _backgroundView.pop_CenterY - _customView.pop_Size.height*0.5 + _adjustY;
            changeY = height*0.5;
        }
            break;
    }
    
    CGFloat originBottom = _originFrame.origin.y + _originFrame.size.height + _avoidKeyboardSpace;
    if (_isShowKeyboard && (originBottom > _keyboardY)) {//键盘已经显示
        CGFloat Y = _keyboardY - _customView.pop_Height - _avoidKeyboardSpace;
        _customView.pop_Y = Y;
        CGRect newFrame = _originFrame;
        newFrame.origin.y = newFrame.origin.y - changeY;
        newFrame.size = CGSizeMake(_originFrame.size.width, _customView.pop_Height);
        self.originFrame = newFrame;
    }else {//没有键盘显示
        self.originFrame = _customView.frame;
    }
    
    [self setCustomViewCorners];
}

- (void)setCustomViewCorners {
    
    BOOL isSetCorner = NO;
    
    if (self.rectCorners & UIRectCornerTopLeft) {
        isSetCorner = YES;
    }
    if (self.rectCorners & UIRectCornerTopRight) {
        isSetCorner = YES;
    }
    if (self.rectCorners & UIRectCornerBottomLeft) {
        isSetCorner = YES;
    }
    if (self.rectCorners & UIRectCornerBottomRight) {
        isSetCorner = YES;
    }
    if (self.rectCorners & UIRectCornerAllCorners) {
        isSetCorner = YES;
    }
    
    if (isSetCorner && self.cornerRadius>0) {
        UIBezierPath * path = [UIBezierPath bezierPathWithRoundedRect:self.customView.bounds byRoundingCorners:self.rectCorners cornerRadii:CGSizeMake(self.cornerRadius, self.cornerRadius)];
        
        CAShapeLayer * layer = [[CAShapeLayer alloc]init];
        layer.frame = self.customView.bounds;
        layer.path = path.CGPath;
        self.customView.layer.mask = layer;
    }
    
}

#pragma mark - ***** setter 设置器/数据处理 *****

- (void)setPopDuration:(NSTimeInterval)popDuration {
    if (popDuration <= 0.0) { return; }
    _popDuration = popDuration;
}

- (void)setDismissDuration:(NSTimeInterval)dismissDuration {
    if (dismissDuration <= 0.0) { return; }
    _dismissDuration = dismissDuration;
}

- (void)setDragDismissDuration:(NSTimeInterval)dragDismissDuration {
    if (dragDismissDuration <= 0.0) { return; }
    _dragDismissDuration = dragDismissDuration;
}

- (void)setHemStyle:(HemStyle)hemStyle {
    _hemStyle = hemStyle;
}

- (void)setAdjustX:(CGFloat)adjustX {
    _adjustX = adjustX;
//    self.customView.x = _customView.x + adjustX;
//    self.originFrame = _customView.frame;
    [self setCustomViewFrameWithHeight:0];
}

- (void)setAdjustY:(CGFloat)adjustY {
    _adjustY = adjustY;
//    self.customView.y = _customView.y + adjustY;
//    self.originFrame = _customView.frame;
    [self setCustomViewFrameWithHeight:0];
}

- (void)setIsObserverScreenRotation:(BOOL)isObserverScreenRotation {
    _isObserverScreenRotation = isObserverScreenRotation;
}

- (void)setBgAlpha:(CGFloat)bgAlpha {
    _bgAlpha = (bgAlpha <= 0.0f) ? 0.0f : ((bgAlpha > 1.0) ? 1.0 : bgAlpha);
    }

- (void)setIsClickFeedback:(BOOL)isClickFeedback {
    _isClickFeedback = isClickFeedback;
}

- (void)setIsHideBg:(BOOL)isHideBg {
    _isHideBg = isHideBg;
    self.backgroundView.isHideBg = isHideBg;
    self.backgroundView.backgroundColor = [self getNewColorWith:self.bgColor alpha:0.0];
}

- (void)setShowTime:(NSTimeInterval)showTime {
    _showTime = showTime;
}

- (void)setDelegate:(id<TFY_PopViewProtocol>)delegate {
    if ([self.delegates containsObject:delegate]) return;
    [self.delegates addObject:delegate];
}

- (void)setDragDismissStyle:(DismissStyle)dragDismissStyle {
    _dragDismissStyle = dragDismissStyle;
    self.isDragDismissStyle = YES;
}

- (void)setPopViewDidDismissBlock:(void (^)(void))popViewDidDismissBlock
{
    if (popViewDidDismissBlock) {
        [self.popViewDidDismissBlocks addObject:popViewDidDismissBlock];
    }
}

#pragma mark - ***** pop 弹出 *****
- (void)pop {
    [self popWithStyle:self.popStyle duration:self.popDuration];
}

- (void)popWithStyle:(PopStyle)popStyle {
    [self popWithStyle:popStyle duration:self.popDuration];
}

- (void)popWithDuration:(NSTimeInterval)duration {
    [self popWithStyle:self.popStyle duration:duration];
}

- (void)popWithStyle:(PopStyle)popStyle duration:(NSTimeInterval)duration {
    [self popWithPopStyle:popStyle duration:duration isOutStack:NO];
}

- (void)popWithPopStyle:(PopStyle)popStyle duration:(NSTimeInterval)duration isOutStack:(BOOL)isOutStack {
    
    NSTimeInterval resDuration = [self getPopDuration:duration];
    
    [self setCustomViewFrameWithHeight:0];
    
    self.originFrame = self.customView.frame;

    BOOL startTimer = NO;
    
    if (self.isSingle) {//单显
        NSArray *popViewArr = [TFY_PopViewManager getAllPopViewForPopView:self];
        for (id obj  in popViewArr) {//移除所有popView和移除定a时器
            TFY_PopView *lastPopView = (TFY_PopView *)obj;
            
            [lastPopView dismissWithDismissStyle:DismissStyleNO duration:0.2 isRemove:YES];
        }
        startTimer = YES;
    }else {//多显
        if (!isOutStack) {//处理隐藏倒数第二个popView
            NSArray *popViewArr = [TFY_PopViewManager getAllPopViewForPopView:self];
            if (popViewArr.count >= 1) {
                id obj = popViewArr[popViewArr.count - 1];
                TFY_PopView *lastPopView = (TFY_PopView *)obj;
                
                if (self.isStack) {//堆叠显示
                    startTimer = YES;
                }else {
                    if (self.priority >= lastPopView.priority) {//置顶显示
                        if (lastPopView.isShowKeyboard) {
                            [lastPopView endEditing:YES];
                        }
                        [lastPopView dismissWithDismissStyle:DismissStyleFade duration:0.2 isRemove:NO];
                        startTimer = YES;
                    } else {//隐藏显示
                        if (!self.parentView) {
                            self.container = [UIApplication sharedApplication].keyWindow;
                        }
                        [TFY_PopViewManager savePopView:self];
                        return;
                    }
                }
            } else {
                startTimer = YES;
            }
        }
    }
    
//    if (!isOutStack){
//        [self.parentView addSubview:self];
//    }
    if (!self.superview) {
        [self.container addSubview:self];
        [PopViewM().showList addPointer:(__bridge void * _Nullable)self];
    }
    
    if (!isOutStack){
        [self tfy_PopViewWillPopForPopView:self];
        
        self.popViewWillPopBlock? self.popViewWillPopBlock():nil;
    }
    //动画处理
    [self popAnimationWithPopStyle:popStyle duration:resDuration];
    //震动反馈
    [self beginImpactFeedback];
    
    TFY_PopViewWK(self);;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(resDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        if (!isOutStack){
            [self tfy_PopViewDidPopForPopView:self];
            wk_self.popViewDidPopBlock? wk_self.popViewDidPopBlock():nil;
        }
        if (startTimer){ [self startTimer]; }
    });
    
    //保存popView
    if (!isOutStack) { [TFY_PopViewManager savePopView:self]; }
}

- (void)popAnimationWithPopStyle:(PopStyle)popStyle duration:(NSTimeInterval)duration {
    
    TFY_PopViewWK(self);
    if (popStyle == PopStyleFade) {//渐变出现
        self.backgroundView.backgroundColor = [self getNewColorWith:self.bgColor alpha:0.0];
        self.customView.alpha = 0.0f;
        [UIView animateWithDuration:0.2 animations:^{
            self.backgroundView.backgroundColor =[self getNewColorWith:self.bgColor alpha:self.bgAlpha];
            self.customView.alpha = 1.0f;
        }];
    } else if (popStyle == PopStyleNO){//无动画
        self.backgroundView.backgroundColor = [self getNewColorWith:self.bgColor alpha:0.0];
        [UIView animateWithDuration:0.1 animations:^{
            self.backgroundView.backgroundColor =[self getNewColorWith:self.bgColor alpha:self.bgAlpha];
        }];
        self.customView.alpha = 1.0f;
    } else {//有动画
        self.backgroundView.backgroundColor = [self getNewColorWith:self.bgColor alpha:0.0];
        [UIView animateWithDuration:duration animations:^{
            wk_self.backgroundView.backgroundColor = [self getNewColorWith:self.bgColor alpha:self.bgAlpha];
        }];
        //自定义view过渡动画
        [self hanlePopAnimationWithDuration:duration popStyle:popStyle];
    }
}

- (void)hanlePopAnimationWithDuration:(NSTimeInterval)duration
                             popStyle:(PopStyle)popStyle {
    
    self.alpha = 0;
    [UIView animateWithDuration:duration*0.2 animations:^{
        self.alpha = 1;
    }];
    
    TFY_PopViewWK(self);
    switch (popStyle) {
        case PopStyleScale:// < 缩放动画，先放大，后恢复至原大小
        {
            [self animationWithLayer:_customView.layer duration:((0.3*duration)/0.7) values:@[@0.0, @1.2, @1.0]]; // 另外一组动画值(the other animation values) @[@0.0, @1.2, @0.9, @1.0]
        }
            break;
        case PopStyleSmoothFromTop:
        case PopStyleSmoothFromBottom:
        case PopStyleSmoothFromLeft:
        case PopStyleSmoothFromRight:
        case PopStyleSpringFromTop:
        case PopStyleSpringFromLeft:
        case PopStyleSpringFromBottom:
        case PopStyleSpringFromRight:
        {
            CGPoint startPosition = self.customView.layer.position;
            if (popStyle == PopStyleSmoothFromTop || popStyle == PopStyleSpringFromTop) {
                self.customView.layer.position = CGPointMake(startPosition.x, -_customView.pop_Height*0.5);
                
            } else if (popStyle == PopStyleSmoothFromLeft || popStyle == PopStyleSpringFromLeft) {
                self.customView.layer.position = CGPointMake(-_customView.pop_Width*0.5, startPosition.y);
                
            } else if (popStyle == PopStyleSmoothFromBottom || popStyle == PopStyleSpringFromBottom) {
                self.customView.layer.position = CGPointMake(startPosition.x, CGRectGetMaxY(self.frame) + _customView.pop_Height*0.5);
                
            } else {
                self.customView.layer.position = CGPointMake(CGRectGetMaxX(self.frame) + _customView.pop_Width*0.5 , startPosition.y);
            }
            
            CGFloat damping = 1.0;
            if (popStyle == PopStyleSpringFromTop||
                popStyle == PopStyleSpringFromLeft||
                popStyle == PopStyleSpringFromBottom||
                popStyle == PopStyleSpringFromRight) {
                damping = 0.65;
            }
            
            [UIView animateWithDuration:duration
                                  delay:0
                 usingSpringWithDamping:damping
                  initialSpringVelocity:1.0
                                options:UIViewAnimationOptionCurveEaseOut
                             animations:^{
                
                wk_self.customView.layer.position = startPosition;
            } completion:nil];
        }
            break;
        case PopStyleCardDropFromLeft:
        case PopStyleCardDropFromRight:
        {
            CGPoint startPosition = self.customView.layer.position;
            if (popStyle == PopStyleCardDropFromLeft) {
                self.customView.layer.position = CGPointMake(startPosition.x * 1.0, -_customView.pop_Height*0.5);
                self.customView.transform = CGAffineTransformMakeRotation(TFY_DEGREES_TO_RADIANS(15.0));
            } else {
                self.customView.layer.position = CGPointMake(startPosition.x * 1.0, -_customView.pop_Height*0.5);
                self.customView.transform = CGAffineTransformMakeRotation(TFY_DEGREES_TO_RADIANS(-15.0));
            }
            
            [UIView animateWithDuration:duration delay:0 usingSpringWithDamping:0.75 initialSpringVelocity:1.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                wk_self.customView.layer.position = startPosition;
            } completion:nil];
            
            [UIView animateWithDuration:duration*0.6 animations:^{
                wk_self.customView.layer.transform = CATransform3DMakeRotation(TFY_DEGREES_TO_RADIANS((popStyle == PopStyleCardDropFromRight) ? 5.5 : -5.5), 0, 0, 0);
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:duration*0.2 animations:^{
                    wk_self.customView.transform = CGAffineTransformMakeRotation(TFY_DEGREES_TO_RADIANS((popStyle == PopStyleCardDropFromRight) ? -1.0 : 1.0));
                } completion:^(BOOL finished) {
                    [UIView animateWithDuration:duration*0.2 animations:^{
                        wk_self.customView.transform = CGAffineTransformMakeRotation(0.0);
                    } completion:nil];
                }];
            }];
        }
            break;
        default:
            break;
    }
}

#pragma mark - ***** dismiss 移除 *****

- (void)dismiss {
    [self dismissWithStyle:self.dismissStyle duration:self.dismissDuration];
}

- (void)dismissWithStyle:(DismissStyle)dismissStyle {
    [self dismissWithStyle:dismissStyle duration:self.dismissDuration];
}

- (void)dismissWithDuration:(NSTimeInterval)duration {
    [self dismissWithStyle:self.dismissStyle duration:duration];
}

- (void)dismissWithStyle:(DismissStyle)dismissStyle duration:(NSTimeInterval)duration  {
    [self dismissWithDismissStyle:dismissStyle duration:duration isRemove:YES];
}

- (void)dismissWithDismissStyle:(DismissStyle)dismissStyle
                       duration:(NSTimeInterval)duration
                       isRemove:(BOOL)isRemove {
    
    NSTimeInterval resDuration = [self getDismissDuration:duration];
    
    if (isRemove) {
        //把当前popView转移到待移除队列 避免线程安全问题
        [TFY_PopViewManager transferredToRemoveQueueWithPopView:self];
    }
    
    [self tfy_PopViewWillDismissForPopView:self];
    
    self.popViewWillDismissBlock? self.popViewWillDismissBlock():nil;
    
    TFY_PopViewWK(self)
    [self dismissAnimationWithDismissStyle:dismissStyle duration:resDuration];
    
    if (!self.isSingle && (isRemove && [TFY_PopViewManager getAllPopViewForPopView:self].count >= 1)){//多显
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(resDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            //popView出栈
            if (!self.isStack && [TFY_PopViewManager getAllPopViewForPopView:self].count >= 1) {
                NSArray *popViewArr = [TFY_PopViewManager getAllPopViewForPopView:self];
                id obj = popViewArr[popViewArr.count-1];
                TFY_PopView *tPopView = (TFY_PopView *)obj;
                if (!tPopView.superview) {
                    [tPopView.container addSubview:tPopView];
                    [PopViewM().showList addPointer:(__bridge void * _Nullable)tPopView];
                }
                [tPopView popWithPopStyle:PopStyleFade duration:0.25 isOutStack:YES];
            }
        });
    }
    if (isRemove) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(resDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [wk_self removeFromSuperview];
        });
    }
}

- (void)dismissAnimationWithDismissStyle:(DismissStyle)dismissStyle duration:(NSTimeInterval)duration {
    
    TFY_PopViewWK(self);
    if (dismissStyle == PopStyleFade) {
        [UIView animateWithDuration:0.2 animations:^{
            wk_self.backgroundView.backgroundColor = [self getNewColorWith:self.bgColor alpha:0.0];
            wk_self.customView.alpha = 0.0f;
        }];
    }else if (dismissStyle == PopStyleNO){
        wk_self.backgroundView.backgroundColor = [self getNewColorWith:self.bgColor alpha:0.0];
        wk_self.customView.alpha = 0.0f;
    }else {//有动画
        [UIView animateWithDuration:duration*0.8 animations:^{
            wk_self.backgroundView.backgroundColor = [self getNewColorWith:self.bgColor alpha:0.0];
        }];
        [self hanleDismissAnimationWithDuration:duration withDismissStyle:dismissStyle];
    }
}

- (void)hanleDismissAnimationWithDuration:(NSTimeInterval)duration
                         withDismissStyle:(DismissStyle)dismissStyle {
    
    [UIView animateWithDuration:duration*0.8 animations:^{
        self.alpha = 0;
    }];
    
    TFY_PopViewWK(self);;
    switch (dismissStyle) {
        case DismissStyleScale:
        {
            [self animationWithLayer:self.customView.layer duration:((0.2*duration)/0.8) values:@[@1.0, @0.66, @0.33, @0.01]];
        }
            break;
        case DismissStyleSmoothToTop:
        case DismissStyleSmoothToBottom:
        case DismissStyleSmoothToLeft:
        case DismissStyleSmoothToRight:
        {
            CGPoint startPosition = self.customView.layer.position;
            CGPoint endPosition = self.customView.layer.position;
            if (dismissStyle == DismissStyleSmoothToTop) {
                endPosition = CGPointMake(startPosition.x, -(_customView.pop_Height*0.5));
                
            } else if (dismissStyle == DismissStyleSmoothToBottom) {
                endPosition = CGPointMake(startPosition.x, CGRectGetMaxY(self.frame) + _customView.pop_Height*0.5);
                
            } else if (dismissStyle == DismissStyleSmoothToLeft) {
                endPosition = CGPointMake(-_customView.pop_Width*0.5, startPosition.y);
                
            } else {
                endPosition = CGPointMake(CGRectGetMaxX(self.frame) + _customView.pop_Width*0.5, startPosition.y);
            }
            
            [UIView animateWithDuration:duration delay:0 usingSpringWithDamping:1.0 initialSpringVelocity:1.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                wk_self.customView.layer.position = endPosition;
            } completion:nil];
        }
            break;
        case DismissStyleCardDropToLeft:
        case DismissStyleCardDropToRight:
        {
            CGPoint startPosition = self.customView.layer.position;
            BOOL isLandscape = UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation);
            __block CGFloat rotateEndY = 0.0f;
            [UIView animateWithDuration:duration delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:1.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                if (dismissStyle == DismissStyleCardDropToLeft) {
                    wk_self.customView.transform = CGAffineTransformMakeRotation(M_1_PI * 0.75);
                    if (isLandscape) rotateEndY = fabs(wk_self.customView.frame.origin.y);
                    wk_self.customView.layer.position = CGPointMake(startPosition.x, CGRectGetMaxY(wk_self.frame) + startPosition.y + rotateEndY);
                } else {
                    wk_self.customView.transform = CGAffineTransformMakeRotation(-M_1_PI * 0.75);
                    if (isLandscape) rotateEndY = fabs(wk_self.customView.frame.origin.y);
                    wk_self.customView.layer.position = CGPointMake(startPosition.x * 1.25, CGRectGetMaxY(wk_self.frame) + startPosition.y + rotateEndY);
                }
            } completion:nil];
        }
            break;
        case DismissStyleCardDropToTop:
        {
            CGPoint startPosition = self.customView.layer.position;
            CGPoint endPosition = CGPointMake(startPosition.x, -startPosition.y);
            [UIView animateWithDuration:duration*0.2 animations:^{
                wk_self.customView.layer.position = CGPointMake(startPosition.x, startPosition.y + 50.0f);
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:duration*0.8 animations:^{
                    wk_self.customView.layer.position = endPosition;
                } completion:nil];
            }];
        }
            break;
        default:
            break;
    }
}

#pragma mark - ***** other 其他 *****

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if([keyPath isEqualToString:@"frame"]) {
        CGRect newFrame = CGRectNull;
        CGRect oldFrame = CGRectNull;
        if([object valueForKeyPath:keyPath] != [NSNull null]) {
            //此处为获取新的frame
            newFrame = [[object valueForKeyPath:keyPath] CGRectValue];
            oldFrame = [[change valueForKeyPath:@"old"] CGRectValue];
            if (!CGSizeEqualToSize(newFrame.size, oldFrame.size)) {
                [self setCustomViewFrameWithHeight:newFrame.size.height-oldFrame.size.height];
            }
        }
    }else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

//按钮的压下事件 按钮缩小
- (void)bgLongPressEvent:(UIGestureRecognizer *)ges {
    
    //    [self.delegateMarr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
    //
    //        if ([obj respondsToSelector:@selector(tfy_PopViewBgLongPressForPopView:)]) {
    //            [obj tfy_PopViewBgLongPressForPopView:self];
    //        }
    //
    //    }];
    
    self.bgLongPressBlock? self.bgLongPressBlock():nil;

    //    switch (ges.state) {
    //        case UIGestureRecognizerStateBegan:
    //        {
    //            CGFloat scale = 0.95;
    //            [UIView animateWithDuration:0.35 animations:^{
    //                ges.view.transform = CGAffineTransformMakeScale(scale, scale);
    //            }];
    //        }
    //            break;
    //        case UIGestureRecognizerStateEnded:
    //        case UIGestureRecognizerStateCancelled:
    //        {
    //            [UIView animateWithDuration:0.35 animations:^{
    //                ges.view.transform = CGAffineTransformMakeScale(1.0, 1.0);
    //            } completion:^(BOOL finished) {
    //            }];
    //        }
    //            break;
    //
    //        default:
    //            break;
    //    }
}

- (void)customViewClickEvent:(UIGestureRecognizer *)ges {
    if (self.isClickFeedback) {
        CGFloat scale = 0.95;
        [UIView animateWithDuration:0.25 animations:^{
            ges.view.transform = CGAffineTransformMakeScale(scale, scale);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.25 animations:^{
                ges.view.transform = CGAffineTransformMakeScale(1.0, 1.0);
            } completion:^(BOOL finished) {
                
            }];
        }];
    }
}

- (void)popViewBgViewTap:(UIButton *)tap {
    
    //    [self.delegateMarr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
    //
    //        if ([obj respondsToSelector:@selector(tfy_PopViewBgClickForPopView:)]) {
    //            [obj tfy_PopViewBgClickForPopView:self];
    //        }
    //
    //    }];
    
    if (self.bgClickBlock) {
        if (self.isShowKeyboard) {
            [self endEditing:YES];
        }
        self.bgClickBlock();
    }
    
    if (_isClickBgDismiss) {
        [self dismiss];
    }
}

- (NSTimeInterval)getPopDuration:(NSTimeInterval)currDuration {
    
    if (_popStyle == PopStyleNO) { return 0.0f; }
    
    if (_popStyle == PopStyleFade) { return 0.2f; }
    
    if (currDuration<=0) { self.popDuration = PopViewDefaultDuration; }
    
    if (self.popDuration == PopViewDefaultDuration) {
        NSTimeInterval defaultDuration = 0.0f;

        if (_popStyle == PopStyleScale) {
            defaultDuration = 0.3f;
        }
        if (_popStyle == PopStyleSmoothFromTop ||
            _popStyle == PopStyleSmoothFromLeft ||
            _popStyle == PopStyleSmoothFromBottom ||
            _popStyle == PopStyleSmoothFromRight ||
            _popStyle == PopStyleSpringFromTop ||
            _popStyle == PopStyleSpringFromLeft ||
            _popStyle == PopStyleSpringFromBottom ||
            _popStyle == PopStyleSpringFromRight ||
            _popStyle == PopStyleCardDropFromLeft ||
            _popStyle == PopStyleCardDropFromRight) {
            defaultDuration = 0.6f;
        }
        return defaultDuration;
    } else {
        return currDuration;
    }
}
- (NSTimeInterval)getDismissDuration:(NSTimeInterval)currDuration {
    
    if (_dismissStyle == DismissStyleNO) { return 0.0f; }
    
    if (_dismissStyle == DismissStyleFade) { return 0.2f; }
    
    if (self.dismissDuration == PopViewDefaultDuration) {
        NSTimeInterval defaultDuration = 0.0f;
        if (_dismissStyle == DismissStyleNO) {
            defaultDuration = 0.0f;
        }
        
        if (_dismissStyle == DismissStyleScale) {
            defaultDuration = 0.3f;
        }
        if (_dismissStyle == DismissStyleSmoothToTop ||
            _dismissStyle == DismissStyleSmoothToBottom ||
            _dismissStyle == DismissStyleSmoothToLeft ||
            _dismissStyle == DismissStyleSmoothToRight ||
            _dismissStyle == DismissStyleCardDropToLeft ||
            _dismissStyle == DismissStyleCardDropToRight ||
            _dismissStyle == DismissStyleCardDropToTop) {
            defaultDuration = 0.5f;
        }
        return defaultDuration;
    } else {
        return currDuration;
    }
}
- (NSTimeInterval)getDragDismissDuration {
    if (self.dragDismissDuration == PopViewDefaultDuration) {
        return [self getDismissDuration:self.dismissDuration];
    } else {
        return self.dragDismissDuration;
    }
}

- (void)animationWithLayer:(CALayer *)layer duration:(CGFloat)duration values:(NSArray *)values {
    CAKeyframeAnimation *KFAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    KFAnimation.duration = duration;
    KFAnimation.removedOnCompletion = NO;
    KFAnimation.fillMode = kCAFillModeForwards;
    //    KFAnimation.delegate = self;//造成强应用 popView释放不了
    NSMutableArray *valueArr = [NSMutableArray arrayWithCapacity:values.count];
    for (NSUInteger i = 0; i<values.count; i++) {
        CGFloat scaleValue = [values[i] floatValue];
        [valueArr addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(scaleValue, scaleValue, scaleValue)]];
    }
    KFAnimation.values = valueArr;
    KFAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    [layer addAnimation:KFAnimation forKey:nil];
}

- (UIColor *)tfy_BlackWithAlpha:(CGFloat)alpha {
    return [UIColor colorWithRed:0 green:0 blue:0 alpha:alpha];
}

// 改变UIColor的Alpha
- (UIColor *)getNewColorWith:(UIColor *)color alpha:(CGFloat)alpha {
    
    if (self.isHideBg) {
        return UIColor.clearColor;
    }
    if (self.bgColor == UIColor.clearColor) {
        return UIColor.clearColor;
    }
    
    CGFloat red = 0.0;
    CGFloat green = 0.0;
    CGFloat blue = 0.0;
    CGFloat resAlpha = 0.0;
    [color getRed:&red green:&green blue:&blue alpha:&resAlpha];
    UIColor *newColor = [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
    return newColor;
}

- (void)startTimer {
    if (self.showTime > 0) {
        TFY_PopViewWK(self);;
        NSString *idStr = [NSString stringWithFormat:@"TFY_PopView_%p",self];
        [TFY_PopTimer addMinuteTimerForTime:self.showTime identifier:idStr handle:^(NSString * day, NSString * hour, NSString * minute, NSString * second, NSString * ms) {
            
            if (wk_self.popViewCountDownBlock) {
                wk_self.popViewCountDownBlock(wk_self, [second doubleValue]);
            }
            [wk_self tfy_PopViewCountDownForPopView:wk_self forCountDown:[second doubleValue]];
        } finish:^(NSString * identifier) {
            [wk_self tfy_PopViewCountDownFinishForPopView:wk_self];
            [self dismiss];
        } pause:^(NSString * identifier) {}];
    }
}

/** 删除指定代理 */
- (void)removeForDelegate:(id<TFY_PopViewProtocol>)delegate {
    if (delegate) {
        if ([self.delegates containsObject:delegate]) {
            [self.delegates removeObject:delegate];
        }
    }
}

/** 删除代理池 删除所有代理 */
- (void)removeAllDelegate {
    if (self.delegates.count > 0) {
        [self.delegates removeAllObjects];
    }
}

- (void)beginImpactFeedback {
    if (self.isImpactFeedback) {
        if (@available(iOS 10.0, *)) {
            UIImpactFeedbackGenerator *feedBackGenertor = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleMedium];
            [feedBackGenertor impactOccurred];
        }
    }
}

#pragma mark - ***** 横竖屏改变 *****

- (void)statusBarOrientationChange:(NSNotification *)notification {
    if (self.isObserverScreenRotation) {
        CGRect originRect = self.customView.frame;
        self.frame = CGRectMake(0, 0, pop_ScreenWidth(), pop_ScreenHeight());
        self.backgroundView.frame = self.bounds;
        self.customView.frame = originRect;
        [self setCustomViewFrameWithHeight:0];
    }
}

#pragma mark - ***** 键盘弹出/收回 *****

- (void)keyboardWillShow:(NSNotification *)notification{
    //    TFYPVLog(@"keyboardWillShow");
    _isShowKeyboard = YES;
  
    self.keyboardWillShowBlock? self.keyboardWillShowBlock():nil;
    
    if (!self.isAvoidKeyboard) { return; }
    CGFloat customViewMaxY = self.customView.pop_Bottom + self.avoidKeyboardSpace;
    CGFloat duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    CGRect keyboardEedFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat keyboardMaxY = keyboardEedFrame.origin.y;
    self.isAvoidKeyboard = YES;
    self.avoidKeyboardOffset = customViewMaxY - keyboardMaxY;
    self.keyboardY = keyboardEedFrame.origin.y;
    //键盘遮挡到弹窗
    if ((keyboardMaxY<customViewMaxY) || ((_originFrame.origin.y + _customView.pop_Height) > keyboardMaxY)) {
        //执行动画
        [UIView animateWithDuration:duration animations:^{
            self.customView.pop_Y = self.customView.pop_Y - self.avoidKeyboardOffset;
        }];
    }
}

- (void)keyboardDidShow:(NSNotification *)notification{
    _isShowKeyboard = YES;
    self.keyboardDidShowBlock? self.keyboardDidShowBlock():nil;
}

- (void)keyboardWillHide:(NSNotification *)notification{
   
    _isShowKeyboard = NO;
    self.keyboardWillHideBlock? self.keyboardWillHideBlock():nil;
    if (!self.isAvoidKeyboard) {
        return;
    }
    CGFloat duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    [UIView animateWithDuration:duration animations:^{
        self.customView.pop_Y = self.originFrame.origin.y;
    }];
}

- (void)keyboardDidHide:(NSNotification *)notification{
    _isShowKeyboard = NO;
    self.keyboardDidHideBlock? self.keyboardDidHideBlock():nil;
}

- (void)keyboardWillChangeFrame:(NSNotification *)notification{
    //    TFYPVLog(@"键盘frame将要改变");
    if (self.keyboardFrameWillChangeBlock) {
        CGRect keyboardBeginFrame = [notification.userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue];
        CGRect keyboardEedFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
        CGFloat duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
        self.keyboardFrameWillChangeBlock(keyboardBeginFrame,keyboardEedFrame,duration);
    }
}

- (void)keyboardDidChangeFrame:(NSNotification *)notification{
    //    TFYPVLog(@"键盘frame已经改变");
    if (self.keyboardFrameDidChangeBlock) {
        CGRect keyboardBeginFrame = [notification.userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue];
        CGRect keyboardEedFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
        CGFloat duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
        self.keyboardFrameDidChangeBlock(keyboardBeginFrame,keyboardEedFrame,duration);
    }
    
}

#pragma mark - ***** UIGestureRecognizerDelegate *****

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    
    if(gestureRecognizer == self.panGesture) {
        UIView *touchView = touch.view;
        while (touchView != nil) {
            if([touchView isKindOfClass:[UIScrollView class]]) {
                self.isDragScrollView = YES;
                self.scrollerView = (UIScrollView *)touchView;
                break;
            } else if(touchView == self.customView) {
                self.isDragScrollView = NO;
                break;
            }
            touchView = (id)[touchView nextResponder];
        }
    }
    return YES;
}


- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if(gestureRecognizer == self.tapGesture) {
        //如果是点击手势
        CGPoint point = [gestureRecognizer locationInView:self.customView];
        BOOL iscontain = [self.customView.layer containsPoint:point];
        if(iscontain) {
            return NO;
        }
    } else if(gestureRecognizer == self.panGesture){
        //如果是自己加的拖拽手势
        //        TFYPVLog(@"gestureRecognizerShouldBegin");
    }
    return YES;
}

//3. 是否与其他手势共存，一般使用默认值(默认返回NO：不与任何手势共存)
- (BOOL)gestureRecognizer:(UIPanGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if(gestureRecognizer == self.panGesture) {
        if ([otherGestureRecognizer isKindOfClass:NSClassFromString(@"UIScrollViewPanGestureRecognizer")] || [otherGestureRecognizer isKindOfClass:NSClassFromString(@"UIPanGestureRecognizer")] ) {
            if([otherGestureRecognizer.view isKindOfClass:[UIScrollView class]] ) {
                return YES;
            }
        }
    }
    return NO;
}

//拖拽手势
- (void)pan:(UIPanGestureRecognizer *)panGestureRecognizer {
    
    self.panOffsetBlock?self.panOffsetBlock(CGPointMake(_customView.pop_X-_originFrame.origin.x, _customView.pop_Y-_originFrame.origin.y)):nil;
    
    if (self.dragStyle == DragStyleNO) {return;}
    // 获取手指的偏移量
    CGPoint transP = [panGestureRecognizer translationInView:self.customView];

    CGPoint velocity = [panGestureRecognizer velocityInView:[UIApplication sharedApplication].keyWindow];
    if(self.isDragScrollView) {//含有tableView,collectionView,scrollView
        //如果当前拖拽的是tableView
        if(self.scrollerView.contentOffset.y <= 0) {
            //如果tableView置于顶端
            if(transP.y > 0) {
                //如果向下拖拽
                self.scrollerView.contentOffset = CGPointMake(0, 0);
                self.scrollerView.panGestureRecognizer.enabled = NO;
                self.isDragScrollView = NO;
                //向下拖
                self.customView.frame = CGRectMake(_customView.pop_X, _customView.pop_Y + transP.y, _customView.pop_Width, _customView.pop_Height);
            } else {
                //如果向上拖拽
            }
        }
    } else {//不含有tableView,collectionView,scrollView
        
        CGFloat customViewX = self.customView.pop_X;
        CGFloat customViewY = self.customView.pop_Y;
        //X正方向移动
        if ((self.dragStyle & DragStyleX_Positive) && (customViewX >= _originFrame.origin.x)) {
            if (transP.x > 0) {
                customViewX = customViewX + transP.x;
            } else if(transP.x < 0 && customViewX > _originFrame.origin.x ){
                customViewX = (customViewX + transP.x) > _originFrame.origin.x? (customViewX + transP.x):(_originFrame.origin.x);
            }
        }
        //X负方向移动
        if ((self.dragStyle & DragStyleX_Negative) && (customViewX <= self.originFrame.origin.x)) {
            if (transP.x < 0) {
                customViewX = customViewX + transP.x;
            } else if(transP.x > 0 && customViewX < _originFrame.origin.x ){
                customViewX = (customViewX + transP.x) < _originFrame.origin.x? (customViewX + transP.x):(_originFrame.origin.x);
            }
        }
        //Y正方向移动
        if (self.dragStyle & DragStyleY_Positive && (customViewY >= _originFrame.origin.y)) {
            if (transP.y > 0) {
                customViewY = customViewY + transP.y;
            } else if(transP.y < 0 && customViewY > _originFrame.origin.y ){
                customViewY = (customViewY + transP.y) > _originFrame.origin.y ?(customViewY + transP.y):(_originFrame.origin.y);
            }
        }
        //Y负方向移动
        if (self.dragStyle & DragStyleY_Negative&&(customViewY <= _originFrame.origin.y)) {
            if (transP.y < 0) {
                customViewY = customViewY + transP.y;
            } else if(transP.y > 0 && customViewY < _originFrame.origin.y){
                customViewY = (customViewY + transP.y) < _originFrame.origin.y?(customViewY + transP.y):(_originFrame.origin.y);
            }
        }
        self.customView.frame = CGRectMake(customViewX, customViewY, _customView.pop_Width, _customView.pop_Height);
    }
    
    [panGestureRecognizer setTranslation:CGPointZero inView:self.customView];

    if(panGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        
        if (self.scrollerView) {
            self.scrollerView.panGestureRecognizer.enabled = YES;
        }

        TFY_PopViewWK(self)
        //拖拽松开回位Block
        void (^dragReboundBlock)(void) = ^ {
            [UIView animateWithDuration:wk_self.dragReboundTime
                                  delay:0.1f
                                options:UIViewAnimationOptionCurveEaseOut
                             animations:^{
                CGRect frame = wk_self.customView.frame;
                frame.origin.y = wk_self.frame.size.height - wk_self.customView.frame.size.height;
                wk_self.customView.frame = wk_self.originFrame;
            } completion:^(BOOL finished) {}];
        };
        //横扫移除Block
        void (^sweepBlock)(BOOL,BOOL,BOOL,BOOL) = ^(BOOL isX_P, BOOL isX_N, BOOL isY_P, BOOL isY_N) {
            
            if (isX_P==NO && isX_N==NO && isY_P==NO && isY_N==NO) {
                dragReboundBlock();
                return;
            }
            
            if (isY_P==NO && isY_N==NO && self.sweepDismissStyle == SweepDismissStyleSmooth) {//X轴可轻扫
                if (velocity.x>0) {//正向
                    [self dismissWithStyle:DismissStyleSmoothToRight duration:self.dismissDuration];
                } else {//负向
                    [self dismissWithStyle:DismissStyleSmoothToLeft duration:self.dismissDuration];
                }
                return;
            }
            
            if (isX_P==NO && isX_N==NO && self.sweepDismissStyle == SweepDismissStyleSmooth) {//Y轴可轻扫
                if (velocity.y>0) {//正向
                    [self dismissWithStyle:DismissStyleSmoothToBottom duration:self.dismissDuration];
                } else {//负向
                    [self dismissWithStyle:DismissStyleSmoothToTop duration:self.dismissDuration];
                }
                return;
            }
            // 移除，以手势速度飞出
            [UIView animateWithDuration:0.5 animations:^{
                wk_self.backgroundView.backgroundColor = [self getNewColorWith:self.bgColor alpha:0.0];
                self.customView.center = CGPointMake(isX_P || isX_N?velocity.x:self.customView.pop_CenterX, isY_P||isY_N?velocity.y:self.customView.pop_CenterY);
            } completion:^(BOOL finished) {
                [wk_self dismissWithStyle:DismissStyleFade duration:0.1];
            }];
        };
        
        double velocityX =  sqrt(pow(velocity.x, 2));
        double velocityY =  sqrt(pow(velocity.y, 2));
        if((velocityX >= self.swipeVelocity)||(velocityY >= self.swipeVelocity)) {//轻扫
            
            if (self.scrollerView.contentOffset.y>0) {
                return;
            }
            
            //可轻扫移除的方向
            BOOL isX_P = NO;
            BOOL isX_N = NO;
            BOOL isY_P = NO;
            BOOL isY_N = NO;
            
            if ((self.dragStyle & DragStyleX_Positive) && velocity.x>0 && velocityX >= self.swipeVelocity) {
                isX_P = self.sweepStyle & SweepStyleX_Positive? YES:NO;
            }
            if ((self.dragStyle & DragStyleX_Negative) && velocity.x<0 && velocityX >= self.swipeVelocity) {
                isX_N = self.sweepStyle & SweepStyleX_Negative? YES:NO;
            }
            
            if ((self.dragStyle & DragStyleY_Positive) && velocity.y>0 && velocityY >= self.swipeVelocity) {
                isY_P = self.sweepStyle & SweepStyleY_Positive? YES:NO;
            }
            if ((self.dragStyle & DragStyleY_Negative) && velocity.y <0 && velocityY >= self.swipeVelocity) {
                isY_N = self.sweepStyle & SweepStyleY_Negative? YES:NO;
            }
            sweepBlock(isX_P,isX_N,isY_P,isY_N);
//            TFYPVLog(@"isX=%@,isY=%@,velocityX=%lf,velocityY=%lf",isX?@"YES":@"NO",isY?@"YES":@"NO",velocityX,velocityY);
        }else {//普通拖拽
            BOOL isCanDismiss = NO;
            if (self.dragStyle & DragStyleAll) {
                
                if (fabs(self.customView.frame.origin.x - self.originFrame.origin.x)>=self.dragDistance && self.dragDistance!=0) {
                    isCanDismiss = YES;
                }
                if (fabs(self.customView.frame.origin.y - self.originFrame.origin.y)>=self.dragDistance && self.dragDistance!=0) {
                    isCanDismiss = YES;
                }
                
                if (isCanDismiss) {
                    [self dismissWithStyle:_isDragDismissStyle? self.dragDismissStyle:self.dismissStyle
                                  duration:self.getDragDismissDuration];
                }else {
                    dragReboundBlock();
                }
            } else {
                dragReboundBlock();
            }
        }
    }
}

#pragma mark - ***** 懒加载 *****

- (NSHashTable<id<TFY_PopViewProtocol>> *)delegates {
    if (_delegates) return _delegates;
    _delegates = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
    return _delegates;
}

- (UIView *)parentView {
    return self.container;
}

- (UIView *)currCustomView {
    return self.customView;
}

- (NSHashTable *)popViewDidDismissBlocks
{
    if (_popViewDidDismissBlocks) return _popViewDidDismissBlocks;
    
    _popViewDidDismissBlocks = [NSHashTable hashTableWithOptions:(NSPointerFunctionsWeakMemory)];
    
    return _popViewDidDismissBlocks;
}

#pragma mark - ***** 以下是 窗口管理api *****

/** 保存popView */
+ (void)savePopView:(TFY_PopView *)popView {
    [TFY_PopViewManager savePopView:popView];
}

/** 获取全局(整个app内)所有popView */
+ (NSArray *)getAllPopView {
    return [TFY_PopViewManager getAllPopView];
}

/** 获取当前页面所有popView */
+ (NSArray *)getAllPopViewForParentView:(UIView *)parentView {
    return [TFY_PopViewManager getAllPopViewForParentView:parentView];
}

/** 获取当前页面指定编队的所有popView */
+ (NSArray *)getAllPopViewForPopView:(TFY_PopView *)popView {
    return [TFY_PopViewManager getAllPopViewForPopView:popView];
}

/**
 读取popView (有可能会跨编队读取弹窗)
 建议使用getPopViewForGroupId:forkey: 方法进行精确读取
 */
+ (TFY_PopView *)getPopViewForKey:(NSString *)key {
    return [TFY_PopViewManager getPopViewForKey:key];
}

/** 移除popView */
+ (void)removePopView:(TFY_PopView *)popView {
    [TFY_PopViewManager removePopView:popView];
}

+ (void)removePopView:(TFY_PopView *)popView complete:(Block_Void)complete
{
    if (popView == nil) {
        complete ? complete() : nil;
    }
    popView.popViewDidDismissBlock = complete;
    [TFY_PopViewManager removePopView:popView];
}

/**
 移除popView 通过唯一key (有可能会跨编队误删弹窗)
 建议使用removePopViewForGroupId:forkey: 方法进行精确删除
 */
+ (void)removePopViewForKey:(NSString *)key {
    [TFY_PopViewManager removePopViewForKey:key complete:nil];
}

+ (void)removePopViewForKey:(NSString *)key complete:(Block_Void)complete
{
    [TFY_PopViewManager removePopViewForKey:key complete:complete];
}

/** 移除所有popView */
+ (void)removeAllPopView {
    [TFY_PopViewManager removeAllPopViewComplete:nil];
}

+ (void)removeAllPopViewComplete:(Block_Void)complete
{
    [TFY_PopViewManager removeAllPopViewComplete:complete];
}

/** 移除 最后一个弹出的 popView */
+ (void)removeLastPopView {
    [TFY_PopViewManager removeLastPopViewComplete:nil];
}

+ (void)removeLastPopViewComplete:(Block_Void)complete
{
    [TFY_PopViewManager removeLastPopViewComplete:complete];
}

/** 开启调试view  建议设置成 线上隐藏 测试打开 */
+ (void)setLogStyle:(PopViewLogStyle)logStyle {
    _logStyle = logStyle;
    
    if (logStyle == PopViewLogStyleNO) {
        [PopViewM().infoView removeFromSuperview];
        PopViewM().infoView = nil;
    }
}


@end
