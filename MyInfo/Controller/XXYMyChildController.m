#import "XXYMyChildController.h"
#import "XXYBackButton.h"
#import "XXYMyChildModel.h"
#import "XXYmYChildCell.h"
#import "XXYJoinSchoolController.h"
#import <MJRefresh/MJRefresh.h>
@interface XXYMyChildController ()<UITableViewDelegate,UITableViewDataSource,XXYReloadDataDelegate>

@property(nonatomic,retain)NSMutableArray*dataList;
@property(nonatomic,strong)UITableView*tableView;

@end

@implementation XXYMyChildController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=XXYBgColor;
    self.navigationItem.title=@"我的孩子";
    
    XXYBackButton*backButton=[XXYBackButton setUpBackButton];
    [backButton addTarget:self action:@selector(backClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc]initWithCustomView:backButton];
    
    SVProgressHUD.minimumDismissTimeInterval=1.0  ;
    SVProgressHUD.maximumDismissTimeInterval=1.5  ;
    [self setUpSubViews];
    
    [self setUpTableView];
    
    [self addRefreshLoadMore];
}
-(void)setUpSubViews
{
    UIButton*addBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    addBtn.frame=CGRectMake(0, 0, 30, 30);
    [addBtn setImage:[UIImage imageNamed:@"nav_add"] forState:UIControlStateNormal];
    [addBtn addTarget:self action:@selector(addChildBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc]initWithCustomView:addBtn];
}
-(void)reloadTableView
{
    [self loadNewData];
}
-(void)addChildBtnClicked:(UIBarButtonItem*)barItem
{
    XXYJoinSchoolController*joinC=[[XXYJoinSchoolController alloc]init];
    joinC.reloadDelegate=self;
    [self presentViewController:joinC animated:YES completion:nil];
}
-(void)setUpTableView
{
    [self.view addSubview:self.tableView];
    self.tableView.dataSource=self;
    self.tableView.delegate=self;
    self.tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    self.tableView.showsVerticalScrollIndicator=NO;
    self.tableView.backgroundColor=XXYBgColor;
    [self.tableView registerNib:[UINib nibWithNibName:@"XXYmYChildCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"cellId"];
}
- (void)addRefreshLoadMore
{
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
    [header beginRefreshing];
    self.tableView.mj_header = header;
}
-(void)loadNewData
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString*userSidString=[defaults objectForKey:@"userSid"];
    NSString*requestUrl=[NSString stringWithFormat:@"%@%@",BaseUrl,@"/parent/child/list"];
    [BSHttpRequest GET:requestUrl parameters:@{@"sid":userSidString} success:^(id responseObject){
        //NSLog(@"Success: %@",[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        [self.tableView.mj_header endRefreshing];
        //先清空数据源
        [self.dataList removeAllObjects];
        id objString = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSArray*array=objString[@"data"];
        [BSHttpRequest archiverObject:array ByKey:@"myChildInfonListCache" WithPath:@"myChildInfonListCache.plist"];
        for (NSDictionary*dict in array)
        {
            XXYMyChildModel*model=[[XXYMyChildModel alloc]init];
            model.schoolName=dict[@"studentInfo"][@"schoolName"];
            model.className=dict[@"studentInfo"][@"className"];
            model.avatarUrl=dict[@"avatarUrl"];
            model.realName=dict[@"realName"];
            model.isDefaultChild=dict[@"isDefaultChild"];
            model.childId=dict[@"id"];
            [self.dataList addObject:model];
        }
        [self.tableView reloadData];
        
    } failure:^(NSError *error) {
        
        [self.dataList removeAllObjects];
        NSArray*array =[BSHttpRequest unarchiverObjectByKey:@"myChildInfonListCache" WithPath:@"myChildInfonListCache.plist"];
        if(array.count>0)
        {
            for (NSDictionary*dict in array)
            {
                XXYMyChildModel*model=[[XXYMyChildModel alloc]init];
                model.schoolName=dict[@"studentInfo"][@"schoolName"];
                model.className=dict[@"studentInfo"][@"className"];
                model.avatarUrl=dict[@"avatarUrl"];
                model.realName=dict[@"realName"];
                model.isDefaultChild=dict[@"isDefaultChild"];
                model.childId=dict[@"id"];
                [self.dataList addObject:model];

            }
            [self.tableView reloadData];
        }
        [self.tableView.mj_header endRefreshing];
    }];
}
-(UITableView*)tableView
{
    if(!_tableView)
    {
        _tableView=[[UITableView alloc]initWithFrame:CGRectMake(10,0,MainScreenW-20, MainScreenH-64) style:UITableViewStylePlain];
        _tableView.backgroundColor=[UIColor clearColor];
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
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dataList.count;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    XXYmYChildCell*cell=[tableView dequeueReusableCellWithIdentifier:@"cellId" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.dataModel=self.dataList[indexPath.section];
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    XXYMyChildModel*model=self.dataList[indexPath.section];
    [self selectedDefultChild:model.childId];
}
-(void)selectedDefultChild:(NSString*)childId
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString*userSidString=[defaults objectForKey:@"userSid"];
    NSString*requestUrl=[NSString stringWithFormat:@"%@%@",BaseUrl,@"/parent/child/select"];
    
    [BSHttpRequest POST:requestUrl parameters:@{@"sid":userSidString,@"studentUserId":childId} success:^(id responseObject){
            
//        NSLog(@"Success: %@",[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
            
            id objString = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        
        if([objString[@"message"] isEqualToString:@"success"])
        {
            [self loadNewData];
        }
        else
        {
            [SVProgressHUD showSuccessWithStatus:@"选择失败"];
        }
                    } failure:^(NSError *error){
                        [SVProgressHUD showSuccessWithStatus:@"选择失败"];
        }];

}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    
    return 15;
}
-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView*view=[[UIView alloc]init];
    view.backgroundColor=XXYBgColor;
    return view;
}

-(void)backClicked:(UIButton*)btn
{
    [self.navigationController popViewControllerWithAnimation];
}
-(void)viewDidDisappear:(BOOL)animated
{
    if([self.reloadDelegate respondsToSelector:@selector(reloadTableView)])
    {
        [self.reloadDelegate reloadTableView];
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
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end
