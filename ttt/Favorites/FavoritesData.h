//
//  FavoritesData.h
//  ttt
//
//  Created by 宋志京 on 2019/7/6.
//  Copyright © 2019 宋志京. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol FavoritesDataDelegate <NSObject>
@optional
-(void)didFavoritesDataChanged;
@end

@interface FavoritesData : NSObject

@property (strong)NSMutableArray *data;
//KEY：@"tile" @"sound" @"mod" @"url"

@property (strong)NSMutableArray *delegateArray;

-(void)addFav:(NSString*)title Sound:(NSString*)sound Mod:(NSString*)mod Url:(NSString*)url;
-(void)delFav:(NSString*)url;

-(void)save;
-(void)load;

-(void)addDelegate:(id<FavoritesDataDelegate>) delegate;
-(void)removeDelegate:(id<FavoritesDataDelegate>) delegate;

@end


NS_ASSUME_NONNULL_END
