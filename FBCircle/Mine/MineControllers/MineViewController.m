//
//  MineViewController.m
//  FBCircle
//
//  Created by soulnear on 14-8-4.
//  Copyright (c) 2014年 soulnear. All rights reserved.
//

#import "MineViewController.h"

#import "mineTableViewCell.h"

#import "GpersonallSettingViewController.h"

#import "FullyLoaded.h"

#import "SDImageCache.h"

#import "UIImageView+AFNetworking.h"

@interface MineViewController ()

@end

@implementation MineViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillDisappear:(BOOL)animated {
    [self setHidesBottomBarWhenPushed:NO];
    [super viewDidDisappear:animated];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIColor * cc = RGBCOLOR(91,138,59);
    
    NSDictionary * dict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:cc,[UIFont systemFontOfSize:20],[UIColor clearColor],nil] forKeys:[NSArray arrayWithObjects:UITextAttributeTextColor,UITextAttributeFont,UITextAttributeTextShadowColor,nil]];
    
    
    self.navigationController.navigationBar.titleTextAttributes = dict;
    
    self.navigationItem.title=@"我";
    
    self.iconArr=[NSArray arrayWithObjects:@"",@"",@"",@"",@"", nil];
    
    self.titleArr=[NSArray arrayWithObjects:@"通讯录",@"我的足迹",@"清除缓存",@"意见反馈",@"关于fb圈", nil];
    
    [self prepareNetData];

    
    
    // Do any additional setup after loading the view.
}

-(void)loadView{
    [super loadView];
    
 
    mainTab=[[UITableView alloc]initWithFrame:CGRectMake(0, 0, 320, iPhone5?568:480)];
    mainTab.delegate=self;
    mainTab.dataSource=self;
    mainTab.separatorColor=[UIColor clearColor];

    mainTab.backgroundColor=RGBCOLOR(246, 247, 249);

    [self.view addSubview:mainTab];

    


}
#pragma mark - 请求网络数据

-(void)prepareNetData{
    
    
    FBCirclePersonalModel *fbPersonModel = [[FBCirclePersonalModel alloc]init];
    
    [fbPersonModel loadPersonWithUid:[[NSUserDefaults standardUserDefaults] objectForKey:USERID] WithBlock:^(FBCirclePersonalModel *model) {
        
        
        self.personModel = model;
        NSLog(@"danteng===%@",self.personModel.person_face);
        [self.userFaceImageView setImageWithURL:[NSURL URLWithString:self.personModel.person_face] placeholderImage:[UIImage imageNamed:@"headimg150_150.png"]];
        self.userNameLabel.text = self.personModel.person_username;
        self.userWordsLabel.text = self.personModel.person_words;
        
   
        
        
        
        
        
    } WithFailedBlcok:^(NSString *string) {
        
    }];
    
}



#pragma 头像点击跳转个人设置
-(void)doTap{
    GRXX4ViewController *grxx4 = [[GRXX4ViewController alloc]init];
    //grxx4.isPersonalSettingClicked = YES;
    grxx4.passUserid = [SzkAPI getUid];
    [self.navigationController pushViewController:grxx4 animated:YES];
    
}
#pragma mark--tableviewDelegateAndDatesource

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{

    if (section==0) {
        return 103;

    }
    return 0;

}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    CGFloat height=0;
    
    switch (indexPath.row) {
        case 0:{
            
            height=76;
        
        }
            
            break;
        case 1:{
            
            height= 108;
        }
            
            break;
        
        case 2:{
                
                height= 44;
            }
            
            break;
            
            
        case 3:{
            
            height= 44;
        }
            
            break;
            
        case 4:{
            
            height= 100;
        }
            
            break;
            
        default:
            break;
    }
    
    return height;
}



