//
//  AppDelegate.h
//  CoMoClassParents
//
//  Created by 徐显洋 on 17/3/24.
//  Copyright © 2017年 徐显洋. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
static NSString *appKey = @"5fe9c4c70550a33eb37d93cc";
static NSString *channel = @"App Store";
static BOOL isProduction = FALSE;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;
-(void)showWindowHome:(NSString *)windowType;
-(void)setUpLogOutAppAlert;
@end

