#import "XXYHomeController.h"
#import "BSHttpRequest.h"
#import <UIImageView+WebCache.h>
#import "SXMarquee.h"
#import "UIColor+Wonderful.h"

#import "XXYTimeTableView.h"
#import "XXYClassAnnouncementsController.h"
#import "XXYTimeTableController.h"
#import "XXYHomeworkController.h"
#import "XXYTestFluidController.h"
#import "XXYChileScoreController.h"
#import "XXYSafetyToolController.h"

#import "XXYMyChildController.h"

#define imageBtnWidth (MainScreenW-30-20*5)/4
#define imageBgViewH (MainScreenW-30-20*5)/4+20+35

@interface XXYHomeController ()<UIScrollViewDelegate,XXYReloadDataDelegate>
@property(nonatomic,strong)UIScrollView*scrollView;
@property(nonatomic,strong)UIPageControl*pageControl;
@property(nonatomic,strong)UIScrollView*adScrollView;
@property(nonatomic,strong)UIView*childInfoBgView;
@property(nonatomic,strong)UIView*btnBgView;

@property(nonatomic,strong)UIImageView*iconImageView;
@property(nonatomic,strong)UILabel*nameLabel;
@property(nonatomic,strong)UILabel*schoolLabel;

@property(nonatomic,strong)UIView*announcementView;
@property(nonatomic,strong)SXMarquee*sxMarquee;

@property(nonatomic,assign)CGFloat adHeight;

@end

