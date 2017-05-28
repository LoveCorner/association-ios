//
//  PubicDetailController.m
//  CommunityProject
//
//  Created by bjike on 17/5/24.
//  Copyright © 2017年 来自任性傲娇的女王. All rights reserved.
//

#import "PubicDetailController.h"
#import "JoinUserModel.h"
#import "HeadDetailCell.h"
#import "MemberListController.h"
#import "PlatformCommentController.h"

#define PublicDetailURL @"appapi/app/commonwealActivesInfo"
#define ZanURL @"appapi/app/userPraise"
#define SignURL @"appapi/app/commonwealActivesJoin"
@interface PubicDetailController ()
@property (weak, nonatomic) IBOutlet UIImageView *actImageView;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@property (weak, nonatomic) IBOutlet UILabel *areaLabel;

@property (weak, nonatomic) IBOutlet UILabel *peopleCountLabel;


@property (weak, nonatomic) IBOutlet UILabel *moneyLabel;
@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (weak, nonatomic) IBOutlet UILabel *signPeopleLabel;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;
@property (weak, nonatomic) IBOutlet UIButton *loveBtn;
@property (weak, nonatomic) IBOutlet UIButton *signBtn;
@property (weak, nonatomic) IBOutlet UIButton *commentBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewWidthCons;
@property (nonatomic,strong)NSString * userId;
@property (weak, nonatomic) IBOutlet UIView *backView;
@property (weak, nonatomic) IBOutlet UITextField *nameTF;

@property (weak, nonatomic) IBOutlet UITextField *phoneTF;
@property (weak, nonatomic) IBOutlet UITextField *wechatTF;
@property (weak, nonatomic) IBOutlet UITextField *companyTF;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomCons;
@property (nonatomic,strong)NSMutableArray * collectArr;
@property (nonatomic,strong)NSString * likes;

@end

