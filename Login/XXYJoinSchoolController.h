//
//  XXYJoinSchoolController.h
//  CoMoClassTeachers
//
//  Created by 徐显洋 on 16/11/29.
//  Copyright © 2016年 徐显洋. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol XXYReloadDataDelegate <NSObject>

-(void)reloadTableView;

@end

@interface XXYJoinSchoolController : UIViewController
@property(nonatomic,assign)NSInteger index;

@property(nonatomic,weak)id<XXYReloadDataDelegate>reloadDelegate;


@end