@implementation XXYHomeController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor=XXYBgColor;
    
    if([[UIDevice currentDevice].model isEqualToString:@"iPad"])
    {
        _adHeight=300;
        
        
    }
    else
    {
        _adHeight=150;
    }
    [self setUpAds];
    [self addButtons];
    [self setUpChileInfoViews];
    [self getChildInfo];
    [self setUpAnnourcrmentView];
    [self setUpTableView];
    [self setUpHomeWorkView];
}
//广告滚动和背景视图
-(void)setUpAds
{
    _scrollView=[[UIScrollView alloc]initWithFrame:CGRectMake(0,20-64, MainScreenW, MainScreenH)];
    _scrollView.backgroundColor=XXYBgColor;
    _scrollView.bounces=YES;
    _scrollView.showsVerticalScrollIndicator=NO;
    if([[UIDevice currentDevice].model isEqualToString:@"iPad"])
    {
        _scrollView.contentSize=CGSizeMake(0, _adHeight+imageBgViewH+(MainScreenW-100)/3*1.28+85+40+45*8+60+200);
    }
    else
    {
        _scrollView.contentSize=CGSizeMake(0, _adHeight+imageBgViewH+(MainScreenW-100)/3*1.28+85+40+45*8+60+80+64);
    }
    [self.view addSubview:_scrollView];
    
    //广告
    NSArray*imageNameArray=@[@"homeslide2",@"homeslide1"];
    _adScrollView=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, MainScreenW, _adHeight)];
    _adScrollView.backgroundColor=[UIColor clearColor];
    _adScrollView.pagingEnabled=YES;
    _adScrollView.showsHorizontalScrollIndicator=NO;
    _adScrollView.bounces=NO;
    _adScrollView.scrollEnabled=YES;
    _adScrollView.contentSize=CGSizeMake(MainScreenW*imageNameArray.count, 0);
    _adScrollView.delegate=self;
    _adScrollView.tag=100;
    [_scrollView addSubview:_adScrollView];
    
    for(int i=0;i<imageNameArray.count;i++)
    {
        UIImageView*imageView=[[UIImageView alloc]initWithFrame:CGRectMake(i*MainScreenW, 0, MainScreenW, _adHeight)];
        imageView.image=[UIImage imageNamed:imageNameArray[i]];
        imageView.contentMode=UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        imageView.userInteractionEnabled = YES;
        [_adScrollView addSubview:imageView];
    }
    _pageControl=[[UIPageControl alloc]initWithFrame:CGRectMake(100,_adHeight-35, MainScreenW-200, 20)];
    _pageControl.numberOfPages=imageNameArray.count;
    _pageControl.currentPage=0;
    _pageControl.currentPageIndicatorTintColor=[UIColor whiteColor];
    _pageControl.pageIndicatorTintColor=[UIColor lightGrayColor];
    [_scrollView addSubview:_pageControl];
    
    for(NSInteger i=0;i<2;i++)
    {
        UIView*bgView=[[UIView alloc]init];
        bgView.backgroundColor=[UIColor whiteColor];
        [_scrollView addSubview:bgView];
        if(i==0)
        {
            bgView.frame=CGRectMake(15, _adHeight-15, MainScreenW-30, imageBgViewH-20);
            _childInfoBgView=bgView;
        }
        else
        {
            _btnBgView=bgView;
            bgView.frame=CGRectMake(15, _adHeight+imageBgViewH-25, MainScreenW-30, imageBgViewH);
        }
    }
    
    UITapGestureRecognizer * pictureTap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAvatarView:)];
    [_childInfoBgView addGestureRecognizer:pictureTap];

}
-(void)reloadTableView
{
    [self getChildInfo];
    XXYTimeTableView*timeTableView=[self.view viewWithTag:600];
    [timeTableView loadNewData];
}
-(void)tapAvatarView:(UITapGestureRecognizer*)tap
{
    XXYMyChildController*childCon=[[XXYMyChildController alloc]init];
    childCon.hidesBottomBarWhenPushed=YES;
    childCon.reloadDelegate=self;
    [self.navigationController pushViewControllerWithAnimation:childCon];
}
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if(scrollView.tag==100)
    {
        NSInteger index=scrollView.contentOffset.x/scrollView.frame.size.width;
        self.pageControl.currentPage=index;
    }
}
//四个自定义点击按钮
-(void)addButtons
{
    NSArray*imageNameArray=@[@"home_timetable_btn",@"home_score_btn",@"home_test_btn",@"home_safe_btn"];
    NSArray*labelName=@[@"课 程 表",@"成绩查询",@"考 试 铃",@"安全助手"];
    for(int i=0;i<4;i++)
    {
        UIButton*btn=[UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame=CGRectMake(20+i*(imageBtnWidth+20), 20, imageBtnWidth, imageBtnWidth);
        [btn setImage:[UIImage imageNamed:imageNameArray[i]] forState:UIControlStateNormal];
        btn.tag=200+i;
        [btn addTarget:self action:@selector(publishBtnCilked:) forControlEvents:UIControlEventTouchUpInside];
        [_btnBgView addSubview:btn];
        
        UILabel*label=[[UILabel alloc]initWithFrame:CGRectMake(15+i*(imageBtnWidth+20), 20+imageBtnWidth, imageBtnWidth+10, 30)];
        label.text=labelName[i];
        label.textColor=XXYCharactersColor;
        label.textAlignment=NSTextAlignmentCenter;
        label.font=[UIFont systemFontOfSize:13];
        //根据字体宽度让字体自适应大小
        //label.adjustsFontSizeToFitWidth = YES;
        [_btnBgView addSubview:label];
    }
}
//孩子信息子视图
-(void)setUpChileInfoViews
{
    _iconImageView=[[UIImageView alloc]initWithFrame:CGRectMake(15, 15, imageBgViewH-50, imageBgViewH-50)];
    [_childInfoBgView addSubview:_iconImageView];
    
    for(NSInteger i=0;i<2;i++)
    {
        UILabel*infoLabel=[[UILabel alloc]initWithFrame:CGRectMake(imageBgViewH-25, 15+i*(imageBgViewH-50)/2, _childInfoBgView.frame.size.width-imageBgViewH-100, (imageBgViewH-50)/2)];
        infoLabel.textColor=XXYCharactersColor;
        [_childInfoBgView addSubview:infoLabel];
        if(i==0)
        {
            _nameLabel=infoLabel;
            infoLabel.font=[UIFont fontWithName:@"Helvetica-Bold" size:16];
        }
        else
        {
            _schoolLabel=infoLabel;
            infoLabel.font=[UIFont systemFontOfSize:15];
        }
        [_childInfoBgView addSubview:infoLabel];
    }
    //获取缓存的孩子信息
    NSDictionary*infoDict =[BSHttpRequest unarchiverObjectByKey:@"defaultChildInfo" WithPath:@"defaultChildInfo.plist"];
    if(infoDict)
    {
        [_iconImageView sd_setImageWithURL:[NSURL URLWithString:infoDict[@"avatarUrl"]] placeholderImage:[UIImage imageNamed:@"head_bj"]];
        _nameLabel.text=infoDict[@"realName"];
        _schoolLabel.text=[NSString stringWithFormat:@"%@ %@",infoDict[@"studentInfo"][@"schoolName"],infoDict[@"studentInfo"][@"className"]];
    }
}
//获取孩子信息
-(void)getChildInfo
{
    NSString*requestUrl=[NSString stringWithFormat:@"%@%@",BaseUrl,@"/parent/child/list"];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString*userSidString=[defaults objectForKey:@"userSid"];
    [BSHttpRequest GET:requestUrl parameters:@{@"sid":userSidString} success:^(id responseObject){
        //NSLog(@"Success: %@",[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        id objString = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSArray*chidArr=objString[@"data"];
        
        for (NSDictionary*dict in chidArr)
        {
            if(dict[@"isDefaultChild"])
            {
                [BSHttpRequest archiverObject:dict ByKey:@"defaultChildInfo" WithPath:@"defaultChildInfo.plist"];
                [_iconImageView sd_setImageWithURL:[NSURL URLWithString:dict[@"avatarUrl"]] placeholderImage:[UIImage imageNamed:@"head_bj"]];
                _nameLabel.text=dict[@"realName"];
                if(dict[@"studentInfo"][@"schoolName"]&&dict[@"studentInfo"][@"className"])
                {
                    _schoolLabel.text=[NSString stringWithFormat:@"%@ %@",dict[@"studentInfo"][@"schoolName"],dict[@"studentInfo"][@"className"]];
                }
                else
                {
                    _schoolLabel.text=@"";
                }
            }
        }
    } failure:^(NSError *error) {}];

}
//班级公告子视图
-(void)setUpAnnourcrmentView
{
    //MainScreenW*2/5+imageBgViewH*2+55
    _announcementView=[[UIView alloc]initWithFrame:CGRectMake(15, _btnBgView.frame.size.height+_adHeight+imageBgViewH-25+10, MainScreenW-30, 40)];//MainScreenW*2/5+imageBgViewH-25+10
    _announcementView.backgroundColor=[UIColor whiteColor];
    [_scrollView addSubview:_announcementView];
    
    UILabel*maskLabel=[[UILabel alloc]initWithFrame:CGRectMake(5, 10, 80, 20)];
    maskLabel.text=@" 班级公告";
    maskLabel.font=[UIFont systemFontOfSize:15];
    maskLabel.textColor=[UIColor blueColor];
    maskLabel.layer.borderColor=[UIColor blueColor].CGColor;
    maskLabel.layer.borderWidth=1.0;
    maskLabel.textAlignment=NSTextAlignmentCenter;
    [_announcementView addSubview:maskLabel];

    NSString*annStr =[BSHttpRequest unarchiverObjectByKey:@"newClassAnnourcement" WithPath:@"newClassAnnourcement.plist"];
    [self setUpSXMarquee:annStr];
    [self getNewAnnouncementData];
}

-(void)setUpSXMarquee:(NSString*)title
{
    [_sxMarquee removeFromSuperview];
    _sxMarquee = [[SXMarquee alloc]initWithFrame:CGRectMake(90, 10, MainScreenW-125, 20) speed:4 Msg:title bgColor:[UIColor lightBLue] txtColor:[UIColor whiteColor]];
    [_sxMarquee changeMarqueeLabelFont:[UIFont systemFontOfSize:15]];
    [_sxMarquee changeTapMarqueeAction:^{
        
        XXYClassAnnouncementsController*annoCon=[[XXYClassAnnouncementsController alloc]init];
        annoCon.hidesBottomBarWhenPushed=YES;
        [self.navigationController pushViewControllerWithAnimation:annoCon];
    }];
    [_sxMarquee start];
    [_announcementView addSubview:_sxMarquee];
}
//获取最新一条公告
-(void)getNewAnnouncementData
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString*userSidString=[defaults objectForKey:@"userSid"];
    NSString*requestUrl=[NSString stringWithFormat:@"%@%@",BaseUrl,@"/student/announcement/latest"];
    [BSHttpRequest GET:requestUrl parameters:@{@"sid":userSidString} success:^(id responseObject){
        // NSLog(@"Success: %@",[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        id objString = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSArray*dataArray=objString[@"data"];
        if(dataArray.count>0)
        {
            NSDictionary*dict=dataArray[0];
            
            NSString*string=[NSString stringWithFormat:@"%@:%@",dict[@"title"],dict[@"content"]];
            [BSHttpRequest archiverObject:string ByKey:@"newClassAnnourcement" WithPath:@"newClassAnnourcement.plist"];
            [self setUpSXMarquee:string];
        }
        else
            
        {
            [self setUpSXMarquee:@"班级公告:点击查看班级公告!"];
        }
    } failure:^(NSError *error) {
        [self setUpSXMarquee:@"班级公告:点击查看班级公告!"];
    }];
}
-(void)setUpTableView
{
    UIView*timeTableBgView=[[UIView alloc]initWithFrame:CGRectMake(15, _btnBgView.frame.size.height+_adHeight+imageBgViewH-25+10+50, MainScreenW-30, 45*8+60)];
    timeTableBgView.backgroundColor=[UIColor whiteColor];
    [_scrollView addSubview:timeTableBgView];
    
    
    //实例化一个NSDateFormatter对象
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //设定时间格式,这里可以设置成自己需要的格式
    [dateFormatter setDateFormat:@"MM-dd"];
    //用[NSDate date]可以获取系统当前时间
    NSString *currentDateStr = [dateFormatter stringFromDate:[NSDate date]];
    //输出格式为：2010-10-27 10:22:13
    NSDictionary*todayInfo= [self weekdayStringFromDate:[NSDate date]];
    NSNumber*weekId=todayInfo[@"id"];
    NSInteger tableViewIndex;
    switch (weekId.integerValue) {
        case 1:
            tableViewIndex=5;
            break;
        case 2:
            tableViewIndex=1;
            break;
        case 3:
            tableViewIndex=2;
            break;
        case 4:
            tableViewIndex=3;
            break;
        case 5:
            tableViewIndex=4;
            break;
        case 6:
            tableViewIndex=5;
            break;
        case 7:
            tableViewIndex=5;
            break;
        default:
            break;
    }
    
    UILabel*todayLabel=[[UILabel alloc]initWithFrame:CGRectMake(10, 0,timeTableBgView.frame.size.width-110 , 45)];
    [timeTableBgView addSubview:todayLabel];
    todayLabel.font=[UIFont systemFontOfSize:14];
    NSString*dataStr=[NSString stringWithFormat:@"今日课程 %@ %@",currentDateStr,todayInfo[@"week"]];
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:dataStr];
    [string addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0,4)];
    [string addAttribute:NSForegroundColorAttributeName value:XXYCharactersColor range:NSMakeRange(4,dataStr.length-4)];
    todayLabel.attributedText=string;
    
    UIView*lineView=[[UIView alloc]initWithFrame:CGRectMake(10, 40, timeTableBgView.frame.size.width-20, 1)];
    lineView.backgroundColor=XXYBgColor;
    [timeTableBgView addSubview:lineView];
    
    UIButton*moreTimeTableBtn=[UIButton buttonWithType:UIButtonTypeSystem];
    moreTimeTableBtn.frame=CGRectMake(timeTableBgView.frame.size.width-100, 0, 90, 45);
    [moreTimeTableBtn setTitle:@"一周课表 >" forState:UIControlStateNormal];
    [moreTimeTableBtn addTarget:self action:@selector(timeTableBtnCliked:) forControlEvents:UIControlEventTouchUpInside];
    moreTimeTableBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    moreTimeTableBtn.titleLabel.textAlignment=NSTextAlignmentRight;
    [moreTimeTableBtn setTitleColor:XXYCharactersColor forState:UIControlStateNormal];
    [timeTableBgView addSubview:moreTimeTableBtn];
    
    XXYTimeTableView*timeTableView= [XXYTimeTableView contentTableView];
    timeTableView.frame=CGRectMake(10, 50, timeTableBgView.frame.size.width-20, timeTableBgView.frame.size.height-60);
    timeTableView.tag=600;
    timeTableView.bounces=NO;
    timeTableView.scrollEnabled=NO;
    timeTableView.index=tableViewIndex;
    timeTableView.sectionHeaderHight=5;
    timeTableView.showsVerticalScrollIndicator=NO;
    [timeTableView loadNewData];
    [timeTableBgView addSubview:timeTableView];
}
-(void)setUpHomeWorkView
{
    
    CGFloat bookWidth=(MainScreenW-100)/3;
    CGFloat bookHeight=(MainScreenW-100)/3*1.28;
    
    UIView*homeworkBgView=[[UIView alloc]initWithFrame:CGRectMake(15, _btnBgView.frame.size.height+_adHeight+imageBgViewH-25+10+50+45*8+60+10, MainScreenW-30, bookHeight+85)];
    UITapGestureRecognizer*tap=[[UITapGestureRecognizer alloc]init];
    [tap addTarget:self action:@selector(homeWorkCileked:)];
    [homeworkBgView addGestureRecognizer:tap];
    homeworkBgView.backgroundColor=[UIColor whiteColor];
    [_scrollView addSubview:homeworkBgView];
    
    NSArray*bookNameArr=@[@"语文",@"数学",@"英语"];
    for(NSInteger i=0;i<3;i++)
    {
        UIImageView*bookImg=[[UIImageView alloc]initWithFrame:CGRectMake(20+(bookWidth+15)*i, 65, bookWidth, bookHeight)];
        bookImg.userInteractionEnabled=YES;
        bookImg.image=[UIImage imageNamed:[NSString stringWithFormat:@"book%i",i+1]];
        [homeworkBgView addSubview:bookImg];
        
        UILabel*nameLabel=[[UILabel alloc]initWithFrame:CGRectMake(20, bookImg.frame.size.height/2-20, bookImg.frame.size.width-20, 25)];
        [bookImg addSubview:nameLabel];
        nameLabel.textColor=[UIColor whiteColor];
        nameLabel.text=bookNameArr[i];
        nameLabel.font=[UIFont systemFontOfSize:13];
    }
    
    NSArray*titleArr=@[@"签字本",@"更多 >"];
    for(NSInteger i=0;i<2;i++)
    {
        UILabel*titleLabel=[[UILabel alloc]init];
        [homeworkBgView addSubview:titleLabel];
        titleLabel.font=[UIFont systemFontOfSize:14];
        titleLabel.text=titleArr[i];
        if(i==0)
        {
            titleLabel.frame=CGRectMake(10, 0, homeworkBgView.frame.size.width-110, 45);
        }
        else
        {
            titleLabel.textAlignment=NSTextAlignmentRight;
            titleLabel.textColor=XXYCharactersColor;
            titleLabel.frame=CGRectMake(homeworkBgView.frame.size.width-110+10, 0, 90, 45);
        }
    }
    UIView*lineView=[[UIView alloc]initWithFrame:CGRectMake(10, 40, homeworkBgView.frame.size.width-20, 1)];
    lineView.backgroundColor=XXYBgColor;
    [homeworkBgView addSubview:lineView];
}
-(void)homeWorkCileked:(UITapGestureRecognizer*)tap
{
    XXYHomeworkController*homeWorkC=[[XXYHomeworkController alloc]init];
    homeWorkC.hidesBottomBarWhenPushed=YES;
    [self.navigationController pushViewControllerWithAnimation:homeWorkC];
}
-(void)timeTableBtnCliked:(UIButton*)btn
{
    XXYTimeTableController*timetableCon=[[XXYTimeTableController alloc]init];
    timetableCon.hidesBottomBarWhenPushed=YES;
    [self.navigationController pushViewControllerWithAnimation:timetableCon];
}
//得到今天是周几
- (NSDictionary*)weekdayStringFromDate:(NSDate*)inputDate {
    
    NSArray *weekdays = [NSArray arrayWithObjects: [NSNull null], @{@"week":@"周日",@"id":@1}, @{@"week":@"周一",@"id":@2}, @{@"week":@"周二",@"id":@3}, @{@"week":@"周三",@"id":@4}, @{@"week":@"周四",@"id":@5}, @{@"week":@"周五",@"id":@6}, @{@"week":@"周六",@"id":@7}, nil];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSTimeZone *timeZone = [[NSTimeZone alloc] initWithName:@"Asia/Shanghai"];
    [calendar setTimeZone: timeZone];
    NSCalendarUnit calendarUnit = NSWeekdayCalendarUnit;
    NSDateComponents *theComponents = [calendar components:calendarUnit fromDate:inputDate];
    return [weekdays objectAtIndex:theComponents.weekday];
}

