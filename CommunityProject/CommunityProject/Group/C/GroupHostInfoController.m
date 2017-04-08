//
//  GroupHostInfoController.m
//  CommunityProject
//
//  Created by bjike on 17/3/29.
//  Copyright © 2017年 来自任性傲娇的女王. All rights reserved.
//

#import "GroupHostInfoController.h"
#import "MemberListCell.h"
#import "MemberListModel.h"
#import "GroupMessageController.h"
#import "NameViewController.h"
#import "MemberListController.h"
#import "GroupNoticeViewController.h"
#import "ChatMainController.h"
#import "ManageGroupViewController.h"

#define MemberURL @"appapi/app/groupMember"
#define DissolveURL @"appapi/app/dissolutionGroup"
@interface GroupHostInfoController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UILabel *groupNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *publicNoticeLabel;
@property (weak, nonatomic) IBOutlet UILabel *groupIdLabel;
@property (weak, nonatomic) IBOutlet UIButton *msgBtn;
@property (weak, nonatomic) IBOutlet UIButton *topBtn;
@property (weak, nonatomic) IBOutlet UILabel *nicknameLabel;
@property (nonatomic,strong)NSMutableArray * dataArr;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *widthContraints;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightConraints;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *collHeightContraints;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *smallViewHeightCons;

@property (weak, nonatomic) IBOutlet UIButton *dissolveBtn;

@end

@implementation GroupHostInfoController
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = YES;
    self.groupNameLabel.text = [NSString stringWithFormat:@"%@",self.groupName];
    self.publicNoticeLabel.text = [NSString stringWithFormat:@"%@",self.publicNotice];
    self.nicknameLabel.text = [NSString stringWithFormat:@"%@",self.nickname];
    if (self.isRef) {
        [self getMemberList];
    }

}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"群信息";
    UIBarButtonItem * leftItem = [UIBarButtonItem CreateBackButtonWithFrame:CGRectMake(0, 0,50, 40) andTitle:@"返回" andTarget:self Action:@selector(leftClick)];
    self.navigationItem.leftBarButtonItem = leftItem;
    [self setUI];
    [self getMemberList];
    if (self.isHost) {
        [self.dissolveBtn setTitle:@"解散本群" forState:UIControlStateNormal];
    }else{
        [self.dissolveBtn setTitle:@"退出该群" forState:UIControlStateNormal];
    }
}
-(void)setUI{
    //注册cell
    [self.collectionView registerNib:[UINib nibWithNibName:@"MemberListCell" bundle:nil] forCellWithReuseIdentifier:@"MemberListCell"];
    self.groupIdLabel.text = self.groupId;
    [self.topBtn setBackgroundImage:[UIImage imageNamed:@"switchOff.png"] forState:UIControlStateNormal];
    [self.topBtn setBackgroundImage:[UIImage imageNamed:@"switchOn.png"] forState:UIControlStateSelected];
    [self.msgBtn setBackgroundImage:[UIImage imageNamed:@"switchOff.png"] forState:UIControlStateNormal];
    [self.msgBtn setBackgroundImage:[UIImage imageNamed:@"switchOn.png"] forState:UIControlStateSelected];
    self.userId = [DEFAULTS objectForKey:@"userId"];
    BOOL isTop = [DEFAULTS boolForKey:@"topGroupOne"];
    self.topBtn.selected = isTop;
    //设置按钮状态
    WeakSelf;
    [[RCIMClient sharedRCIMClient]getConversationNotificationStatus:ConversationType_GROUP targetId:self.groupId success:^(RCConversationNotificationStatus nStatus) {
        //免打扰
        if (nStatus == 0) {
            weakSelf.msgBtn.selected = YES;
        }else{
            //消息提醒
            weakSelf.msgBtn.selected = NO;
        }
    } error:^(RCErrorCode status) {
        NSSLog(@"%ld",(long)status);
    }];
}
-(void)leftClick{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)getMemberList{
    NSDictionary * dict = @{@"groupId":self.groupId,@"userId":self.userId};
    [AFNetData postDataWithUrl:[NSString stringWithFormat:NetURL,MemberURL] andParams:dict returnBlock:^(NSURLResponse *response, NSError *error, id data) {
        if (error) {
            NSSLog(@"获取群成员失败%@",error);
        }else{
            if (self.dataArr.count !=0) {
                [self.dataArr removeAllObjects];
            }
            NSNumber * code = data[@"code"];
            if ([code intValue] == 200) {
                NSArray * array = data[@"data"];
                for (NSDictionary * dic in array) {
                    MemberListModel * member = [[MemberListModel alloc]initWithDictionary:dic error:nil];
                    [self.dataArr addObject:member];
                    RCUserInfo * userInfo = [[RCUserInfo alloc]initWithUserId:member.userId name:member.userName portrait:[NSString stringWithFormat:NetURL,[ImageUrl changeUrl:member.userPortraitUrl]]];
                    //刷新群组成员的信息
                    [[RCIM sharedRCIM] refreshUserInfoCache:userInfo withUserId:member.userId];
                }
                [self.collectionView reloadData];
            }
            
        }
    }];
}
#pragma mark - collectionView的代理方法
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    NSInteger shu = KMainScreenWidth/85;
    NSInteger row = self.dataArr.count/shu;
    NSInteger remainder = self.dataArr.count%shu;
    if ((row=3 && remainder==0)||(row<3)) {
        return self.dataArr.count;
    }else{
        return shu*3;
    }
}
-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    MemberListCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MemberListCell" forIndexPath:indexPath];
    cell.listModel = self.dataArr[indexPath.row];
    return cell;
}
//群名
- (IBAction)groupNameClick:(id)sender {
    UIStoryboard * sb = [UIStoryboard storyboardWithName:@"Address" bundle:nil];
    NameViewController * nameVC = [sb instantiateViewControllerWithIdentifier:@"NameViewController"];
    nameVC.hostDelegate = self;
    nameVC.groupId = self.groupId;
    nameVC.name = @"群名称";
    nameVC.titleCount = 3;
    nameVC.placeHolder = @"设置群名称";
    nameVC.content = self.groupName;
    nameVC.headUrl = self.headUrl;
    nameVC.isChangeGroupName = YES;
    [self.navigationController pushViewController:nameVC animated:YES];

}

