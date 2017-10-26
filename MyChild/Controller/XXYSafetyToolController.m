#import "XXYSafetyToolController.h"
#import "XXYBackButton.h"
#import "XXYSafetyToolsModel.h"
#import "XXYSafetyToolsCell.h"
#import <MJRefresh/MJRefresh.h>
@interface XXYSafetyToolController ()<UITableViewDelegate,UITableViewDataSource>
{
    NSInteger _currentPage;
}
@property(nonatomic,retain)NSMutableArray*dataList;
@property(nonatomic,retain)NSMutableArray*dataCacheArray;
@property(nonatomic,strong)UITableView*tableView;

@property(nonatomic,strong)UIView*headerBgView;
@property(nonatomic,strong)UIImageView*iconImageView;
@property(nonatomic,strong)UILabel*safetyTitleLabel;

@property(nonatomic,strong)UIView*nothingView;

@end

@implementation XXYSafetyToolController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title=@"安全助手";
    //self.view.backgroundColor=XXYBgColor;
    XXYBackButton*backButton=[XXYBackButton setUpBackButton];
    [backButton addTarget:self action:@selector(backClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc]initWithCustomView:backButton];
    
    SVProgressHUD.minimumDismissTimeInterval=1.0  ;
    SVProgressHUD.maximumDismissTimeInterval=1.5  ;
    
    [self setUpTableView];
    [self addRefreshLoadMore];
}
//添加刷新加载更多
- (void)addRefreshLoadMore
{
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
    [header beginRefreshing];
    self.tableView.mj_header = header;
    __unsafe_unretained __typeof(self) weakSelf = self;
    
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [weakSelf loadMoreData];
    }];
    self.tableView.mj_footer.automaticallyHidden = YES;
}
-(void)loadMoreData
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString*userSidString=[defaults objectForKey:@"userSid"];
    NSNumber *page = [NSNumber numberWithInteger:_currentPage];
    NSString*requestUrl=[NSString stringWithFormat:@"%@%@",BaseUrl,@"/parent/sos/msg/list"];
    
    [BSHttpRequest GET:requestUrl parameters:@{@"sid":userSidString,@"pageNum":page,@"pageSize":@10} success:^(id responseObject){
        
        [self.tableView.mj_footer endRefreshing];
        //NSLog(@"Success: %@",[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        id objString = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSArray*dataArr=objString[@"data"];
        if(dataArr.count>0)
        {
            _currentPage++;
            [self.dataCacheArray addObjectsFromArray:dataArr];
            [BSHttpRequest archiverObject:self.dataCacheArray ByKey:@"sosInfoDataCache" WithPath:@"sosInfoDataCache.plist"];
            [self.dataList addObjectsFromArray:dataArr];
        }
        else
        {
            [SVProgressHUD showSuccessWithStatus:@"已经到底了~"];
        }
        
        [self.tableView reloadData];
        
    } failure:^(NSError *error) {
        
        [self.tableView.mj_footer endRefreshing];
        //        [SVProgressHUD showSuccessWithStatus:@"没有更多内容了"];
        [SVProgressHUD showSuccessWithStatus:@"已经到底了~"];
    }];
    
}
-(void)loadNewData
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString*userSidString=[defaults objectForKey:@"userSid"];
    
    NSString*requestUrl=[NSString stringWithFormat:@"%@%@",BaseUrl,@"/parent/sos/msg/list"];
    
    _currentPage=2;
    
    [BSHttpRequest GET:requestUrl parameters:@{@"sid":userSidString} success:^(id responseObject){
        
//        NSLog(@"Success: %@",[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        
        [self.tableView.mj_header endRefreshing];
        //先清空数据源
        [self.dataList removeAllObjects];
        [self.dataCacheArray removeAllObjects];
        
        id objString = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        
        NSArray*array=objString[@"data"];
        
        
        if(array.count>0)
        {
            [_nothingView removeFromSuperview];
            self.tableView.tableHeaderView=self.headerBgView;

            NSDictionary*infodict=array[0];
            NSArray*arr=infodict[@"sosMessageDtoList"];
            NSDictionary*mesInfoDict=arr[0];
            NSString*messageType=mesInfoDict[@"messageType"];
            if(messageType.integerValue==1)
            {
                _iconImageView.image=[UIImage imageNamed:@"help-danger-bg"];
                _safetyTitleLabel.text=@"危险警报";
                
            }
        }
        if(array.count<=0)
        {
            [self setUpNoHomeworkOfSubViews];
        }
        self.dataCacheArray=[NSMutableArray arrayWithArray:array];
        self.dataList=[NSMutableArray arrayWithArray:array];
        [BSHttpRequest archiverObject:self.dataCacheArray ByKey:@"sosInfoDataCache" WithPath:@"sosInfoDataCache.plist"];
        
        [self.tableView reloadData];
    } failure:^(NSError *error) {
        
        [self.dataList removeAllObjects];
        self.dataList =[BSHttpRequest unarchiverObjectByKey:@"sosInfoDataCache" WithPath:@"sosInfoDataCache.plist"];
        if(self.dataList.count>0)
        {
           self.tableView.tableHeaderView=self.headerBgView;
        }
        [self.tableView reloadData];
        [self.tableView.mj_header endRefreshing];
    }];
}
-(void)setUpNoHomeworkOfSubViews
{
    self.tableView.tableHeaderView=nil;
    [_nothingView removeFromSuperview];
    
    CGFloat height=self.tableView.frame.size.height;
    CGFloat width=self.tableView.frame.size.width;
    
    _nothingView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, width, height)];
    [self.tableView addSubview:_nothingView];
    CGFloat hight=(height-width/2)/3;
    //320*260
    UIImageView*imageView=[[UIImageView alloc]initWithFrame:CGRectMake(width/4, hight, width/2,width/2*5/7)];
    imageView.image=[UIImage imageNamed:@"no_network"];
    [_nothingView addSubview:imageView];
    
    UILabel*label=[[UILabel alloc]initWithFrame:CGRectMake(50, hight+width/2*5/7, width-100,50)];
    label.textAlignment=NSTextAlignmentCenter;
    label.textColor=[UIColor colorWithRed:146.0/255 green:146.0/255 blue:146.0/255 alpha:1.0];
    label.font=[UIFont systemFontOfSize:16];
    label.text=@"暂无安全信息";
    [_nothingView addSubview:label];
}

