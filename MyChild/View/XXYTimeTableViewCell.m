//
//  XXYTimeTableViewCell.m
//  CoMoClassTeachers
//
//  Created by 徐显洋 on 16/10/11.
//  Copyright © 2016年 徐显洋. All rights reserved.
//

#import "XXYTimeTableViewCell.h"
#import "XXYTimeTableModel.h"
@interface XXYTimeTableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *weekDayName;
@property (weak, nonatomic) IBOutlet UIImageView *courseImage;

@property (weak, nonatomic) IBOutlet UILabel *courseName;
@property (weak, nonatomic) IBOutlet UIImageView *teacherImage;
@property (weak, nonatomic) IBOutlet UILabel *teacherName;
@property (weak, nonatomic) IBOutlet UIView *courseContent;

@end

@implementation XXYTimeTableViewCell


-(void)setDataModel:(XXYTimeTableModel *)dataModel
{
    _dataModel=dataModel;
    _weekDayName.text=dataModel.courseNum;
    _courseName.text=dataModel.courseName;
    _teacherName.text=dataModel.teacherName;
}
-(void)layoutSubviews
{
    _weekDayName.textColor=[UIColor whiteColor];
    _weekDayName.textAlignment=NSTextAlignmentCenter;
    _courseName.font=[UIFont systemFontOfSize:14];
    _teacherName.font=[UIFont systemFontOfSize:14];
    _weekDayName.font=[UIFont systemFontOfSize:15];
    
    if(self.index<4)
    {
        _courseImage.image=[UIImage imageNamed:@"timeTable_3"];
        _teacherImage.image=[UIImage imageNamed:@"timeTable_1"];
        _weekDayName.backgroundColor=[UIColor colorWithRed:0.0/255 green:148.0/255 blue:250.0/255 alpha:1.0];
        _courseContent.backgroundColor=[UIColor colorWithRed:229.0/255 green:242.0/255 blue:252.0/255 alpha:1.0];
    }
    else
    {
        _teacherImage.image=[UIImage imageNamed:@"timeTable_2"];
        _courseImage.image=[UIImage imageNamed:@"timeTable_4"];
        _weekDayName.backgroundColor=[UIColor colorWithRed:255.0/255 green:166.0/255 blue:25.0/255 alpha:1.0];
        _courseContent.backgroundColor=[UIColor colorWithRed:255.0/255 green:242.0/255 blue:232.0/255 alpha:1.0];
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