-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section==0) {
        return 0;
    }

    return 5;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{

    return 2;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{

    if (section==0) {
        //头像 和 用户名 能点击部位
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setBackgroundImage:[UIImage imageNamed:@"geren320_103.png"] forState:UIControlStateHighlighted];
        btn.frame = CGRectMake(0, 0, 320, 103);
        [btn addTarget:self action:@selector(doTap) forControlEvents:UIControlEventTouchUpInside];
        
        
        
        //箭头
        UIImageView *jiantouV = [[UIImageView alloc]initWithFrame:CGRectMake(288, 45, 7, 14)];
        [jiantouV setImage:[UIImage imageNamed:@"geren-jiantou.png"]];
        [btn addSubview:jiantouV];
        
        
        //头像图片
        
        UIView *backFaceView = [[UIView alloc]initWithFrame:CGRectMake(23.5, 19.5, 63, 63)];
        backFaceView.backgroundColor = [UIColor whiteColor];
        backFaceView.layer.cornerRadius = 5;
        backFaceView.layer.borderColor = [RGBCOLOR(211, 211, 211)CGColor];
        backFaceView.layer.borderWidth = 0.3;
        backFaceView.layer.masksToBounds = YES;
        
        
        self.userFaceImageView = [[GavatarView alloc]initWithFrame:CGRectMake(24, 20, 62, 62)];
        self.userFaceImageView.layer.cornerRadius = 5;
        self.userFaceImageView.layer.borderWidth = 0;//设置边框的宽度，当然可以不要
        self.userFaceImageView.layer.borderColor = [[UIColor whiteColor] CGColor];//设置边框的颜色
        self.userFaceImageView.layer.masksToBounds = YES;
        self.userFaceImageView.userInteractionEnabled = YES;
        __weak typeof(self)bself = self;
        [self.userFaceImageView setAvatarClickedBlock:^{
            [bself doTap];
        }];
        
        
        [btn addSubview:backFaceView];
        [btn addSubview:self.userFaceImageView];
        
        if ([GlocalUserImage getUserFaceImage]) {
            [self.userFaceImageView setImage:[GlocalUserImage getUserFaceImage]];
        }else{
            [self.userFaceImageView setImageWithURL:self.string_photo placeholderImage:[UIImage imageNamed:@"geren_morentouxiang126_126.png"]];
        }
        
        
        
        
        
        
        
        //用户名
        self.userNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(self.userFaceImageView.frame)+12, 30, 188, 18)];
        //self.userNameLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:15];
        
        
        [btn addSubview:self.userNameLabel];
        
        //个性签名
        self.userWordsLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.userNameLabel.frame.origin.x, CGRectGetMaxY(self.userNameLabel.frame)+3, 169, 40)];
        self.userWordsLabel.font = [UIFont systemFontOfSize:12];
        self.userWordsLabel.textColor = [UIColor grayColor];
        self.userWordsLabel.numberOfLines = 2;
        
        [btn addSubview:self.userWordsLabel];
        
        
        [self.userFaceImageView setImageWithURL:[NSURL URLWithString:self.personModel.person_face] placeholderImage:[UIImage imageNamed:@"headimg150_150.png"]];
        self.userNameLabel.text = self.personModel.person_username;
        self.userWordsLabel.text = self.personModel.person_words;
        
        return btn;
        
    }
    return nil;
  

}