//按钮点击跳转
-(void)publishBtnCilked:(UIButton*)btn
{
    switch (btn.tag) {
        case 200:
        {
            XXYTimeTableController*timetableCon=[[XXYTimeTableController alloc]init];
            timetableCon.hidesBottomBarWhenPushed=YES;
            [self.navigationController pushViewControllerWithAnimation:timetableCon];
        }
            break;
        case 201:
        {
            XXYChileScoreController*publishCon=[[XXYChileScoreController alloc]init];
            publishCon.hidesBottomBarWhenPushed=YES;
            [self.navigationController pushViewControllerWithAnimation:publishCon];
        }
            break;
            
        case 202:
        {
            XXYTestFluidController*publishCon=[[XXYTestFluidController alloc]init];
            publishCon.hidesBottomBarWhenPushed=YES;
            [self.navigationController pushViewControllerWithAnimation:publishCon];
        }
            break;
            
        case 203:
        {
            XXYSafetyToolController*publishCon=[[XXYSafetyToolController alloc]init];
            publishCon.hidesBottomBarWhenPushed=YES;
            [self.navigationController pushViewControllerWithAnimation:publishCon];
        }
            break;
        default:
            break;
    }
}
-(void)viewWillAppear:(BOOL)animated
{
    [_sxMarquee start];
}
//导航栏无色
-(void)viewDidAppear:(BOOL)animated
{
    //状态栏颜色为黑色
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    self.navigationItem.title=@"";
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"transparent"] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage imageNamed:@"transparent"]];
}
- (void)didReceiveMemoryWarnin {
    [super didReceiveMemoryWarning];
}
@end
