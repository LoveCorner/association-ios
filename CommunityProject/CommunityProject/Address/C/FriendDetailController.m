//
//  FriendDetailController.m
//  CommunityProject
//
//  Created by bjike on 17/3/25.
//  Copyright © 2017年 来自任性傲娇的女王. All rights reserved.
//

#import "FriendDetailController.h"
#import "NameViewController.h"
#import "ChatDetailController.h"
#import "ChatMainController.h"

#define DeleteURL @"http://192.168.0.209:90/appapi/app/deleteUser"

@interface FriendDetailController ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *widthContraints;

@property (weak, nonatomic) IBOutlet UIImageView *headImageView;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (weak, nonatomic) IBOutlet UIImageView *sexImageView;
@property (weak, nonatomic) IBOutlet UILabel *userLabel;

@property (weak, nonatomic) IBOutlet UILabel *recomendLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (weak, nonatomic) IBOutlet UILabel *knowLabel;

@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;
@property (weak, nonatomic) IBOutlet UILabel *contributeLabel;

@property (weak, nonatomic) IBOutlet UILabel *birthdayLabel;
@property (weak, nonatomic) IBOutlet UILabel *prestigeLabel;
@property (weak, nonatomic) IBOutlet UILabel *areaLabel;

@property (weak, nonatomic) IBOutlet UILabel *displayNameLabel;
@property (nonatomic,copy)NSString * userId;
@property (weak, nonatomic) IBOutlet UIView *sendView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end

@implementation FriendDetailController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setBar];
    [self setUI];
}
-(void)setBar{
    self.navigationItem.title = @"详细资料";
    UIBarButtonItem * leftItem = [UIBarButtonItem CreateBackButtonWithFrame:CGRectMake(0, 0,50, 40) andTitle:@"返回" andTarget:self Action:@selector(leftClick)];
    self.navigationItem.leftBarButtonItem = leftItem;
    self.navigationController.navigationBar.tintColor = UIColorFromRGB(0x121212);
    self.userId = [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"];
    if (![self.userId isEqualToString:self.friendId]) {
        UIBarButtonItem * rightItem = [[UIBarButtonItem alloc]initWithTitle:@"删除" style:UIBarButtonItemStylePlain target:self action:@selector(rightClick)];
        self.navigationItem.rightBarButtonItem = rightItem;
    }
}
//初始化传参过来的数据
-(void)setUI{
    self.headImageView.layer.cornerRadius = 5;
    self.headImageView.layer.masksToBounds = YES;
    [self.headImageView sd_setImageWithURL:[NSURL URLWithString:self.url]];
    if (self.age.length == 0) {
        self.nameLabel.text = [NSString stringWithFormat:@"%@  0岁",self.name];
    }else{
        self.nameLabel.text = [NSString stringWithFormat:@"%@  %@岁",self.name,self.age];
    }
    if (self.sex == 1) {
        self.sexImageView.image = [UIImage imageNamed:@"man.png"];
    }else{
        self.sexImageView.image = [UIImage imageNamed:@"woman.png"];
    }
    self.userLabel.text = [NSString stringWithFormat:@"账号：%@",self.friendId];
    if (self.recomendPerson.length == 0) {
        self.recomendLabel.text = @"推荐人：";
    }else{
        self.recomendLabel.text = [NSString stringWithFormat:@"推荐人：%@",self.recomendPerson];
    }
    if (self.email.length == 0) {
        self.emailLabel.text = @"邮箱：";
    }else{
        self.emailLabel.text = [NSString stringWithFormat:@"邮箱：%@",self.email];
    }
    if (self.lingPerson.length == 0) {
        self.knowLabel.text = @"认领人：";
    }else{
        self.knowLabel.text = [NSString stringWithFormat:@"认领人：%@",self.lingPerson];
    }
    if (self.phone.length == 0) {
        self.phoneLabel.text = @"电话：";
    }else{
        self.phoneLabel.text = [NSString stringWithFormat:@"电话：%@",self.phone];
    }
    
    if (self.contribute.length == 0) {
        self.contributeLabel.text = @"贡献值：";
    }else{
        self.contributeLabel.text = [NSString stringWithFormat:@"贡献值：%@",self.contribute];
    }
    if (self.prestige.length == 0) {
        self.prestigeLabel.text = @"信誉值：";
    }else{
        self.prestigeLabel.text = [NSString stringWithFormat:@"信誉值：%@",self.prestige];
    }
    if (self.birthday.length == 0) {
        self.birthdayLabel.text = @"生日：";
    }else{
        self.birthdayLabel.text = [NSString stringWithFormat:@"生日：%@",self.birthday];
    }
    if (self.areaStr.length == 0) {
        self.areaLabel.text = @"地址：";
    }else{
        self.areaLabel.text = [NSString stringWithFormat:@"地址：%@",self.areaStr];
    }
    if (self.display.length == 0) {
        self.displayNameLabel.text = @"";
    }else{
        self.displayNameLabel.text = self.display;
    }
}
-(void)leftClick{
    [self.navigationController popViewControllerAnimated:YES];
}
//删除好友
-(void)rightClick{
    WeakSelf;
    [MessageAlertView alertViewWithTitle:@"亲，确定删除该好友吗？" message:nil buttonTitle:@[@"取消",@"确定"] Action:^(NSInteger indexpath) {
        if (indexpath == 0) {
            NSSLog(@"取消");
        }else{
            [weakSelf deleteFriend];
        }
    } viewController:self];
}
-(void)deleteFriend{
    NSUserDefaults * user = [NSUserDefaults standardUserDefaults];
    NSString * nickname = [user objectForKey:@"nickname"];
    NSString * headUrl = [user objectForKey:@"userPortraitUrl"];
    NSString * url = [ImageUrl changeUrl:headUrl];
    RCUserInfo * userInfo = [[RCUserInfo alloc]initWithUserId:self.userId name:nickname portrait:[NSString stringWithFormat:@"http://192.168.0.209:90/%@",url]];
    WeakSelf;
    [AFNetData postDataWithUrl:DeleteURL andParams:@{@"userId":self.userId,@"friendUserid":self.friendId} returnBlock:^(NSURLResponse *response, NSError *error, id data) {
        if (error) {
            NSSLog(@"删除好友失败%@",error);
        }else{
            NSDictionary * jsonDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            NSSLog(@"%@",jsonDic);
            NSNumber * code = jsonDic[@"code"];
            if ([code intValue] == 200) {
                //刷新SDK缓存 
                [[RCIM sharedRCIM]refreshUserInfoCache:userInfo withUserId:self.userId];
                //返回通讯录刷新通讯录
                if (weakSelf.isAddress) {
                    weakSelf.listDelegate.isRef = YES;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf.navigationController popViewControllerAnimated:YES];
                    });
                }else{//返回会话列表
                    dispatch_async(dispatch_get_main_queue(), ^{
                        for (UIViewController* vc in self.navigationController.viewControllers) {
                            
                            if ([vc isKindOfClass:[ChatMainController class]]) {
                                
                                [weakSelf.navigationController popToViewController:vc animated:YES];
                            }
                        }
                    });
                }
            }
        }
    }];
}

