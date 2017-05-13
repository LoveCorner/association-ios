//
//  ClaimInfoController.m
//  CommunityProject
//
//  Created by bjike on 17/5/12.
//  Copyright © 2017年 来自任性傲娇的女王. All rights reserved.
//

#import "ClaimInfoController.h"
#import "UIView+ChatMoreView.h"

#define ClaimURL @"appapi/app/claimUser"
@interface ClaimInfoController ()<UITextFieldDelegate,UIPickerViewDelegate,UIPickerViewDataSource>
@property (weak, nonatomic) IBOutlet UILabel *nicknameLabel;

@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property (weak, nonatomic) IBOutlet UITextField *nameLabel;
@property (weak, nonatomic) IBOutlet UITextField *phoneTF;
@property (weak, nonatomic) IBOutlet UIButton *manBtn;
@property (weak, nonatomic) IBOutlet UIButton *famaleBtn;

@property (weak, nonatomic) IBOutlet UIButton *danceBtn;

@property (weak, nonatomic) IBOutlet UIButton *musicBtn;

@property (weak, nonatomic) IBOutlet UIButton *printBtn;

@property (weak, nonatomic) IBOutlet UIButton *intrusmentBtn;

@property (weak, nonatomic) IBOutlet UIButton *gameBtn;
@property (weak, nonatomic) IBOutlet UIButton *movieBtn;

@property (weak, nonatomic) IBOutlet UIButton *foodBtn;

@property (weak, nonatomic) IBOutlet UIButton *chatBtn;

@property (weak, nonatomic) IBOutlet UIButton *travelBtn;

@property (weak, nonatomic) IBOutlet UIButton *readBtn;
@property (weak, nonatomic) IBOutlet UIButton *motionBtn;
@property (weak, nonatomic) IBOutlet UIButton *chessBtn;

@property (weak, nonatomic) IBOutlet UITextField *liveProTF;

@property (weak, nonatomic) IBOutlet UITextField *liveCityTF;

@property (weak, nonatomic) IBOutlet UITextField *liveDisTF;
@property (weak, nonatomic) IBOutlet UITextField *relationshipTF;

@property (weak, nonatomic) IBOutlet UITextField *presiTF;

@property (weak, nonatomic) IBOutlet UITextField *birthdayTF;


@property (weak, nonatomic) IBOutlet UITextField *schoolTF;
@property (weak, nonatomic) IBOutlet UITextField *degreeTF;

@property (weak, nonatomic) IBOutlet UITextField *companyTF;

@property (weak, nonatomic) IBOutlet UITextField *postTF;

@property (weak, nonatomic) IBOutlet UITextField *emailTF;
@property (weak, nonatomic) IBOutlet UITextField *qqTF;
@property (weak, nonatomic) IBOutlet UITextField *homeProTF;
@property (weak, nonatomic) IBOutlet UITextField *homeCityTF;
@property (weak, nonatomic) IBOutlet UITextField *homeDisTF;

@property (weak, nonatomic) IBOutlet UIButton *recomendBtn;

@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewWidthCons;
@property (weak, nonatomic) IBOutlet UITextField *wechatTF;


@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (nonatomic,copy)NSString * userId;
//生日
@property (nonatomic,copy)NSString * birthday;

//所有数据
@property (nonatomic,strong)NSArray *allArr;
//省份数据
@property (nonatomic,strong)NSMutableArray * provinceArr;
//城市数据
@property (nonatomic,strong)NSMutableArray * cityArr;
//区县数据
@property (nonatomic,strong)NSMutableArray * districtArr;
//索引
@property (nonatomic,assign)NSInteger proIndex;

@property (nonatomic,assign)NSInteger cityIndex;
@property (nonatomic,assign)NSInteger districtIndex;

@property (nonatomic,assign)NSInteger relationIndex;
@property (nonatomic,assign)NSInteger presiIndex;
//学历
@property (nonatomic,assign)NSInteger degreeIndex;
@property (nonatomic,strong)NSArray * degreeArr;

//关系
@property (nonatomic,strong)NSArray * relationshipArr;
//信誉
@property (nonatomic,strong)NSArray * presiCountArr;

