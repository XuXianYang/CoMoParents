#import "XXYJoinSchoolController.h"
#import "BSHttpRequest.h"
#import "AppDelegate.h"
#import "LMComBoxView.h"
#import "XXYLoginController.h"
@interface XXYJoinSchoolController ()<UITextFieldDelegate,LMComBoxViewDelegate>

@property(nonatomic,strong)UITextField*schoolCodeTextField;
@property(nonatomic,strong)UIButton*joinSchoolBtn;
@property(nonatomic,strong)UIImageView*bgImageView;
@property (nonatomic, strong) LMComBoxView *comBox;
@property(nonatomic,retain)NSArray*dataArray;
@property(nonatomic,strong)NSNumber*relationId;
@property(nonatomic,strong)UIView*bgView;
@end

@implementation XXYJoinSchoolController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title=@"添加孩子";
   
    [self setUpBgImageView];
    _relationId=@1;
    [self setUpSubviews];
    [self setUpNavigationControllerBackButton];
    [self setUpComBoxView];
    
    SVProgressHUD.minimumDismissTimeInterval=1.0  ;
    SVProgressHUD.maximumDismissTimeInterval=1.5  ;
}
-(void)setUpBgImageView
{
    _bgImageView=[[UIImageView alloc]initWithFrame:self.view.bounds];
    _bgImageView.image=[[UIImage imageNamed:@"bg_join_class"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    _bgImageView.userInteractionEnabled=YES;
    [self.view addSubview:_bgImageView];
}
-(void)viewWillAppear:(BOOL)animated
{
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
}
-(void)setUpNavigationControllerBackButton
{
    UIButton*btn=[UIButton buttonWithType:UIButtonTypeCustom];
    [btn setImage:[UIImage imageNamed:@"btn_back"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(backClicked:) forControlEvents:UIControlEventTouchUpInside];
    btn.frame=CGRectMake(20, 27, 30, 30);
    [self.view addSubview:btn];
    
    UILabel*label=[[UILabel alloc]initWithFrame:CGRectMake(100, 20, MainScreenW-200, 44)];
    label.text=@"添加孩子";
    label.textColor=[UIColor whiteColor];
    label.font=[UIFont fontWithName:@"Helvetica-Bold" size:19];
    label.textAlignment=NSTextAlignmentCenter;
    [self.view addSubview:label];
}
-(void)backClicked:(UIButton*)btn
{
    if(self.index)
    {
        [(AppDelegate*)[UIApplication sharedApplication].delegate showWindowHome:@"loginOut"];
//        XXYLoginController *loginVC = [[XXYLoginController alloc] init];
//        loginVC.index=1;
//        UINavigationController*navCon = [[UINavigationController alloc] initWithRootViewController:loginVC];
//        [UIApplication sharedApplication].keyWindow.rootViewController = navCon;
    }
    else
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}
-(NSArray*)dataArray
{
    if(!_dataArray)
    {
        _dataArray=@[@{@"name":@"父亲",@"id":@1},@{@"name":@"母亲",@"id":@2}];
    }
    return _dataArray;
}
-(void)setUpComBoxView
{
    _comBox = [[LMComBoxView alloc]initWithFrame:CGRectMake(_bgView.frame.size.width/3+30, 64+90, _bgView.frame.size.width*1/3, 45)];
    _comBox.backgroundColor = [UIColor whiteColor];
    NSMutableArray*dataArr=[NSMutableArray array];
    for (NSDictionary*dict in self.dataArray)
    {
        NSString*titleName=dict[@"name"];
        [dataArr addObject:titleName];
    }
    _comBox.titlesList = dataArr;
    
    _comBox.delegate = self;
    _comBox.supView = _bgImageView;
    [_comBox defaultSettings];
    _comBox.tag = 100;
    [_bgImageView addSubview:_comBox];
}
#pragma mark -LMComBoxViewDelegate
-(void)selectAtIndex:(int)index inCombox:(LMComBoxView *)_combox
{
    NSDictionary*dict=_dataArray[index];
    _relationId=dict[@"id"];
}
-(void)setUpSubviews
{
    
    _bgView=[[UIView alloc]initWithFrame:CGRectMake(20, 64+45, MainScreenW-40, 90)];
    _bgView.backgroundColor=[UIColor whiteColor];
    [_bgImageView addSubview:_bgView];
    
    NSArray*titleArr=@[@"学生码",@"关系"];
    for (NSInteger i=0;i<2;i++)
    {
        UILabel*titleLabel=[[UILabel alloc]initWithFrame:CGRectMake(10, 45*i, _bgView.frame.size.width/3-10, 45)];
        titleLabel.text=titleArr[i];
        titleLabel.textColor=XXYCharactersColor;
        [_bgView addSubview:titleLabel];
    }
    UIView*lineView=[[UIView alloc]initWithFrame:CGRectMake(10, 44.5, _bgView.frame.size.width-10, 1)];
    lineView.backgroundColor=XXYBgColor;
    [_bgView addSubview:lineView];
    
    _schoolCodeTextField=[[UITextField alloc]initWithFrame:CGRectMake(_bgView.frame.size.width/3, 0, _bgView.frame.size.width*2/3, 45)];
    _schoolCodeTextField.delegate=self;
    UIView*oldView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 10, 45)];
    _schoolCodeTextField.leftView=oldView;
    _schoolCodeTextField.leftViewMode=UITextFieldViewModeAlways;
    _schoolCodeTextField.keyboardType=UIKeyboardTypeASCIICapable;
    _schoolCodeTextField.placeholder=@"请填写孩子的学生码";
    _schoolCodeTextField.clearButtonMode =UITextFieldViewModeAlways;
    [_schoolCodeTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [_bgView addSubview:_schoolCodeTextField];
    
    _joinSchoolBtn=[UIButton buttonWithType:UIButtonTypeSystem];
    _joinSchoolBtn.frame=CGRectMake(20,64+180, MainScreenW-40, 45);
    _joinSchoolBtn.layer.cornerRadius=5;
    [_joinSchoolBtn setBackgroundColor:XXYMainColor];
    _joinSchoolBtn.titleLabel.font=[UIFont systemFontOfSize:19];
    [_joinSchoolBtn setTitle:@"添加孩子" forState:UIControlStateNormal];
    [_joinSchoolBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_joinSchoolBtn addTarget:self action:@selector(joinSchoolBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [_bgImageView addSubview:_joinSchoolBtn];
}
-(void)joinSchoolBtnClicked:(UIButton*)btn
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString*userSidString=[defaults objectForKey:@"userSid"];
    NSString*requestUrl=[NSString stringWithFormat:@"%@%@",BaseUrl,@"/parent/child/add"];
    
    if([XXYMyTools isEmpty:_schoolCodeTextField.text]||[XXYMyTools isChinese:_schoolCodeTextField.text]||_schoolCodeTextField.text.length==0)
    {
        [self setUpAlertController:@"学生码不能包含中文,空格等字符"];
    }
    else
    [BSHttpRequest POST:requestUrl parameters:@{@"sid":userSidString,@"studentCode":_schoolCodeTextField.text,@"relation":_relationId} success:^(id responseObject){
        
//        NSLog(@"Success: %@",[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        
        id objString = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSNumber*num=objString[@"code"];
        if([objString[@"message"] isEqualToString:@"success"]&&[num integerValue]==0)
        {
            
            if(self.index)
            {
                UIAlertController*alertCon = [UIAlertController alertControllerWithTitle:@"提示" message:@"添加孩子成功" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"返回" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                    
//                    XXYLoginController *loginVC = [[XXYLoginController alloc] init];
//                    XXYNavigationController*navCon = [[XXYNavigationController alloc] initWithRootViewController:loginVC];
//                    [UIApplication sharedApplication].keyWindow.rootViewController = navCon;
                    
                    [(AppDelegate*)[UIApplication sharedApplication].delegate showWindowHome:@"loginOut"];
                    
                }];
                [alertCon addAction:action1];
                UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                    
                    [(AppDelegate*)[UIApplication sharedApplication].delegate showWindowHome:@"login"];
                }];
                [alertCon addAction:action2];
                [self presentViewController:alertCon animated:YES completion:nil];
            }
            else
            {
                [SVProgressHUD showSuccessWithStatus:@"添加孩子成功"];
                if([self.reloadDelegate respondsToSelector:@selector(reloadTableView)])
                {
                    [self.reloadDelegate reloadTableView];
                }
                [self dismissViewControllerAnimated:YES completion:nil];

            }
            
        }
        else
        {
            NSString*failString=objString[@"message"];
            [self setUpAlertController:failString];
        }
        
        } failure:^(NSError *error){
        [self setUpAlertController:@"添加孩子失败"];
        }];
}
-(void)setUpAlertController:(NSString*)str
{
    UIAlertController*alertCon = [UIAlertController alertControllerWithTitle:@"提示" message:str preferredStyle:UIAlertControllerStyleAlert];
    [self presentViewController:alertCon animated:YES completion:nil];
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(creatAlert:) userInfo:alertCon repeats:NO];
}
- (void)creatAlert:(NSTimer *)timer{
    UIAlertController *alert = [timer userInfo];
    [alert dismissViewControllerAnimated:YES completion:nil];
    alert = nil;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    //注销第一响应者身份,隐藏键盘
    [textField resignFirstResponder];
    return YES;
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [_schoolCodeTextField resignFirstResponder];
    if(_comBox.isOpen)
    {
        [_comBox tapAction];
    }

}
- (void)textFieldDidChange:(UITextField *)textField
{
    if (textField == self.schoolCodeTextField)
    {
        if (textField.text.length > 12)
        {
            textField.text = [textField.text substringToIndex:12];
        }
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end
