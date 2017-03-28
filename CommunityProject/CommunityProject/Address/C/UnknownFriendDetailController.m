//
//  UnknownFriendDetailController.m
//  CommunityProject
//
//  Created by bjike on 17/3/25.
//  Copyright © 2017年 来自任性傲娇的女王. All rights reserved.
//

#import "UnknownFriendDetailController.h"
#import "AddFriendController.h"

@interface UnknownFriendDetailController ()
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

@property (weak, nonatomic) IBOutlet UIButton *addFriendBtn;
@property (weak, nonatomic) IBOutlet UIView *moreView;
@property (weak, nonatomic) IBOutlet UIView *addFriendView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UILabel *moreLabel;
@property (weak, nonatomic) IBOutlet UIImageView *moreImage;

@end

@implementation UnknownFriendDetailController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setBar];
    [self setUI];

}
-(void)setBar{
    self.navigationItem.title = @"详细资料";
    UIBarButtonItem * leftItem = [UIBarButtonItem CreateBackButtonWithFrame:CGRectMake(0, 0,50, 40) andTitle:@"返回" andTarget:self Action:@selector(leftClick)];
    self.navigationItem.leftBarButtonItem = leftItem;
}
-(void)leftClick{
    [self.navigationController popViewControllerAnimated:YES];
}
//初始化传参过来的数据
-(void)setUI{
    self.headImageView.layer.cornerRadius = 5;
    self.headImageView.layer.masksToBounds = YES;
    if (self.isRegister) {
        [self.headImageView sd_setImageWithURL:[NSURL URLWithString:self.url]];
        self.moreImage.hidden = NO;
        self.moreLabel.hidden = NO;
        self.moreView.backgroundColor = UIColorFromRGB(0xffffff);
        [self.addFriendBtn setTitle:@"加为好友" forState:UIControlStateNormal];
    }else{
        [self.headImageView setImage:[UIImage imageNamed:@"default.png"]];
        self.moreImage.hidden = YES;
        self.moreLabel.hidden = YES;
        self.moreView.backgroundColor = UIColorFromRGB(0xECEEF0);
        [self.addFriendBtn setTitle:@"推荐好友" forState:UIControlStateNormal];

    }
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
    if (self.birthday.length == 0) {
        self.birthdayLabel.text = @"生日：";
    }else{
        self.birthdayLabel.text = [NSString stringWithFormat:@"生日：%@",self.birthday];
    }
    if (self.prestige.length == 0) {
        self.prestigeLabel.text = @"信誉值：";
    }else{
        self.prestigeLabel.text = [NSString stringWithFormat:@"信誉值：%@",self.prestige];
    }
    if (self.areaStr.length == 0) {
        self.areaLabel.text = @"地址：";
    }else{
        self.areaLabel.text = [NSString stringWithFormat:@"地址：%@",self.areaStr];
    }
}
#pragma mark- 解决scrollView的屏幕适配
-(void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    self.widthContraints.constant = KMainScreenWidth+5;
    if ((self.addFriendView.frame.origin.y+75)<KMainScreenHeight) {
        self.scrollView.scrollEnabled = NO;
    }else{
        self.scrollView.scrollEnabled = YES;
    }
}
//更多
- (IBAction)moreClick:(id)sender {
    
}
//推荐好友或者加为好友
- (IBAction)addClick:(id)sender {
    if (self.isRegister) {
        //加好友
        UIStoryboard * sb = [UIStoryboard storyboardWithName:@"Address" bundle:nil];
        AddFriendController * add = [sb instantiateViewControllerWithIdentifier:@"AddFriendController"];
        add.friendId = self.friendId;
        add.buttonName = @"确认添加好友";
        [self.navigationController pushViewController:add animated:YES];
    }else{
       //推荐好友
        
    }
}

@end
