//
//  NameViewController.h
//  CommunityProject
//
//  Created by bjike on 17/3/25.
//  Copyright © 2017年 来自任性傲娇的女王. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FriendDetailController.h"

@interface NameViewController : UIViewController
//标题
@property (nonatomic,copy)NSString * name;
//1:个人昵称2：群昵称3：群名字
@property (nonatomic,assign)int titleCount;
//好友ID
@property (nonatomic,copy)NSString * friendId;
//群ID
@property (nonatomic,copy)NSString * groupId;

@property (nonatomic,assign)FriendDetailController * friendDelegate;


@end