@implementation PubicDetailController
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = YES;
    self.navigationController.navigationBar.hidden = YES;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.userId = [DEFAULTS objectForKey:@"userId"];
    self.backView.hidden = YES;
    self.backView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
    self.nameTF.layer.borderColor = UIColorFromRGB(0xECEEF0).CGColor;
    self.phoneTF.layer.borderColor = UIColorFromRGB(0xECEEF0).CGColor;
    self.wechatTF.layer.borderColor = UIColorFromRGB(0xECEEF0).CGColor;
    self.companyTF.layer.borderColor = UIColorFromRGB(0xECEEF0).CGColor;
    self.nameTF.layer.borderWidth = 1;
    self.phoneTF.layer.borderWidth = 1;
    self.wechatTF.layer.borderWidth = 1;
    self.companyTF.layer.borderWidth = 1;
    
    [self.signBtn setBackgroundImage:[UIImage imageNamed:@"voteBtn"] forState:UIControlStateNormal];
    [self.signBtn setBackgroundImage:[UIImage imageNamed:@"voteStop"] forState:UIControlStateDisabled];
    [self.signBtn setTitle:@"立即报名" forState:UIControlStateNormal];
    [self.signBtn setTitle:@"已报名" forState:UIControlStateDisabled];
    [self.signBtn setTitleColor:UIColorFromRGB(0x444343) forState:UIControlStateNormal];
    [self.signBtn setTitleColor:UIColorFromRGB(0x444343) forState:UIControlStateDisabled];
    [self.loveBtn setImage:[UIImage imageNamed:@"darkHeart"] forState:UIControlStateNormal];
    [self.loveBtn setImage:[UIImage imageNamed:@"heart"] forState:UIControlStateSelected];
    [self.collectionView registerNib:[UINib nibWithNibName:@"HeadDetailCell" bundle:nil] forCellWithReuseIdentifier:@"PublicUsersCell"];
    //手势恢复视图frame
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction)];
    [self.backView addGestureRecognizer:tap];
    WeakSelf;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [weakSelf getActivityDetailData];
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        });
    });
    

}
-(void)tapAction{
    [self resign];
}
-(void)getActivityDetailData{
    NSDictionary * params = @{@"userId":self.userId,@"activesId":self.idStr};
    WeakSelf;
    [AFNetData postDataWithUrl:[NSString stringWithFormat:NetURL,PublicDetailURL] andParams:params returnBlock:^(NSURLResponse *response, NSError *error, id data) {
        if (error) {
            NSSLog(@"公益数据请求失败：%@",error);
        }else{
            NSNumber * code = data[@"code"];
            if ([code intValue] == 200) {
                NSDictionary * dict = data[@"data"];
                weakSelf.titleLabel.text = [NSString stringWithFormat:@"%@",dict[@"title"]];
                weakSelf.areaLabel.text = [NSString stringWithFormat:@"地点：%@",dict[@"address"]];
                [weakSelf.actImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:NetURL,[ImageUrl changeUrl:dict[@"activesImage"]]]] placeholderImage:[UIImage imageNamed:@"banner2"]];
                weakSelf.timeLabel.text = [NSString stringWithFormat:@"时间：%@~%@",dict[@"startingTime"],dict[@"endTime"]];
                weakSelf.moneyLabel.text = [NSString stringWithFormat:@"报名费：¥%@/人",dict[@"costMoney"]];
                weakSelf.detailLabel.text = [NSString stringWithFormat:@"%@",dict[@"content"]];
                NSInteger  status = [dict[@"joinStatus"] integerValue];
                if (status == 0) {
                    weakSelf.signBtn.enabled = YES;
                }else{
                    weakSelf.signBtn.enabled = NO;
                }
                weakSelf.peopleCountLabel.text = [NSString stringWithFormat:@"已报名：%@人/无限制",dict[@"joinUsersNumber"]];
                //signPeopleLabel
                weakSelf.signPeopleLabel.text = [NSString stringWithFormat:@"已报名：（%@）",dict[@"joinUsersNumber"]];
                NSInteger  likeStatus = [dict[@"likesStatus"] integerValue];
                if (likeStatus == 0) {
                    weakSelf.loveBtn.selected = NO;
                }else{
                    weakSelf.loveBtn.selected = YES;
                }
//                if (dict[@"likes"] == nil) {
//                    [weakSelf.loveBtn setTitle:@"" forState:UIControlStateNormal];
//                }else{
//                    [weakSelf.loveBtn setTitle:[NSString stringWithFormat:@"%@",dict[@"likes"]] forState:UIControlStateNormal];
//                    weakSelf.likes = [NSString stringWithFormat:@"%@",dict[@"likes"]];
//                }
//                if (dict[@"commentNumber"] == nil) {
//                    [weakSelf.commentBtn setTitle:@"" forState:UIControlStateNormal];
//                }else{
//                    [weakSelf.commentBtn setTitle:[NSString stringWithFormat:@"%@",dict[@"commentNumber"]] forState:UIControlStateNormal];
//                }
                NSArray * users = dict[@"joinUsers"];
                if (users.count != 0) {
                    for (NSDictionary * subDic in users) {
                        JoinUserModel * user = [[JoinUserModel alloc]initWithDictionary:subDic error:nil];
                        [weakSelf.collectArr addObject:user];
                    }
                    [weakSelf.collectionView reloadData];
                }
            }else{
                NSSLog(@"请求公益活动数据失败");
            }
        }
    }];
    
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (textField == self.nameTF) {
        [self.nameTF resignFirstResponder];
        [self.phoneTF becomeFirstResponder];
    }else if (textField == self.phoneTF){
        [self.phoneTF resignFirstResponder];
        [self.wechatTF becomeFirstResponder];
    }else if (textField == self.wechatTF){
        [self.wechatTF resignFirstResponder];
        [self.companyTF becomeFirstResponder];
    }else{
        [self resign];
    }
    return YES;
}
-(void)resign{
    [self.nameTF resignFirstResponder];
    [self.phoneTF resignFirstResponder];
    [self.wechatTF resignFirstResponder];
    [self.companyTF resignFirstResponder];
    self.bottomCons.constant = 0;
    
}
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    CGFloat offset = KMainScreenHeight+20-348+textField.frame.origin.y+60-(KMainScreenHeight-216);
    if (offset >= 0) {
        self.bottomCons.constant = offset;
    }
    return YES;
}
#pragma mark - collectionView的代理方法
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    NSInteger count = (KMainScreenWidth-8)/62;
    if (self.collectArr.count<=count) {
        return self.collectArr.count;
    }else{
        return count;
    }
}
-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    HeadDetailCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PublicUsersCell" forIndexPath:indexPath];
    cell.userModel = self.collectArr[indexPath.row];
    return cell;
    
}
//更多
- (IBAction)moreClick:(id)sender {
    if (self.collectArr.count != 0) {
        UIStoryboard * sb = [UIStoryboard storyboardWithName:@"Group" bundle:nil];
        MemberListController * mem = [sb instantiateViewControllerWithIdentifier:@"MemberListController"];
        mem.userId = self.userId;
        mem.collectArr = self.collectArr;
        mem.isManager = 3;
        mem.name = [NSString stringWithFormat:@"已报名(%ld)",(unsigned long)self.collectArr.count];
        [self.navigationController pushViewController:mem animated:YES];
        
    }
}

