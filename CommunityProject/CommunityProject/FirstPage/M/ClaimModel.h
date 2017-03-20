//
//  ClaimModel.h
//  CommunityProject
//
//  Created by bjike on 17/3/16.
//  Copyright © 2017年 来自任性傲娇的女王. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@interface ClaimModel : JSONModel
//推荐ID
@property (nonatomic,copy) NSString * recommendId;
//真实名字
@property (nonatomic,copy) NSString * fullName;
//昵称
@property (nonatomic,copy) NSString * nickname;
//编号
@property (nonatomic,copy) NSString * numberId;
//头像
@property (nonatomic,copy) NSString * userPortraitUrl;
//推荐人编号
@property (nonatomic,copy) NSString * claimNumberId;
//推荐人昵称
@property (nonatomic,copy) NSString * claimNickName;
//推荐真实姓名
@property (nonatomic,copy) NSString * claimFullName;


@end
