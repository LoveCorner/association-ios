//
//  MyHelpListController.m
//  CommunityProject
//
//  Created by bjike on 2017/7/3.
//  Copyright © 2017年 来自任性傲娇的女王. All rights reserved.
//

#import "MyHelpListController.h"
#import "MyHelpAndAnswerCell.h"
#import "MyHelpListModel.h"
#import "HelpDetailController.h"

#define MyHelpURL @"appapi/app/mySeekHelp"

@interface MyHelpListController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UISegmentedControl *segControll;
@property (nonatomic,strong)NSMutableArray * dataArr;


@end

@implementation MyHelpListController
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = YES;
    self.navigationController.navigationBar.hidden = YES;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    WeakSelf;
    /*
     self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
     weakSelf.page ++;
     [weakSelf getEducationListData];
     }];
     */
    self.tableView.mj_footer.hidden = YES;
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        //        weakSelf.page = 1;
        if (self.segControll.selectedSegmentIndex == 0) {
            //我的求助
            [weakSelf getMyHelpData:@"1"];
            
        }else{
            //我的回答
            [weakSelf getMyHelpData:@"0"];
            
        }
    }];
    [self netWork];


}
-(void)netWork{
    NSInteger status = [[RCIMClient sharedRCIMClient]getCurrentNetworkStatus];
    if (status == 0) {
        //无网从本地加载数据
        [self showMessage:@"亲，没有连接网络哦！"];
    }else{
        WeakSelf;
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            [weakSelf getMyHelpData:@"1"];
        });
        
    }
    
}
-(void)getMyHelpData:(NSString *)status{
    WeakSelf;
    NSDictionary * params = @{@"userId":self.userId,@"status":status};
    [AFNetData postDataWithUrl:[NSString stringWithFormat:NetURL,MyHelpURL] andParams:params returnBlock:^(NSURLResponse *response, NSError *error, id data) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        });
        if (error) {
            NSSLog(@"我的求助：%@",error);
            [weakSelf showMessage:@"服务器出错咯！"];
            if (weakSelf.tableView.mj_header.isRefreshing) {
                [weakSelf.tableView.mj_header endRefreshing];
            }
//            if (weakSelf.tableView.mj_footer.isRefreshing) {
//                [weakSelf.tableView.mj_footer endRefreshing];
//            }
        }else{
            if (!weakSelf.tableView.mj_footer.isRefreshing) {
                [weakSelf.dataArr removeAllObjects];
            }
            NSNumber * code = data[@"code"];
            if ([code intValue] == 200) {
                NSArray * arr = data[@"data"];
//                if (arr.count == 0) {
//                    [weakSelf.tableView.mj_footer endRefreshingWithNoMoreData];
//                }else{
                    for (NSDictionary * dic in arr) {
                        MyHelpListModel * list = [[MyHelpListModel alloc]initWithDictionary:dic error:nil];
                        [weakSelf.dataArr addObject:list];
                    }
//                }
            }else{
                [weakSelf showMessage:@"加载我的求助失败，下拉刷新重试！"];
            }
            [weakSelf.tableView reloadData];
            [weakSelf.tableView.mj_header endRefreshing];
//            [weakSelf.tableView.mj_footer endRefreshing];
            
        }
    }];
}
#pragma mark - tableView-delegate and DataSources
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MyHelpAndAnswerCell * cell = [tableView dequeueReusableCellWithIdentifier:@"MyHelpAndAnswerCell"];
    cell.helpModel = self.dataArr[indexPath.row];
    return cell;
    
    
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return self.dataArr.count;
    
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}


- (IBAction)backClick:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)segClick:(id)sender {
    
    [self.dataArr removeAllObjects];
    [self.tableView reloadData];
    if (self.segControll.selectedSegmentIndex == 0) {
        //我的求助
        [self getMyHelpData:@"1"];
        
    }else{
        //我的回答
        [self getMyHelpData:@"0"];
        
    }
}
-(void)showMessage:(NSString *)msg{
    UIView * msgView = [UIView showViewTitle:msg];
    [self.view addSubview:msgView];
    [UIView animateWithDuration:1.0 animations:^{
        msgView.frame = CGRectMake(20, KMainScreenHeight-150, KMainScreenWidth-40, 50);
    } completion:^(BOOL finished) {
        //完成之后3秒消失
        [NSTimer scheduledTimerWithTimeInterval:2.0 repeats:NO block:^(NSTimer * _Nonnull timer) {
            msgView.hidden = YES;
        }];
    }];
    
}
-(NSMutableArray *)dataArr{
    if (!_dataArr) {
        _dataArr = [NSMutableArray new];
    }
    return _dataArr;
}

@end