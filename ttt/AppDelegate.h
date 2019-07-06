//
//  AppDelegate.h
//  ttt
//
//  Created by 宋志京 on 2019/6/6.
//  Copyright © 2019年 宋志京. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Player/Player.h"
#import "UsrData.h"
#import "Favorites/FavoritesData.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong,nonatomic) Player *player;
@property (strong,nonatomic) UsrData *usrData;
@property (strong,nonatomic) FavoritesData *favData;
+ (AppDelegate *)getInstance;
@end