//网络请求更多数据
- (IBAction)moreClick:(id)sender {
    
}
- (IBAction)changeNicknameClick:(id)sender {
    UIStoryboard * sb = [UIStoryboard storyboardWithName:@"Address" bundle:nil];
    NameViewController * nameVC = [sb instantiateViewControllerWithIdentifier:@"NameViewController"];
    nameVC.friendDelegate = self;
    nameVC.friendId = self.friendId;
    nameVC.name = @"备注";
    nameVC.titleCount = 1;
    [self.navigationController pushViewController:nameVC animated:YES];

}
//发送消息
- (IBAction)sendMessage:(id)sender {
    
    ChatDetailController * chat = [[ChatDetailController alloc]initWithConversationType:ConversationType_PRIVATE targetId:self.friendId];
    chat.conversationType = ConversationType_PRIVATE;
    chat.targetId = self.friendId;
    //会话人备注
    chat.title = self.display;
    [self.navigationController pushViewController:chat animated:YES];
}
#pragma mark- 解决scrollView的屏幕适配
-(void)viewWillLayoutSubviews{
    
    [super viewWillLayoutSubviews];
    
    self.widthContraints.constant = KMainScreenWidth+5;
    if ((self.sendView.frame.origin.y+75)<KMainScreenHeight) {
        self.scrollView.scrollEnabled = NO;
    }else{
        self.scrollView.scrollEnabled = YES;
        
    }
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = YES;
    self.displayNameLabel.text = self.display;

}
@end