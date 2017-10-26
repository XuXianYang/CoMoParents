#import "XXYmYChildCell.h"
#import "XXYMyChildModel.h"
#import <UIImageView+WebCache.h>
@interface XXYmYChildCell()
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *schoolLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIView *lineView;

@end
@implementation XXYmYChildCell
-(void)setDataModel:(XXYMyChildModel *)dataModel
{
    _dataModel=dataModel;
    [_iconImageView sd_setImageWithURL:[NSURL URLWithString:dataModel.avatarUrl] placeholderImage:[UIImage imageNamed:@"nohead"]];
    _nameLabel.text=dataModel.realName;
   
    if(dataModel.schoolName&&dataModel.className)
    {
        _schoolLabel.text=[NSString stringWithFormat:@"%@ %@",dataModel.schoolName,dataModel.className];
    }
    else
    {
        _schoolLabel.text=@"";
    }
    if(dataModel.isDefaultChild)
    {
        _titleLabel.text=@"默认";
    }
    else
    {
        _titleLabel.text=@"";
    }
}
-(void)layoutSubviews
{
    _nameLabel.font=[UIFont fontWithName:@"Helvetica-Bold" size:17];
    _titleLabel.font=[UIFont systemFontOfSize:15];
    _schoolLabel.font=[UIFont systemFontOfSize:15];
    _schoolLabel.textColor=[UIColor colorWithRed:153.0/255 green:153.0/255 blue:153.0/255 alpha:1.0];
    _titleLabel.textColor=[UIColor colorWithRed:0.0/255 green:152.0/255 blue:37.0/255 alpha:1.0];
    _lineView.backgroundColor=[UIColor colorWithRed:231.0/255 green:231.0/255 blue:231.0/255 alpha:1.0];
    
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