//标记pickerView的数据源 1,2,3地址，4关系，5信誉分，6，7，8是籍贯,9,学历，10生日
@property (nonatomic,assign)int flag;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewHeightCons;

@property (nonatomic,strong) UIView * backView;
@property (nonatomic,strong)UIWindow * window;
//标记认领之后的状态
@property (nonatomic,assign)int claim;

@end

@implementation ClaimInfoController
-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    self.tabBarController.tabBar.hidden = YES;
    self.window = [[UIApplication sharedApplication].windows objectAtIndex:0];

}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"认领信息";
    UIBarButtonItem * leftItem = [UIBarButtonItem CreateTitleButtonWithFrame:CGRectMake(0, 0, 40, 30) titleColor:UIColorFromRGB(0x121212) font:15 andTitle:@"取消" andLeft:-15 andTarget:self Action:@selector(leftClick)];
    self.navigationItem.leftBarButtonItem = leftItem;
    self.userId = [DEFAULTS objectForKey:@"userId"];
    [self setUI];
}

-(void)setUI{
    self.headImageView.layer.cornerRadius = 5;
    self.headImageView.layer.masksToBounds = YES;
    [self.headImageView sd_setImageWithURL:[NSURL URLWithString:self.url] placeholderImage:[UIImage imageNamed:@"default.png"]];
    self.nameLabel.text = self.name;
    self.bottomView.hidden = YES;
    [self setTitleButton:self.danceBtn];
    [self setTitleButton:self.musicBtn];
    [self setTitleButton:self.printBtn];
    [self setTitleButton:self.intrusmentBtn];
    [self setTitleButton:self.gameBtn];
    [self setTitleButton:self.movieBtn];
    [self setTitleButton:self.travelBtn];
    [self setTitleButton:self.chessBtn];
    [self setTitleButton:self.foodBtn];
    [self setTitleButton:self.chatBtn];
    [self setTitleButton:self.readBtn];
    [self setTitleButton:self.motionBtn];
    
    [self.manBtn setBackgroundImage:[UIImage imageNamed:@"noSelBtn"] forState:UIControlStateNormal];
    [self.famaleBtn setBackgroundImage:[UIImage imageNamed:@"noSelBtn"] forState:UIControlStateNormal];
    [self.manBtn setBackgroundImage:[UIImage imageNamed:@"chooseSel"] forState:UIControlStateSelected];
    [self.famaleBtn setBackgroundImage:[UIImage imageNamed:@"chooseSel"] forState:UIControlStateSelected];
    self.liveProTF.layer.borderColor = UIColorFromRGB(0xECEEF0).CGColor;
    self.liveCityTF.layer.borderColor = UIColorFromRGB(0xECEEF0).CGColor;
    self.liveDisTF.layer.borderColor = UIColorFromRGB(0xECEEF0).CGColor;
    self.liveProTF.layer.borderWidth = 1;
    self.liveDisTF.layer.borderWidth = 1;
    self.liveCityTF.layer.borderWidth = 1;
    
    self.homeDisTF.layer.borderColor = UIColorFromRGB(0xECEEF0).CGColor;
    self.homeProTF.layer.borderColor = UIColorFromRGB(0xECEEF0).CGColor;
    self.homeCityTF.layer.borderColor = UIColorFromRGB(0xECEEF0).CGColor;
    self.homeCityTF.layer.borderWidth = 1;
    self.homeProTF.layer.borderWidth = 1;
    self.homeDisTF.layer.borderWidth = 1;
    //手势回收键盘
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(resign)];
    [self.view addGestureRecognizer:tap];
    
}
-(void)resign{
    self.view.frame = CGRectMake(0, 64, KMainScreenWidth, KMainScreenHeight);
    [self.nameLabel resignFirstResponder];
    [self.phoneTF resignFirstResponder];
    [self.schoolTF resignFirstResponder];
    [self.companyTF resignFirstResponder];
    [self.postTF resignFirstResponder];
    [self.emailTF resignFirstResponder];
    [self.qqTF resignFirstResponder];
    [self.wechatTF resignFirstResponder];

}
-(void)setTitleButton:(UIButton *)btn{
    [btn setBackgroundImage:[UIImage imageNamed:@"hobbyWhite"] forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage imageNamed:@"hobbyGreen"] forState:UIControlStateSelected];
    [btn setTitleColor:UIColorFromRGB(0x18bc8b) forState:UIControlStateNormal];
    [btn setTitleColor:UIColorFromRGB(0x11624a) forState:UIControlStateSelected];
    
}
-(void)leftClick{
    [self.navigationController popViewControllerAnimated:YES];
    
}
//认领
- (IBAction)recommendClick:(id)sender {
    [self resign];
    //提示必填项
    if (!self.manBtn.selected && !self.famaleBtn.selected) {
        return;
    }
    if (!self.danceBtn.selected && !self.musicBtn.selected&&!self.printBtn.selected && !self.intrusmentBtn.selected&&!self.gameBtn.selected && !self.movieBtn.selected&&!self.chessBtn.selected && !self.travelBtn.selected&&!self.foodBtn.selected && !self.chatBtn.selected&&!self.readBtn.selected && !self.motionBtn.selected) {
        return;
    }
    if (self.nameLabel.text.length == 0||self.phoneTF.text.length == 0 || self.liveProTF.text.length == 0||self.liveCityTF.text.length == 0||self.liveDisTF.text.length == 0 || self.relationshipTF.text.length == 0 || self.presiTF.text.length == 0) {
        return;
    }
    
    WeakSelf;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [weakSelf recommendSubmit];
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        });
    });
}
-(void)recommendSubmit{
    NSMutableDictionary * params = [NSMutableDictionary new];
    [params setValue:self.userId forKey:@"userId"];
    [params setValue:self.nameLabel.text forKey:@"fullName"];
    [params setValue:self.claimUserId forKey:@"claimUserId"];
    [params setValue:self.phoneTF.text forKey:@"mobile"];
    if (self.manBtn.selected) {
        [params setValue:@"1" forKey:@"sex"];
    }else if (self.famaleBtn.selected){
        [params setValue:@"2" forKey:@"sex"];
        
    }
    NSArray * arr = @[self.liveProTF.text,self.liveCityTF.text,self.liveDisTF.text,@"中国"];
    NSData * data = [NSJSONSerialization dataWithJSONObject:arr options:NSJSONWritingPrettyPrinted error:nil];
    NSString * result = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    
    [params setValue:result forKey:@"address"];
    NSMutableString * hobby = [NSMutableString new];
    if (self.danceBtn.selected) {
        [hobby appendString:@"舞蹈,"];
    }
    if (self.musicBtn.selected) {
        [hobby appendString:@"音乐,"];
    }
    if (self.printBtn.selected) {
        [hobby appendString:@"画画,"];
    }
    if (self.intrusmentBtn.selected) {
        [hobby appendString:@"乐器,"];
    }
    if (self.gameBtn.selected) {
        [hobby appendString:@"游戏,"];
    }
    if (self.movieBtn.selected) {
        [hobby appendString:@"影视,"];
    }
    if (self.travelBtn.selected) {
        [hobby appendString:@"旅游,"];
    }
    if (self.chessBtn.selected) {
        [hobby appendString:@"棋类,"];
    }
    if (self.foodBtn.selected) {
        [hobby appendString:@"美食,"];
    }
    if (self.chatBtn.selected) {
        [hobby appendString:@"社交,"];
    }
    if (self.readBtn.selected) {
        [hobby appendString:@"阅读,"];
    }
    if (self.motionBtn.selected) {
        [hobby appendString:@"运动,"];
    }
    
    [params setValue:hobby forKey:@"hobby"];
    NSString * relation ;
    if ([self.relationshipTF.text isEqualToString:@"亲人"]) {
        relation = @"1";
    }else if ([self.relationshipTF.text isEqualToString:@"同乡"]){
        relation = @"4";
        
    }else if ([self.relationshipTF.text isEqualToString:@"校友"]){
        relation = @"3";
        
    }else if ([self.relationshipTF.text isEqualToString:@"同事"]){
        relation = @"2";
        
    }
    [params setValue:self.presiTF.text forKey:@"creditScore"];

    [params setValue:relation forKey:@"relationship"];
    [params setValue:self.birthday forKey:@"birthday"];
    [params setValue:[NSString stringWithFormat:@"%@,%@,%@",self.homeProTF.text,self.homeCityTF.text,self.homeDisTF.text] forKey:@"homeplace"];

    [params setValue:self.schoolTF.text forKey:@"finishSchool"];
    
    NSString * degree;
    switch (self.degreeIndex) {
        case 0:
            degree = @"1";
            
            break;
        case 1:
            degree = @"2";
            
            break;
        case 2:
            degree = @"3";
            
            break;
        case 3:
            degree = @"4";
            
            break;
        case 4:
            degree = @"5";
            
            break;
        case 5:
            degree = @"6";
            
            break;
        case 6:
            degree = @"7";
            
            break;
        case 7:
            degree = @"8";
            
            break;
        case 8:
            degree = @"9";
            
            break;
        case 9:
            degree = @"10";
            
            break;
        default:
            degree = @"11";
            
            break;
    }
    [params setValue:degree forKey:@"degree"];
    [params setValue:self.companyTF.text forKey:@"company"];
    [params setValue:self.postTF.text forKey:@"position"];
    [params setValue:self.emailTF.text forKey:@"email"];
    [params setValue:self.qqTF.text forKey:@"QQ"];
    [params setValue:self.wechatTF.text forKey:@"wechat"];

    
    WeakSelf;
    [AFNetData postDataWithUrl:[NSString stringWithFormat:NetURL,ClaimURL] andParams:params returnBlock:^(NSURLResponse *response, NSError *error, id data) {
        if (error) {
            NSSLog(@"认领人请求失败：%@",error);
            weakSelf.claim = 5;
            [weakSelf showBackViewUI:@"服务器出问题咯！"];

        }else{
            NSNumber * code = data[@"code"];
            if ([code intValue] == 200) {
                weakSelf.claim = 2;
                [weakSelf showBackViewUI:@"认领成功"];
            }else if ([code intValue] == 100){
                //已认领
                weakSelf.claim = 1;
                [weakSelf showBackViewUI:@"已认领，不要重复提交"];
            }else if ([code intValue] == 101){
                //认领已回答，等待对方审核
                weakSelf.claim = 4;
                [weakSelf showBackViewUI:@"认领已回答，等待对方审核"];

            }else if ([code intValue] == 300){
                //等待对方审核
                weakSelf.claim = 3;
                [weakSelf showBackViewUI:@"等待对方审核"];

            }else{
                NSSLog(@"失败");
                weakSelf.claim = 0;
                [weakSelf showBackViewUI:@"未知原因，认领失败"];
            }
            
        }
    }];
    
}
-(void)showBackViewUI:(NSString *)msg{
    
    self.backView = [UIView sureViewTitle:msg andTag:120 andTarget:self andAction:@selector(buttonAction:)];
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideViewAction)];
    
    [self.backView addGestureRecognizer:tap];
    
    [self.window addSubview:self.backView];
    [self.backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(-64);
        make.left.equalTo(self.view);
        make.width.mas_equalTo(KMainScreenWidth);
        make.height.mas_equalTo(KMainScreenHeight);
    }];
}
-(void)buttonAction:(UIButton *)btn{
    [self hideViewAction];
    if (btn.tag == 120) {
        switch (self.claim) {
            case 0://失败

                break;
            case 1://已认领
                [self leftClick];
                break;
            case 2://成功返回上页
                [self leftClick];
                break;
            case 3://等待对方审核
                [self leftClick];

                break;
            case 4://等待审核
                [self leftClick];
                break;
            default://服务器或者网络

                break;
        }
    }
}
-(void)hideViewAction{
    self.backView.hidden = YES;
}
- (IBAction)manClick:(id)sender {
    self.manBtn.selected = !self.manBtn.selected;
    if (self.manBtn.selected) {
        self.famaleBtn.selected = NO;
    }
}
- (IBAction)famaleClick:(id)sender {
    self.famaleBtn.selected = !self.famaleBtn.selected;
    if (self.famaleBtn.selected) {
        self.manBtn.selected = NO;
    }
}
- (IBAction)danceClick:(id)sender {
    self.danceBtn.selected = !self.danceBtn.selected;
    
}