-(void)setUpTableView
{
    [self.view addSubview:self.tableView];
    
    self.tableView.dataSource=self;
    self.tableView.delegate=self;
//    self.tableView.backgroundColor=[UIColor clearColor];
    self.tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    self.tableView.showsVerticalScrollIndicator=NO;
    //    self.tableView.bounces=NO;
    [self.tableView registerNib:[UINib nibWithNibName:@"XXYSafetyToolsCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"cellId"];
//        self.tableView.tableHeaderView=_headerBgView;
}
-(UIView*)headerBgView
{
    if(!_headerBgView)
    {
        //tableView头视图
        _headerBgView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, MainScreenW, 150)];
        _headerBgView.backgroundColor=[UIColor colorWithRed:255.0/255 green:3.0/255 blue:18.0/255 alpha:1.0];
        _iconImageView=[[UIImageView alloc]initWithFrame:CGRectMake((MainScreenW-70)/2, 30, 70, 70)];
        _iconImageView.image=[UIImage imageNamed:@"help-success-bg"];
        [_headerBgView addSubview:_iconImageView];
        _safetyTitleLabel=[[UILabel alloc]initWithFrame:CGRectMake((MainScreenW-100)/2, 100, 100, 50)];
        _safetyTitleLabel.textAlignment=NSTextAlignmentCenter;
        _safetyTitleLabel.font=[UIFont systemFontOfSize:19];
        _safetyTitleLabel.textColor=[UIColor whiteColor];
        _safetyTitleLabel.text=@"安全到家!";
        [_headerBgView addSubview:_safetyTitleLabel];
    }
    return _headerBgView;
}
-(UITableView*)tableView
{
    if(!_tableView)
    {
        _tableView=[[UITableView alloc]initWithFrame:CGRectMake(0,0,MainScreenW, [XXYMyTools normalTableheight]) style:UITableViewStylePlain];
    }
    return _tableView;
}
-(NSMutableArray*)dataList
{
    if(!_dataList)
    {
        _dataList=[NSMutableArray array];
    }
    return _dataList;
}
-(NSMutableArray*)dataCacheArray
{
    if(!_dataCacheArray)
    {
        _dataCacheArray=[NSMutableArray array];
    }
    return _dataCacheArray;
}
#pragma mark -tableViewDelegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSDictionary*dict=self.dataList[section];
    NSArray*arr=dict[@"sosMessageDtoList"];
    return arr.count;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dataList.count;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    XXYSafetyToolsCell*cell=[tableView dequeueReusableCellWithIdentifier:@"cellId" forIndexPath:indexPath];
    
    NSDictionary*dataDict=self.dataList[indexPath.section];
    NSArray*arr=dataDict[@"sosMessageDtoList"];
    NSDictionary*dict=arr[indexPath.row];

    XXYSafetyToolsModel*model=[[XXYSafetyToolsModel alloc]initWithDictionary:dict error:nil];
    cell.dataModel=model;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary*dataDict=self.dataList[indexPath.section];
    
    NSArray*arr=dataDict[@"sosMessageDtoList"];
    NSDictionary*dict=arr[indexPath.row];
    //文字
    CGFloat textMaxW = MainScreenW - 150;
    CGSize textMaxSize = CGSizeMake(textMaxW, MAXFLOAT);
    CGSize textSize = [dict[@"content"] boundingRectWithSize:textMaxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]} context:nil].size;
    CGFloat cellHeight = textSize.height + 45;
    
    return cellHeight;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20;
}
-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView*view=[[UIView alloc]initWithFrame:CGRectMake(0, 0, MainScreenW, 20)];
    view.backgroundColor=[UIColor clearColor];
    
    UILabel*label=[[UILabel alloc]initWithFrame:CGRectMake(40, 0, 70, 20)];
    label.textColor=[UIColor lightGrayColor];
    label.font=[UIFont systemFontOfSize:13];
    label.textAlignment=NSTextAlignmentCenter;
    [view addSubview:label];
    NSDictionary*dataDict=self.dataList[section];
    NSString*disTime=dataDict[@"dayDistance"];
    if(disTime.integerValue==0)
    {
        disTime=@"今天";
    }
    else
    {
        disTime=[NSString stringWithFormat:@"%@ 天前",disTime];
    }
    label.text=disTime;
    return view;
}
-(void)backClicked:(UIButton*)btn
{
    if(self.isPush)
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }

}
-(void)viewWillAppear:(BOOL)animated
{
    //状态栏颜色为白色
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navBg"] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage imageNamed:@"navBg"]];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"Helvetica-Bold" size:19],NSForegroundColorAttributeName:[UIColor whiteColor]}];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
@end
