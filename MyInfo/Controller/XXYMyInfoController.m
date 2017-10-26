#import "XXYMyInfoController.h"
#import "CropImageViewController.h"
#import <UIImageView+WebCache.h>
#import <AFNetworking.h>
#import "XXYMyChildController.h"
#import "XXYInfoSettingController.h"
#import"XXYSettingDetailController.h"
@interface XXYMyInfoController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    UIAlertController *_alertCon;
}

@property(nonatomic,strong)UIImageView*iconImageView;
@property(nonatomic,strong)UIImageView*bgIconImageView;
@property(nonatomic,strong)UIImage*selImage;
@property(nonatomic,strong)UILabel*nameLabel;

@end

@implementation XXYMyInfoController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=XXYBgColor;
    
    [self setUpSubViews];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationHandler:) name: @"CropOK" object: nil];
    
    [self getPersonInfoData];

}
-(void)getPersonInfoData
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString*userSidString=[defaults objectForKey:@"userSid"];
    NSString*requestUrl=[NSString stringWithFormat:@"%@%@",BaseUrl,@"/user/info"];
    [BSHttpRequest GET:requestUrl parameters:@{@"sid":userSidString} success:^(id responseObject){
        
//        NSLog(@"Success: %@",[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        
        id objString = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSDictionary*dict=objString[@"data"];
        
        [BSHttpRequest archiverObject:dict ByKey:@"myInfoCache" WithPath:@"myInfo.plist"];
        
        
        [_iconImageView sd_setImageWithURL:[NSURL URLWithString:objString[@"data"][@"avatarUrl"]] placeholderImage:[UIImage imageNamed:@"head_bj"]];
        if(objString[@"data"][@"realName"])
        {
           _nameLabel.text=objString[@"data"][@"realName"];
        }
        else
        {
            _nameLabel.text=@"请填写姓名";
        }
    } failure:^(NSError *error) {
        NSDictionary*dict=[BSHttpRequest unarchiverObjectByKey:@"myInfoCache" WithPath:@"myInfo.plist"];
        [_iconImageView sd_setImageWithURL:[NSURL URLWithString:dict[@"avatarUrl"]] placeholderImage:[UIImage imageNamed:@"head_bj"]];
        if(dict[@"realName"])
        {
            _nameLabel.text=dict[@"realName"];
        }
        else
        {
            _nameLabel.text=@"请填写姓名";
        }

    }];
}

