//
//  FriendsListModel.h
//  LoveChatProject
//
//  Created by bjike on 17/1/18.
//  Copyright © 2017年 来自任性傲娇的女王. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FriendsListModel : JSONModel

@property (nonatomic,copy)NSString * userId;
//昵称
@property (nonatomic,copy)NSString * name;
//头像
@property (nonatomic,copy)NSString * userPortraitUrl;
//备注
@property (nonatomic,copy)NSString * displayName;
//电话
@property (nonatomic,copy)NSString * mobile;
//邮箱
@property (nonatomic,copy)NSString * email;
@end