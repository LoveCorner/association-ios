//
//  DataSource.m
//  CommunityProject
//
//  Created by bjike on 17/3/17.
//  Copyright © 2017年 来自任性傲娇的女王. All rights reserved.
//

#import "DataSource.h"

@implementation DataSource
-(NSArray *)getApplictionData{
    
    NSDictionary * dic1 = @{@"name":@"干货分享",@"imageName":@"share.png"};
    
    NSDictionary * dic2 = @{@"name":@"灵感贩卖",@"imageName":@"sell.png"};
    
    NSDictionary * dic3 = @{@"name":@"认领中心",@"imageName":@"claimCenter.png"};
    
    NSDictionary * dic4 = @{@"name":@"直播中心",@"imageName":@"seedCenter.png"};
    
    NSDictionary * dic5 = @{@"name":@"联盟打车",@"imageName":@"taxi.png"};
    
    NSDictionary * dic6 = @{@"name":@"导航",@"imageName":@"navigition.png"};
    
    NSDictionary * dic7 = @{@"name":@"三分钟教学",@"imageName":@"train.png"};
    
    NSDictionary * dic8 = @{@"name":@"天气中心",@"imageName":@"train.png"};
    
    NSDictionary * dic9 = @{@"name":@"游戏",@"imageName":@"train.png"};
    
    NSDictionary * dic10 = @{@"name":@"一元夺宝",@"imageName":@"train.png"};
    
    NSDictionary * dic11 = @{@"name":@"众筹",@"imageName":@"train.png"};
    NSDictionary * dic12 = @{@"name":@"平台活动",@"imageName":@"train.png"};
    NSDictionary * dic13 = @{@"name":@"公益活动",@"imageName":@"train.png"};
    NSDictionary * dic14 = @{@"name":@"联盟司机",@"imageName":@"train.png"};
    NSArray * arr = @[dic1,dic2,dic3,dic4,dic5,dic6,dic7,dic8,dic9,dic10,dic11,dic12,dic13,dic14];
    return arr;
}
@end