-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{


    static NSString *identifier=@"cell";
    
    mineTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:identifier];
    
    

    if (!cell) {
        cell=[[mineTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;

    }
    
    switch (indexPath.row) {
        case 0:{
            
            [cell setTitletext:[self.titleArr objectAtIndex:indexPath.row] iconstring:[self.iconArr objectAtIndex:indexPath.row] type:mineTableViewCellTypeFirst];

        }
            
            break;
        case 1:{
            
            [cell setTitletext:[self.titleArr objectAtIndex:indexPath.row] iconstring:[self.iconArr objectAtIndex:indexPath.row] type:mineTableViewCellTypeSecond];
        }
            
            break;
            
        case 2:{
            
        }
            
            
            
        case 3:{
            
            [cell setTitletext:[self.titleArr objectAtIndex:indexPath.row] iconstring:[self.iconArr objectAtIndex:indexPath.row] type:FBQuanAlertViewTypeHaveOther];
        }
            
            break;
            
        case 4:{
            
            [cell setTitletext:[self.titleArr objectAtIndex:indexPath.row] iconstring:[self.iconArr objectAtIndex:indexPath.row] type:FBQuanAlertViewTypeHaveLast];
        }
            
            break;
            
        default:
            break;
    }
    
//    UIView *selectback=[[UIView alloc]initWithFrame:cell.frame];
//    selectback.backgroundColor=[UIColor clearColor];
//    cell.selectedBackgroundView=selectback;
//
    
    return cell;
    
    
    


}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    NSLog(@"====%d",indexPath.row);
    
    switch (indexPath.row) {
        case 0:{
            
            FriendListViewController *_friendListV=[[FriendListViewController alloc]init];
            [self setHidesBottomBarWhenPushed:YES] ;

            [self.navigationController pushViewController:_friendListV animated:YES];

            
        }
            
            break;
        case 1:{
            
            //推到我的足迹界面
            [self setHidesBottomBarWhenPushed:YES] ;

            GmyFootViewController *gmyFootVC = [[GmyFootViewController alloc]init];

            [self.navigationController pushViewController:gmyFootVC animated:YES];

            
        }
            
            break;
            
        case 2:{
            
            //清除缓存
            [self clearTmpPics];

            
        }
            break;
            
            
        case 3:{
            UMFeedbackViewController *feedbackViewController = [[UMFeedbackViewController alloc] initWithNibName:@"UMFeedbackViewController" bundle:nil];
            feedbackViewController.appkey = @"5368ab4256240b6925029e29";
            [self setHidesBottomBarWhenPushed:YES] ;

            [self.navigationController pushViewController:feedbackViewController animated:YES];

        }
            
            break;
            
        case 4:{
            
            AboutFBQuanViewController *_aboutV=[[AboutFBQuanViewController alloc]init];
            [self setHidesBottomBarWhenPushed:YES] ;

            [self.navigationController pushViewController:_aboutV animated:YES];

            
        }
            
            break;
            
        default:
            break;
    }


}

#pragma mark - 清除缓存
-(void)removeCache
{
    
    
    
    NSString * path = [NSHomeDirectory() stringByAppendingPathComponent:@"tmp/data"];
    NSString *strdate=[NSString stringWithFormat:@"成功清除缓存%@",[SzkAPI fileSizeAtPath:path]];
    [[SDImageCache sharedImageCache] clearDisk];
    
    
    //弹出提示信息
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"温馨提示" message:strdate delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil, nil];
    
    [alert show];
}

- (void)clearTmpPics
{
    [[SDImageCache sharedImageCache] clearDisk];
    
    //    [[SDImageCache sharedImageCache] clearMemory];//可有可无
    
    float tmpSize = [[SDImageCache sharedImageCache] getSize];
    
    
    
    //    //document路径
    //    NSString *documentPathStr = [GlocalUserImage documentFolder];
    //    NSString *userFace = @"/guserFaceImage.png";
    //    NSString *userBanner = @"/guserBannerImage.png";
    //    //文件管理器
    //    NSFileManager *fileM = [NSFileManager defaultManager];
    //    //清除 头像和 banner
    //    [fileM removeItemAtPath:[documentPathStr stringByAppendingString:userFace] error:nil];
    //    [fileM removeItemAtPath:[documentPathStr stringByAppendingString:userBanner] error:nil];
    
    
    
    //    //清除图片
    [[FullyLoaded sharedFullyLoaded] removeAllCacheDownloads];
    
    
    
    //上传标志位
    //    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"gIsUpBanner"];
    //    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"gIsUpFace"];
    
    
    
    NSString *clearCacheName = tmpSize >= 1 ? [NSString stringWithFormat:@"清理缓存(%.2fM)",tmpSize] : [NSString stringWithFormat:@"清理缓存(%.2fK)",tmpSize * 1024];
    
    UIAlertView *_alert=[[UIAlertView alloc]initWithTitle:@"温馨提示" message:clearCacheName delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil, nil];
    [_alert show];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