-(void)setUpSubViews
{
    // 状态栏(statusbar)
    CGRect StatusRect = [[UIApplication sharedApplication] statusBarFrame];
    //标题栏
    CGRect NavRect = self.navigationController.navigationBar.frame;
    CGFloat scrollowTop=NavRect.size.height+StatusRect.size.height;
    
    UIScrollView*scrollView=[[UIScrollView alloc]initWithFrame:CGRectMake(0,-scrollowTop, MainScreenW, MainScreenH-49)];
    
    scrollView.backgroundColor=[UIColor colorWithRed:239.0/255 green:239.0/255 blue:244.0/255 alpha:1.0];
    scrollView.showsVerticalScrollIndicator=NO;
    scrollView.backgroundColor=XXYBgColor;
    scrollView.bounces=NO;
    scrollView.scrollEnabled=NO;
    scrollView.contentSize=CGSizeMake(0, MainScreenH-49);
    [self.view addSubview:scrollView];
    
    _bgIconImageView=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, MainScreenW, MainScreenW*2/3)];
    _bgIconImageView.image=[UIImage imageNamed:@"profile_bg"];
    _bgIconImageView.userInteractionEnabled=YES;
    [scrollView addSubview:_bgIconImageView];
    
    _iconImageView=[[UIImageView alloc]initWithFrame:CGRectMake((MainScreenW-100)/2,(MainScreenW*2/3-100)/2, 100, 100)];
    _iconImageView.image=[UIImage imageNamed:@"head_bj"];
    _iconImageView.layer.cornerRadius=50;
    _iconImageView.layer.masksToBounds=YES;
    _iconImageView.userInteractionEnabled=YES;
    [_bgIconImageView addSubview:_iconImageView];
    
    UITapGestureRecognizer * pictureTap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAvatarView:)];
    [_iconImageView addGestureRecognizer:pictureTap];

    _nameLabel=[[UILabel alloc]initWithFrame:CGRectMake((MainScreenW-100)/2, (MainScreenW*2/3-100)/2+105, 100, 40)];
    _nameLabel.textColor=[UIColor whiteColor];
    _nameLabel.textAlignment=NSTextAlignmentCenter;
    _nameLabel.font=[UIFont systemFontOfSize:18];
    _nameLabel.userInteractionEnabled=YES;
    UITapGestureRecognizer*tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapNameClieked:)];
    [_nameLabel addGestureRecognizer:tap];

    [_bgIconImageView addSubview:_nameLabel];
   
    NSDictionary*dict=[BSHttpRequest unarchiverObjectByKey:@"myInfoCache" WithPath:@"myInfo.plist"];
    if(dict)
    {
        [_iconImageView sd_setImageWithURL:[NSURL URLWithString:dict[@"avatarUrl"]] placeholderImage:[UIImage imageNamed:@"head_bj"]];
        _nameLabel.text=dict[@"realName"];

    }
    
    UIDevice*device= [UIDevice currentDevice];
    CGFloat picHeight=0.0;
    CGFloat bgHeight=0.0;
    if([device.model isEqualToString:@"iPad"])
    {
        picHeight=MainScreenW*2/3-60;
        bgHeight=(MainScreenW-30)/4;
    }
    else
    {
        picHeight=MainScreenW*2/3-15;
        bgHeight=(MainScreenW-30)/2;
        
    }
    UIView*bgView=[[UIView alloc]initWithFrame:CGRectMake(15, picHeight, MainScreenW-30, bgHeight)];
    bgView.backgroundColor=[UIColor whiteColor];
    [scrollView addSubview:bgView];
    
    UIView*lineView=[[UIView alloc]initWithFrame:CGRectMake((MainScreenW-30)/2, 0, 1, bgHeight)];
    lineView.backgroundColor=XXYBgColor;
    [bgView addSubview:lineView];
    
    NSArray*imgArr=@[@"my_child",@"my_setting"];
    NSArray*titleArr=@[@"孩子",@"设置"];
    for(NSInteger i=0;i<2;i++)
    {
        UIButton*btn=[UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame=CGRectMake((MainScreenW-30)/2*i, 0, (MainScreenW-30)/2, bgHeight);
        btn.tag=88+i;
        [btn addTarget:self action:@selector(settingBtnCliked:) forControlEvents:UIControlEventTouchUpInside];
        [bgView addSubview:btn];
        
        UIImageView*imgView=[[UIImageView alloc]initWithFrame:CGRectMake((btn.frame.size.width-bgHeight+70)/2, 20, bgHeight-70, bgHeight-70)];
        imgView.image=[UIImage imageNamed:imgArr[i]];
        [btn addSubview:imgView];
        
        UILabel*titleL=[[UILabel alloc]initWithFrame:CGRectMake(0, bgHeight-50, btn.frame.size.width, 50)];
        titleL.textAlignment=NSTextAlignmentCenter;
        titleL.font=[UIFont systemFontOfSize:20];
        titleL.textColor=XXYCharactersColor;
        titleL.text=titleArr[i];
        [btn addSubview:titleL];
    }
}
-(void)tapNameClieked:(UITapGestureRecognizer*)tap
{
    XXYSettingDetailController*detailCon=[[XXYSettingDetailController alloc]init];
    detailCon.titleName=@"个人资料";
    detailCon.index=2;
    detailCon.hidesBottomBarWhenPushed=YES;
    [self.navigationController pushViewControllerWithAnimation:detailCon];
}
-(void)settingBtnCliked:(UIButton*)btn
{
    switch (btn.tag) {
        case 88:
        {
            XXYMyChildController*childCon=[[XXYMyChildController alloc]init];
            childCon.hidesBottomBarWhenPushed=YES;
            [self.navigationController pushViewControllerWithAnimation:childCon];
        }
            break;
        case 89:
        {
            XXYInfoSettingController*childCon=[[XXYInfoSettingController alloc]init];
            childCon.hidesBottomBarWhenPushed=YES;
            [self.navigationController pushViewControllerWithAnimation:childCon];
        }
            break;
 
        default:
            break;
    }
    
}
-(void)tapAvatarView:(UITapGestureRecognizer*)tap
{
    UIAlertController*al=[UIAlertController alertControllerWithTitle:@"请选择图片来源" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    
    UIPopoverPresentationController *popover = al.popoverPresentationController;
    
    if (popover) {
        
        popover.sourceView = _iconImageView;
        popover.sourceRect = _iconImageView.bounds;
        popover.permittedArrowDirections = UIPopoverArrowDirectionAny;
    }
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"照相机" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
                              {
                                  [self pickPicture:UIImagePickerControllerSourceTypeCamera];
                              }];
    [al addAction:action1];
    
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"本地相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
                              {
                                  [self pickPicture:UIImagePickerControllerSourceTypePhotoLibrary];
                              }];
    [al addAction:action2];
    
    UIAlertAction *action4 = [UIAlertAction actionWithTitle:@"取消 " style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action)
                              {
                              }];
    [al addAction:action4];
    
    [self presentViewController:al animated:YES completion:nil];
}
-(void)pickPicture:(UIImagePickerControllerSourceType)sourceType
{
    // 跳转到相机或相册页面
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    imagePickerController.allowsEditing = YES;
    imagePickerController.sourceType = sourceType;
    [self presentViewController:imagePickerController animated:YES completion:^{
    
        if(![XXYMyTools isCameraValid]&&sourceType==1)
        {
            [SVProgressHUD showErrorWithStatus:@"如果不能访问相机,请在iPhone的“设置-隐私-相机”选项中，允许程序访问你的相机"];
        }
        if(sourceType==0)
        {
            [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
        }

    }];
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:^{}];
    
    //NSLog(@"imageInfo=%@",info);
    _selImage=[info objectForKey:UIImagePickerControllerOriginalImage];
    _selImage=[XXYMyTools fixOrientation:_selImage];
    CropImageViewController*cropCon=[[CropImageViewController alloc]init];
    cropCon.image=_selImage;
    cropCon.hidesBottomBarWhenPushed=YES;
    [self.navigationController pushViewController:cropCon animated:YES];
}
- (void)notificationHandler: (NSNotification *)notification
{
    UIImage*image = notification.object;
    [self uploadPicture:image];
}
-(void)uploadPicture:(UIImage*)image
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString*userSidString=[defaults objectForKey:@"userSid"];
    // 获取图片数据
    NSData *fileData = UIImageJPEGRepresentation(image, 0.2);
    // 设置上传图片的名字
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyyMMddHHmmss";
    NSString *str = [formatter stringFromDate:[NSDate date]];
    NSString *fileName = [NSString stringWithFormat:@"%@.jpg", str];
    // 获得网络管理者
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer=[AFHTTPRequestSerializer serializer];
    manager.responseSerializer=[AFHTTPResponseSerializer serializer];
    
    NSString*urlString=[NSString stringWithFormat:@"%@/user/avatar/upload?sid=%@",BaseUrl,userSidString];
    
    
    urlString=[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
  
    NSNumber*imageWidth=[NSNumber numberWithFloat:image.size.width-1];
    NSMutableDictionary *parameter = [NSMutableDictionary dictionary];
    parameter[@"topX"] = @0;
    parameter[@"topY"] = @0;
    parameter[@"width"] = imageWidth;
    [manager POST:urlString parameters:parameter constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        if (fileData != nil)
        {
            [formData appendPartWithFileData:fileData name:@"file" fileName:fileName mimeType:@"image/jpg"];
        }
    } progress:^(NSProgress * _Nonnull uploadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        NSLog(@"Success: %@",[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        id objString = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        if([objString[@"message"] isEqualToString:@"success"])
        {
            _iconImageView.image=_selImage;
            [self setUpAlertController:@"更换头像成功"];
        }
        else
        {
            [self setUpAlertController:objString[@"message"]];
            
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        // NSLog(@"error=%@",error.localizedDescription);
        [self setUpAlertController:@"更换头像失败"];
    }];
}
-(void)setUpAlertController:(NSString*)str
{
    _alertCon = [UIAlertController alertControllerWithTitle:@"提示" message:str preferredStyle:UIAlertControllerStyleAlert];
    [self presentViewController:_alertCon animated:YES completion:nil];
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(creatAlert:) userInfo:_alertCon repeats:NO];
}
- (void)creatAlert:(NSTimer *)timer{
    UIAlertController *alert = [timer userInfo];
    [alert dismissViewControllerAnimated:YES completion:^{
        
    }];
    alert = nil;
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:^{
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    }];
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
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
-(void)viewWillAppear:(BOOL)animated
{
    [self getPersonInfoData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end
