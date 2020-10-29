//
//  AppDelegate.m
//  TFY_POPControllerKit
//
//  Created by 田风有 on 2020/10/28.
//

#import "AppDelegate.h"
#import "POP_OneController.h"
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    if (!TFY_ScenePackage.isSceneApp) {
            self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
            self.window.backgroundColor = [UIColor whiteColor];
            [self.window makeKeyAndVisible];
    }
    [TFY_ScenePackage addBeforeWindowEvent:^(TFY_Scene * _Nonnull application) {
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:POP_OneController.new];
        [UIApplication tfy_window].rootViewController = nav;
    }];
    return YES;
}



@end