- (IBAction)musicClick:(id)sender {
    self.musicBtn.selected = !self.musicBtn.selected;
    
}

- (IBAction)printClick:(id)sender {
    self.printBtn.selected = !self.printBtn.selected;
    
}

- (IBAction)instrumentClick:(id)sender {
    self.intrusmentBtn.selected = !self.intrusmentBtn.selected;
    
}

- (IBAction)gameClick:(id)sender {
    self.gameBtn.selected = !self.gameBtn.selected;
    
}

- (IBAction)movieClick:(id)sender {
    self.movieBtn.selected = !self.movieBtn.selected;
    
}

- (IBAction)foodClick:(id)sender {
    self.foodBtn.selected = !self.foodBtn.selected;
}

- (IBAction)chatClick:(id)sender {
    self.chatBtn.selected = !self.chatBtn.selected;
    
}
- (IBAction)travelClick:(id)sender {
    self.travelBtn.selected = !self.travelBtn.selected;
    
}

- (IBAction)readClick:(id)sender {
    self.readBtn.selected = !self.readBtn.selected;
    
}

- (IBAction)motionClick:(id)sender {
    self.motionBtn.selected = !self.motionBtn.selected;
    
}
- (IBAction)chessClick:(id)sender {
    self.chessBtn.selected = !self.chessBtn.selected;
    
}

