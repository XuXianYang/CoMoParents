#import "XXYSafetyToolsCell.h"
#import "XXYSafetyToolsModel.h"
@interface XXYSafetyToolsCell()

@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UIView *lineView;

@end
@implementation XXYSafetyToolsCell
-(void)setDataModel:(XXYSafetyToolsModel *)dataModel
{
    _dataModel=dataModel;
    if(dataModel.messageType.integerValue==1)
    {
       _iconImageView.image=[UIImage imageNamed:@"help_error"];
        _titleLabel.text=@"有危险!";
        _titleLabel.textColor=[UIColor colorWithRed:255.0/255 green:3.0/255 blue:18.0/255 alpha:1.0];
    }
    else
    {
        _iconImageView.image=[UIImage imageNamed:@"help_qiandao"];
        _titleLabel.text=@"到家签到!";
        _titleLabel.textColor=XXYCharactersColor;
    }
    if(dataModel.content.length<1)
    {
        _contentLabel.text=@"";
    }
    else
    {
        _contentLabel.text=dataModel.content;
    }
    _timeLabel.text=[self turnDateStringToMyString:dataModel.createdAt];
    
}
-(void)layoutSubviews
{
    _timeLabel.font= [UIFont fontWithName:@"Helvetica-Bold" size:14];
    _titleLabel.font=[UIFont systemFontOfSize:15];
    _contentLabel.font=[UIFont systemFontOfSize:12];
    _contentLabel.textColor=[UIColor lightGrayColor];
    _lineView.backgroundColor=[UIColor lightGrayColor];
}
-(NSString*)turnDateStringToMyString:(NSString*)dateString
{
    //Mar 28, 2017 10:13:09 AM
    NSArray*array=[dateString componentsSeparatedByString:@" "];
    
    NSString*dayString=[array[3] substringWithRange:NSMakeRange(0,((NSString*)array[3]).length-3)];
    
    //10:13 2:23
    NSString*hourStr=[dayString substringWithRange:NSMakeRange(0,dayString.length-3)];
    NSString*minStr=[dayString substringWithRange:NSMakeRange(dayString.length-2,2)];
    
    NSString* morStr=array[array.count-1];
    if([morStr isEqualToString:@"AM"])
    {
        hourStr=[NSString stringWithFormat:@"%@",hourStr];
        
    }
    else
    {
        hourStr=[NSString stringWithFormat:@"%i",hourStr.integerValue+12];
    }
    
    if(hourStr.integerValue==24)
    {
       hourStr=[NSString stringWithFormat:@"%i",hourStr.integerValue-12];
    }
    dayString=[NSString stringWithFormat:@"%@:%@",hourStr,minStr];
    return dayString;
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
