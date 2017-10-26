//
//  XXYMyChildController.h
//  CoMoClassParents
//
//  Created by 徐显洋 on 17/3/28.
//  Copyright © 2017年 徐显洋. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol XXYReloadDataDelegate <NSObject>

-(void)reloadTableView;

@end

@interface XXYMyChildController : UIViewController
@property(nonatomic,weak)id<XXYReloadDataDelegate>reloadDelegate;

@end