#pragma mark-textField-Delegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (textField == self.nameLabel) {
        [self.nameLabel resignFirstResponder];
        [self.phoneTF becomeFirstResponder];
    }else if (textField == self.phoneTF){
        [self.phoneTF resignFirstResponder];
        [self.schoolTF becomeFirstResponder];
    }else if (textField == self.schoolTF){
        [self.schoolTF resignFirstResponder];
        [self.companyTF becomeFirstResponder];
    }else if (textField == self.companyTF){
        [self.companyTF resignFirstResponder];
        [self.postTF becomeFirstResponder];
    }else if (textField == self.postTF){
        [self.postTF resignFirstResponder];
        [self.emailTF becomeFirstResponder];
    }else if (textField == self.emailTF){
        [self.emailTF resignFirstResponder];
        [self.qqTF becomeFirstResponder];
    }else if (textField == self.qqTF){
        [self.qqTF resignFirstResponder];
        [self.wechatTF becomeFirstResponder];
    }else{
        [self resign];
        
    }
    return YES;
}
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if (textField == self.postTF||textField == self.emailTF ||textField == self.qqTF||textField == self.wechatTF){
        self.bottomView.hidden = YES;
        CGFloat offset = textField.frame.origin.y+50-(KMainScreenHeight-216);
        self.view.frame = CGRectMake(0, -offset-64, KMainScreenWidth, KMainScreenHeight+offset+64);
        return YES;
        
    }
    else if (textField == self.liveProTF||textField == self.liveCityTF||textField == self.liveDisTF||textField == self.relationshipTF||textField == self.presiTF||textField == self.homeProTF||textField == self.homeCityTF||textField == self.homeDisTF||textField == self.degreeTF){
        [self resign];
        if (textField == self.liveProTF) {
            [self hidden];
            self.flag = 1;
            [self getAllData];
        }else if (textField == self.liveCityTF){
            if (self.liveProTF.text.length != 0) {
                [self hidden];
                self.flag = 2;
                for (NSDictionary *dict in self.allArr) {
                    if ([dict objectForKey:self.provinceArr[self.proIndex]]) {
                        self.cityArr = [NSMutableArray arrayWithArray:[[dict objectForKey:self.provinceArr[self.proIndex]] allKeys]];
                        break;
                    }
                }
            }
        }else if(textField == self.liveDisTF){
            if (self.liveCityTF.text.length != 0) {
                [self hidden];
                self.flag = 3;
                for (NSDictionary *dict in self.allArr) {
                    
                    if ([dict objectForKey:self.provinceArr[self.proIndex]]) {
                        self.districtArr = [NSMutableArray arrayWithArray:[[dict objectForKey:self.provinceArr[self.proIndex]] objectForKey:self.cityArr[self.cityIndex]]];
                        break;
                        
                    }
                    
                }
            }
        }else  if (textField == self.homeProTF) {
            [self hidden];
            self.flag = 6;
            [self getAllData];
        }else if (textField == self.homeCityTF){
            if (self.homeProTF.text.length != 0) {
                [self hidden];
                self.flag = 7;
                for (NSDictionary *dict in self.allArr) {
                    
                    if ([dict objectForKey:self.provinceArr[self.proIndex]]) {
                        self.cityArr = [NSMutableArray arrayWithArray:[[dict objectForKey:self.provinceArr[self.proIndex]] allKeys]];
                        break;
                    }
                }
            }
        }else if(textField == self.homeDisTF){
            if (self.homeCityTF.text.length != 0) {
                [self hidden];
                self.flag = 8;
                for (NSDictionary *dict in self.allArr) {
                    
                    if ([dict objectForKey:self.provinceArr[self.proIndex]]) {
                        self.districtArr = [NSMutableArray arrayWithArray:[[dict objectForKey:self.provinceArr[self.proIndex]] objectForKey:self.cityArr[self.cityIndex]]];
                        break;
                    }
                }
            }
        }else if (textField == self.relationshipTF){
            [self hidden];
            self.flag = 4;
            self.relationshipArr = @[@"亲人",@"同事",@"校友",@"同乡"];
        }else if (textField == self.presiTF){
            [self hidden];
            self.flag = 5;
            //信誉分
            self.presiCountArr = @[@"0",@"10",@"20",@"30",@"40",@"50",@"60",@"70",@"80",@"90",@"100"];
        }else if (textField == self.degreeTF){
            [self hidden];
            self.flag = 9;
            self.degreeArr = @[@"初中",@"高中",@"中技",@"中专",@"大专",@"本科",@"硕士",@"博士",@"MBA",@"EMBA",@"其他"];

        }
        [self.pickerView reloadComponent:0];
        [self.pickerView selectRow:0 inComponent:0 animated:YES];
        if ([self.pickerView.delegate respondsToSelector:@selector(pickerView:didSelectRow:inComponent:)]) {
            [self.pickerView.delegate pickerView:self.pickerView didSelectRow:0 inComponent:0];
        }
        return NO;
    }else if (textField == self.birthdayTF){
        [self resign];
        self.bottomView.hidden = NO;
        self.pickerView.hidden = YES;
        self.datePicker.hidden = NO;
        self.flag = 10;
        return NO;
    }
    else{
        self.bottomView.hidden = YES;
        return YES;
    }
}
-(void)hidden{
    self.bottomView.hidden = NO;
    self.datePicker.hidden = YES;
    self.pickerView.hidden = NO;
}
- (IBAction)datePickerClick:(id)sender {
    [self common];
    
}
-(void)common{
    NSString * time = [NowDate getTime:self.datePicker.date];
    NSArray * arr = [time componentsSeparatedByString:@"-"];
    self.birthdayTF.text = [NSString stringWithFormat:@"%@年%@月%@日",arr[0],arr[1],arr[2]];
    self.birthday = time;
}
-(void)getAllData{
    self.allArr = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Address" ofType:@"plist"]];
    for (NSDictionary *dci in self.allArr) {
        [self.provinceArr addObject:[[dci allKeys] firstObject]];
    }
}
- (IBAction)finishClick:(id)sender {
    switch (self.flag) {
        case 1:
            self.liveProTF.text = self.provinceArr[self.proIndex];
            
            break;
        case 2:
            self.liveCityTF.text = self.cityArr[self.cityIndex];
            
            break;
        case 3:
            self.liveDisTF.text = self.districtArr[self.districtIndex];
            
            break;
        case 4:
            //关系
            self.relationshipTF.text = self.relationshipArr[self.relationIndex];
            break;
        case 5:
            //信誉分
            self.presiTF.text = self.presiCountArr[self.presiIndex];
            break;
        case 6:
            self.homeProTF.text = self.provinceArr[self.proIndex];
            
            break;
        case 7:
            self.homeCityTF.text = self.cityArr[self.cityIndex];
            
            break;
        case 8:
            self.homeDisTF.text = self.districtArr[self.districtIndex];
            
            break;
        case 9:
            self.degreeTF.text = self.degreeArr[self.degreeIndex];
            
            break;
        default:
            //生日
            [self common];
            break;
    }
    self.bottomView.hidden = YES;
    
}
#pragma mark - pickerView-delegate and DataSources
-(UIView*)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    UILabel* pickerLabel = (UILabel*)view;
    if (!pickerLabel) {
        pickerLabel = [UILabel new];
        pickerLabel.textAlignment = NSTextAlignmentCenter;
        [pickerLabel setFont:[UIFont boldSystemFontOfSize:15]];
        pickerLabel.textColor = UIColorFromRGB(0x333333);
        pickerLabel.text=[self pickerView:pickerView titleForRow:row forComponent:component];
    }
    //去除线条
    [[pickerView.subviews objectAtIndex:1]setHidden:true];
    [[pickerView.subviews objectAtIndex:2]setHidden:true];
    return pickerLabel;
}
//返回组件高度
-(CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
    
    return 45;
}
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    //改变选择时的颜色
    UILabel * label = (UILabel *)[pickerView viewForRow:row forComponent:0];
    label.backgroundColor = [UIColor whiteColor];
    switch (self.flag) {
        case 1:
        {
            self.proIndex = row;
            self.cityIndex = 0;
            self.districtIndex = 0;
            
        }
            break;
        case 2:
        {
            self.cityIndex = row;
            self.districtIndex = 0;
            
        }
            break;
        case 3:
        {
            self.districtIndex = row;
        }
            break;
        case 4:
        {
            self.relationIndex = row;
        }
            break;
        case 5:
        {
            self.presiIndex = row;
        }
            break;
        case 6:
        {
            self.proIndex = row;
            self.cityIndex = 0;
            self.districtIndex = 0;
        }
            break;
        case 7:
        {
            self.cityIndex = row;
            self.districtIndex = 0;
        }
            break;
        case 8:
        {
            self.districtIndex = row;

        }
            break;
        default:
            //学历
            self.degreeIndex = row;
            break;
    }
    
}
-(NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    switch (self.flag) {
        case 1:
            return [self.provinceArr objectAtIndex:row];
            
            break;
        case 2:
            return [self.cityArr objectAtIndex:row];
            
            break;
        case 3:
            return [self.districtArr objectAtIndex:row];
            
            break;
        case 4:
            return [self.relationshipArr objectAtIndex:row];
            
            break;
        case 5:
            return [self.presiCountArr objectAtIndex:row];
            
            break;
        case 6:
            return [self.provinceArr objectAtIndex:row];
            
            break;
        case 7:
            return [self.cityArr objectAtIndex:row];
            
            break;
        case 8:
            return [self.districtArr objectAtIndex:row];
            
            break;
   
        default:
            return [self.degreeArr objectAtIndex:row];

            break;
    }
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    switch (self.flag) {
        case 1:
            return self.provinceArr.count;
            
            break;
        case 2:
            return self.cityArr.count;
            
            break;
        case 3:
            return self.districtArr.count;
            
            break;
        case 4:
            return self.relationshipArr.count;
            
            break;
        case 5:
            return self.presiCountArr.count;
            
            break;
        case 6:
            return self.provinceArr.count;
            
            break;
        case 7:
            return self.cityArr.count;
            
            break;
        case 8:
            return self.districtArr.count;
            
            break;
        default:
            return self.degreeArr.count;

            break;
    }
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

//解决scrollView的屏幕适配
-(void)viewWillLayoutSubviews{
    
    [super viewWillLayoutSubviews];
    self.viewWidthCons.constant = KMainScreenWidth;
}
-(NSMutableArray *)provinceArr{
    if (!_provinceArr) {
        _provinceArr = [NSMutableArray new];
    }
    return _provinceArr;
}
-(NSMutableArray *)cityArr{
    if (!_cityArr) {
        _cityArr = [NSMutableArray new];
    }
    return _cityArr;
}
-(NSMutableArray *)districtArr{
    if (!_districtArr) {
        _districtArr = [NSMutableArray new];
    }
    return _districtArr;
}

@end