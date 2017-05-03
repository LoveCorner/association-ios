//
//  SignInViewController.m
//  CommunityProject
//
//  Created by bjike on 17/5/3.
//  Copyright © 2017年 来自任性傲娇的女王. All rights reserved.
//

#import "SignInViewController.h"
#import "FSCalendar.h"
#import "UIView+ChatMoreView.h"

#define HistorySignURL @"appapi/app/signDate"
#define SignInURL @"appapi/app/sign"

@interface SignInViewController ()<FSCalendarDelegate,FSCalendarDataSource,FSCalendarDelegateAppearance>
@property (weak, nonatomic) IBOutlet FSCalendar *calendarView;

@property (weak, nonatomic) IBOutlet UIButton *signInBtn;

@property (strong, nonatomic) NSCalendar *gregorian;
//当前用户
@property (nonatomic,copy)NSString * userId;
//签到的日期
@property (nonatomic,strong)NSDictionary * dateArr;
//保存当天签到的日期
@property (nonatomic,assign)BOOL isToday;

@property (nonatomic,strong) UIView * backView;
@property (nonatomic,strong)UIWindow * window;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *calendarHeightCons;

@end

@implementation SignInViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.userId = [DEFAULTS objectForKey:@"userId"];
    self.navigationItem.title = @"签到";
    UIBarButtonItem * backItem = [UIBarButtonItem CreateTitleButtonWithFrame:CGRectMake(0, 0, 40, 30) titleColor:UIColorFromRGB(0x10DB9F) font:16 andTitle:@"返回" andLeft:-15 andTarget:self Action:@selector(backClick)];
    self.navigationItem.leftBarButtonItem = backItem;
    self.gregorian = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    //头的字体和颜色
    self.calendarView.appearance.headerTitleFont = [UIFont boldSystemFontOfSize:15];
    self.calendarView.appearance.headerTitleColor = UIColorFromRGB(0x333333);
    //周的 颜色和字体
    self.calendarView.appearance.weekdayFont = [UIFont boldSystemFontOfSize:14];
    self.calendarView.appearance.weekdayTextColor = UIColorFromRGB(0x666666);
   
    //天数的字体
    self.calendarView.appearance.titleFont = [UIFont systemFontOfSize:14];
    //没有选中字体颜色
    self.calendarView.appearance.titleDefaultColor = UIColorFromRGB(0x444343);
    //选中是字体颜色
    self.calendarView.appearance.titleSelectionColor = UIColorFromRGB(0x444343);
    //当天字体颜色
    self.calendarView.appearance.titleTodayColor = UIColorFromRGB(0x444343);
    //不是当前月的字体颜色
//    self.calendarView.appearance.titlePlaceholderColor = UIColorFromRGB(0x999999);
   
    //当天圆的背景色
    self.calendarView.appearance.todayColor = UIColorFromRGB(0xffffff);
    self.calendarView.appearance.todaySelectionColor = UIColorFromRGB(0x10DB9F);

    //选中线条颜色
    self.calendarView.appearance.borderSelectionColor = UIColorFromRGB(0x10DB9F);
    //选中时圆的背景色
    self.calendarView.appearance.selectionColor = UIColorFromRGB(0x10DB9F);

    //没选中的圆的线条颜色
