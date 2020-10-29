//
//  TFY_PopControllerKit.h
//  TFY_POPControllerKit
//
//  Created by 田风有 on 2020/10/29.
//  最新版本:1.0.0


#import <Foundation/Foundation.h>

FOUNDATION_EXPORT double TFY_PopControllerKitVersionNumber;

FOUNDATION_EXPORT const unsigned char TFY_PopControllerKitVersionString[];

#define TFY_PopControllerKitRelease 0

#if TFY_PopControllerKitRelease

#import <TFY_PopController/TFY_PopController.h>
#import <TFY_PopController/TFY_NavAnimatedController.h>

#import <TFY_PopController/UIViewController+TFY_PopController.h>
#import <TFY_PopController/TFY_PopControllerAnimationProtocol.h>
#import <TFY_PopController/TFY_PopControllerAnimatedTransitioning.h>


#else

//弹出框容器头文件
#import "TFY_PopController.h"
#import "TFY_NavAnimatedController.h"

#import "UIViewController+TFY_PopController.h"
#import "TFY_PopControllerAnimationProtocol.h"
#import "TFY_PopControllerAnimatedTransitioning.h"

#endif
