#import "XXYTabBarController.h"
#import "XXYMyInfoController.h"
#import "XXYChatGroupController.h"
#import "XXYHomeController.h"
#import <RongIMKit/RongIMKit.h>
#import"UITabBar+XXYBageValue.h"

@interface XXYTabBarController ()

@end

@implementation XXYTabBarController

#pragma mark 本类或子类初始化时调用且只调用一次
+ (void)initialize {
    
    [[UITabBarItem appearance] setTitleTextAttributes:
     @{NSForegroundColorAttributeName : XXYMainColor}
                                             forState:UIControlStateSelected];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // 添加子控制器
    [self setupChildController];
    // 设置tabbarItem
    [self setupTabbarItem];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(didReceiveMessageNotification:)
     name:RCKitDispatchMessageNotification
     object:nil];

}
- (void)didReceiveMessageNotification:(NSNotification *)notification
{
    // NSLog(@"1234567890");
    [self.tabBar showTabBarBadgeOnItemIndex:1];
    
}

- (void)setupChildController {
    NSArray *classNameArr = @[@"XXYHomeController", @"XXYChatGroupController",@"XXYMyInfoController"];
    for (int i = 0; i < 3; i ++)
    {
        UIViewController *vc= [[NSClassFromString(classNameArr[i]) alloc] init];
        XXYNavigationController *nav = [[XXYNavigationController alloc] initWithRootViewController:vc];
        [self addChildViewController:nav];
    }
}
- (void)setupTabbarItem {
    NSArray *titleArr = @[@"首页", @"班群",@"我"];
    NSArray *imageArr = @[[UIImage imageWithOriginalNamed:@"tabbar_home"], [UIImage imageWithOriginalNamed:@"tabbar_chatGroup"],[UIImage imageWithOriginalNamed:@"tabbar_profile"]];
    NSArray *selImageArr = @[[UIImage imageWithOriginalNamed:@"tabbar_home_selected"], [UIImage imageWithOriginalNamed:@"tabbar_chatGroup_selected"],[UIImage imageWithOriginalNamed:@"tabbar_profile_selected"]];
    for (int i = 0; i < 3; i ++) {
        UIViewController *vc = self.viewControllers[i];
        vc.tabBarItem = [[UITabBarItem alloc] initWithTitle:titleArr[i] image:imageArr[i] selectedImage:selImageArr[i]];
    }
}
@end