//群公告
- (IBAction)publicNoticeClick:(id)sender {
    UIStoryboard * sb = [UIStoryboard storyboardWithName:@"Group" bundle:nil];
    GroupNoticeViewController * notice = [sb instantiateViewControllerWithIdentifier:@"GroupNoticeViewController"];
    notice.hostDelegate = self;
    notice.groupId = self.groupId;
    notice.publicNotice = self.publicNotice;
    notice.isHost = YES;
    notice.hostId = self.userId;
    [self.navigationController pushViewController:notice animated:YES];

}
//群管理
- (IBAction)manageClick:(id)sender {
    UIStoryboard * sb = [UIStoryboard storyboardWithName:@"Group" bundle:nil];
    ManageGroupViewController * manager = [sb instantiateViewControllerWithIdentifier:@"ManageGroupViewController"];
    manager.groupId = self.groupId;
    manager.hostId = self.hostId;
    [self.navigationController pushViewController:manager animated:YES];
}
//进群申请
- (IBAction)comeInGroupClick:(id)sender {
    UIStoryboard * sb = [UIStoryboard storyboardWithName:@"Group" bundle:nil];
    GroupMessageController * message = [sb instantiateViewControllerWithIdentifier:@"GroupMessageController"];
    message.groupId = self.groupId;
    message.groupName = self.groupName;
    [self.navigationController pushViewController:message animated:YES];

}
//群昵称
- (IBAction)ninknameClick:(id)sender {
    
    UIStoryboard * sb = [UIStoryboard storyboardWithName:@"Address" bundle:nil];
    NameViewController * nameVC = [sb instantiateViewControllerWithIdentifier:@"NameViewController"];
    nameVC.hostDelegate = self;
    nameVC.groupId = self.groupId;
    nameVC.name = @"备注";
    nameVC.titleCount = 2;
    nameVC.placeHolder = @"设置备注";
    nameVC.content = self.nickname;
    [self.navigationController pushViewController:nameVC animated:YES];

}
//消息免打扰
- (IBAction)messageClick:(id)sender {
    self.msgBtn.selected = !self.msgBtn.selected;
    [self setMessage:self.msgBtn.selected];
}
-(void)setMessage:(BOOL)isBlocked{
    WeakSelf;
    [[RCIMClient sharedRCIMClient]setConversationNotificationStatus:ConversationType_GROUP targetId:self.groupId isBlocked:isBlocked success:^(RCConversationNotificationStatus nStatus) {
        //免打扰
        if (nStatus == 0) {
            weakSelf.msgBtn.selected = YES;
        }else{
            //消息提醒
            weakSelf.msgBtn.selected = NO;
        }
    } error:^(RCErrorCode status) {
        NSSLog(@"状态码：%ld",(long)status);
    }];
}
//置顶聊天
- (IBAction)topClick:(id)sender {
    self.topBtn.selected = !self.topBtn.selected;
    [[RCIMClient sharedRCIMClient]setConversationToTop:ConversationType_GROUP targetId:self.groupId isTop:self.topBtn.selected];
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:self.topBtn.selected forKey:@"topGroupOne"];
    [userDefaults synchronize];
}
//更多成员
- (IBAction)moreMemberClick:(id)sender {
    UIStoryboard * sb = [UIStoryboard storyboardWithName:@"Group" bundle:nil];
    MemberListController * mem = [sb instantiateViewControllerWithIdentifier:@"MemberListController"];
    mem.groupId = self.groupId;
    mem.userId = self.userId;
    mem.collectArr = self.dataArr;
    mem.groupName = self.groupName;
    mem.groupUrl = self.headUrl;
    mem.isManager = YES;
    //管理员ID
    mem.hostId = self.userId;
    mem.delegate = self;
    [self.navigationController pushViewController:mem animated:YES];
}
//解散群
- (IBAction)dissolveClick:(id)sender {
    NSString * str ;
    if (self.isHost) {
        str = @"确定要解散此群吗？";
    }else{
        str = @"确定要退出本群吗？";
    }
    WeakSelf;
    [MessageAlertView alertViewWithTitle:str message:nil buttonTitle:@[@"取消",@"确定"] Action:^(NSInteger indexpath) {
        if (indexpath == 1) {
            [weakSelf dismissGroup];
        }
    } viewController:self];
}
-(void)dismissGroup{
    WeakSelf;
    RCGroup * group = [[RCGroup alloc]initWithGroupId:self.groupId groupName:self.groupName portraitUri:self.headUrl];
    [AFNetData postDataWithUrl:[NSString stringWithFormat:NetURL,DissolveURL] andParams:@{@"groupId":self.groupId,@"groupUser":self.userId} returnBlock:^(NSURLResponse *response, NSError *error, id data) {
        if (error) {
            NSSLog(@"解散群或退群失败%@",error);
        }else{
            NSNumber * code = data[@"code"];
            if ([code intValue] == 200 ||[code intValue] == 100) {
                //解散群成功 刷新SDK
//                删除会话
                [[RCIMClient sharedRCIMClient]removeConversation:ConversationType_GROUP targetId:weakSelf.groupId];
                [[RCIM sharedRCIM]refreshGroupInfoCache:group withGroupId:weakSelf.groupId];
                dispatch_async(dispatch_get_main_queue(), ^{
                    for (UIViewController* vc in weakSelf.navigationController.viewControllers) {
                        
                        if ([vc isKindOfClass:[ChatMainController class]]) {
                            
                            [weakSelf.navigationController popToViewController:vc animated:YES];
                        }
                    }
                });

            }
        }
    }];
}
-(NSMutableArray *)dataArr{
    if (!_dataArr) {
        _dataArr = [NSMutableArray new];
    }
    return _dataArr;
}
#pragma mark- 解决scrollView的屏幕适配
-(void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    self.widthContraints.constant = KMainScreenWidth+5;
     NSInteger width = self.dataArr.count*70;
     int count = width/KMainScreenWidth;
     NSInteger remainder = width%(NSInteger)KMainScreenWidth;
     //一行coll
     if ((count==0 && remainder !=0)|| (count==1 && remainder==0)) {
     self.collHeightContraints.constant = 85;
     self.smallViewHeightCons.constant = 125;
     self.heightConraints.constant = 712;
     }else if ((count==2 && remainder ==0)|| (count==1 && remainder!=0)) {
     //2行
     self.collHeightContraints.constant = 170;
     self.smallViewHeightCons.constant = 210;
     self.heightConraints.constant = 797;
     }else if((count==3)|| (count==2 && remainder!=0)){
     //3行
     self.collHeightContraints.constant = 255;
     self.smallViewHeightCons.constant = 295;
     self.heightConraints.constant = 882;
     }
        if (self.heightConraints.constant<KMainScreenHeight) {
            self.scrollView.scrollEnabled = NO;
        }else{
            self.scrollView.scrollEnabled = YES;
        }

}
@end