- (IBAction)backClick:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
//分享
- (IBAction)shareClick:(id)sender {
    
}
//点赞
- (IBAction)loveClick:(id)sender {
    self.loveBtn.selected = !self.loveBtn.selected;
    NSDictionary * params = @{@"userId":self.userId,@"articleId":self.idStr,@"type":@"7",@"status":self.loveBtn.selected?@"1":@"0"};
    WeakSelf;
    [AFNetData postDataWithUrl:[NSString stringWithFormat:NetURL,ZanURL] andParams:params returnBlock:^(NSURLResponse *response, NSError *error, id data) {
        if (error) {
            NSSLog(@"公益点赞失败：%@",error);
            weakSelf.loveBtn.selected = NO;
        }else{
            
            NSNumber * code = data[@"code"];
            if ([code intValue] == 200) {
                if (self.loveBtn.selected) {
                    self.likes = [NSString stringWithFormat:@"%ld",[self.likes integerValue]+1];
                }else{
                    self.likes = [NSString stringWithFormat:@"%ld",[self.likes integerValue]-1];
                }
                [weakSelf.loveBtn setTitle:self.likes forState:UIControlStateNormal];
                
            }else if ([code intValue] == 100){
                weakSelf.loveBtn.selected = NO;
                
            }else if ([code intValue] == 101){
                weakSelf.loveBtn.selected = NO;
            }
        }
        
    }];
}
//评论
- (IBAction)commentClick:(id)sender {
    UIStoryboard * sb = [UIStoryboard storyboardWithName:@"Activity" bundle:nil];
    PlatformCommentController * comment = [sb instantiateViewControllerWithIdentifier:@"PlatformCommentController"];
    comment.idStr = self.idStr;
    comment.type = 7;
    comment.headUrl = self.headUrl;
    comment.content = self.titleName;
    [self.navigationController pushViewController:comment animated:YES];
}
//报名
- (IBAction)signClick:(id)sender {
    self.backView.hidden = NO;

}
//确定报名
- (IBAction)sureSignClick:(id)sender {
    //提示用户要填写完整
    if (self.nameTF.text.length == 0) {
        return;
    }
    if (self.phoneTF.text.length == 0) {
        return;
    }
    if (self.wechatTF.text.length == 0) {
        return;
    }
    if (self.companyTF.text.length == 0) {
        return;
    }
    NSMutableDictionary * mDic = [NSMutableDictionary new];
    [mDic setValue:self.userId forKey:@"userId"];
    [mDic setValue:self.idStr forKey:@"activesId"];
    [mDic setValue:self.nameTF.text forKey:@"userName"];
    [mDic setValue:self.phoneTF.text forKey:@"mobile"];
    [mDic setValue:self.wechatTF.text forKey:@"wechat"];
    [mDic setValue:self.companyTF.text forKey:@"company"];
    WeakSelf;
    [AFNetData postDataWithUrl:[NSString stringWithFormat:NetURL,SignURL] andParams:mDic returnBlock:^(NSURLResponse *response, NSError *error, id data) {
        if (error) {
            NSSLog(@"平台报名失败：%@",error);
            weakSelf.signBtn.enabled = YES;
            NSSLog(@"报名失败");
        }else{
            
            NSNumber * code = data[@"code"];
            if ([code intValue] == 200) {
                weakSelf.backView.hidden = YES;
                weakSelf.signBtn.enabled = NO;
            }else if ([code intValue] == 100){
                NSSLog(@"已报名");
            }else if ([code intValue] == 101){
                NSSLog(@"报名失败");
                weakSelf.signBtn.enabled = YES;
            }else{
                NSSLog(@"报名失败");
                weakSelf.signBtn.enabled = YES;
            }
        }
        
    }];
}

- (IBAction)closeClick:(id)sender {
    self.backView.hidden = YES;
}

-(NSMutableArray *)collectArr{
    if (!_collectArr) {
        _collectArr = [NSMutableArray new];
    }
    return _collectArr;
}
//解决scrollView的屏幕适配
-(void)viewWillLayoutSubviews{
    
    [super viewWillLayoutSubviews];
    //    if (KMainScreenWidth == 375) {
    //        self.viewWidthCons.constant = KMainScreenWidth+5;
    //    }else{
    self.viewWidthCons.constant = KMainScreenWidth;
    
    //    }
    
}
@end