//    self.calendarView.appearance.borderDefaultColor = UIColorFromRGB(0xffffff);
    //选中的小点的颜色 小点
    self.calendarView.appearance.eventSelectionColor = UIColorFromRGB(0xffffff);
    //未选择的小点默认圆颜色
    self.calendarView.appearance.eventDefaultColor = UIColorFromRGB(0xffffff);
   
    //设置圆
    self.calendarView.appearance.borderRadius = 1;
    //设置日历周的风格
    self.calendarView.appearance.caseOptions = FSCalendarCaseOptionsWeekdayUsesSingleUpperCase;
    //隐藏两侧
    self.calendarView.appearance.headerMinimumDissolvedAlpha = 0.0;
    //月的格式
    self.calendarView.appearance.headerDateFormat = @"yyyy.MM";
    //隐藏线条
    self.calendarView.clipsToBounds = YES;
    //设置不显示上下月的日期
    self.calendarView.placeholderType = FSCalendarPlaceholderTypeNone;
    //设置月的高度
    self.calendarView.headerHeight = 52;
    self.signInBtn.layer.masksToBounds = YES;
    self.signInBtn.layer.cornerRadius = 5;
    [self getEventDateData];

}
-(void)getEventDateData{
    NSMutableDictionary * param = [NSMutableDictionary new];
    WeakSelf;
    [AFNetData postDataWithUrl:[NSString stringWithFormat:NetURL,HistorySignURL] andParams:@{@"userId":self.userId} returnBlock:^(NSURLResponse *response, NSError *error, id data) {
        if (error) {
            NSSLog(@"签到日期请求失败：%@",error);
        }else{
            NSNumber * code = data[@"code"];
            if ([code intValue] == 200) {
                NSArray * arr = data[@"data"];
                for (NSString * date in arr) {
                    [param setValue:UIColorFromRGB(0x10DB9F) forKey:date];
                }
                //2017-05-03
                weakSelf.dateArr = param;
//                [weakSelf.calendarView reloadData];
                NSSLog(@"%@",weakSelf.dateArr);
                }
            
        }
    }];
}
-(void)backClick{
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)signInClick:(id)sender {
    if (self.isToday) {
        [self signIn];
    }
}
-(void)signIn{
    WeakSelf;
    [AFNetData postDataWithUrl:[NSString stringWithFormat:NetURL,SignInURL] andParams:@{@"userId":self.userId} returnBlock:^(NSURLResponse *response, NSError *error, id data) {
        if (error) {
            NSSLog(@"签到请求失败：%@",error);
        }else{
            NSNumber * code = data[@"code"];
            if ([code intValue] == 200) {
                NSDictionary * dict = data[@"data"];
                [weakSelf showBackViewUI:[NSString stringWithFormat:@"连续签到%@天，奖励%@贡献值",dict[@"days"],dict[@"experience"]]];

            }
            
        }
    }];
}
-(void)showBackViewUI:(NSString *)title{
    
    self.backView = [UIView sureViewTitle:title andTag:80 andTarget:self andAction:@selector(buttonAction:)];
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
}
-(void)hideViewAction{
    self.backView.hidden = YES;
}
//选中日历事件==签到
-(void)calendar:(FSCalendar *)calendar didSelectDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)monthPosition{
    //只有当天可以签到
    self.isToday = [self.gregorian isDateInToday:date];
}
//事件显示圆的线条颜色
- (UIColor *)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance borderDefaultColorForDate:(NSDate *)date
{
     NSString * key = [NowDate getTime:date];
    NSSLog(@"%@",self.dateArr.allKeys);
    if ([self.dateArr.allKeys containsObject:key]) {
        return self.dateArr[key];
    }
    return UIColorFromRGB(0xffffff);
    
}
- (IBAction)lastMonthClick:(id)sender {
    NSDate *currentMonth = self.calendarView.currentPage;
    NSDate *previousMonth = [self.gregorian dateByAddingUnit:NSCalendarUnitMonth value:-1 toDate:currentMonth options:0];
    [self.calendarView setCurrentPage:previousMonth animated:YES];
}

- (IBAction)nextMonthClick:(id)sender {
    NSDate *currentMonth = self.calendarView.currentPage;
    NSDate *nextMonth = [self.gregorian dateByAddingUnit:NSCalendarUnitMonth value:1 toDate:currentMonth options:0];
    [self.calendarView setCurrentPage:nextMonth animated:YES];
}
- (void)calendar:(FSCalendar *)calendar boundingRectWillChange:(CGRect)bounds animated:(BOOL)animated
{
    self.calendarHeightCons.constant = CGRectGetHeight(bounds);
    // Do other updates here
    [self.view layoutIfNeeded];
}

-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    self.tabBarController.tabBar.hidden = YES;
    self.window = [[UIApplication sharedApplication].windows objectAtIndex:0];

}
@end