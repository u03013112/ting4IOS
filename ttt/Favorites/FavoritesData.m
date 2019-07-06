//
//  FavoritesData.m
//  ttt
//
//  Created by 宋志京 on 2019/7/6.
//  Copyright © 2019 宋志京. All rights reserved.
//

#import "FavoritesData.h"

@implementation FavoritesData

-(id)init{
    if (self = [super init]){
        self.data = [[NSMutableArray alloc]init];
        self.delegateArray = [[NSMutableArray alloc]init];
    }
    return self;
}

-(void)addFav:(NSString*)title Sound:(NSString*)sound Mod:(NSString*)mod Url:(NSString*)url{
    NSMutableDictionary *cd = [[NSMutableDictionary alloc]init];
    if (title==nil){
        return;
    }
    [cd setObject:title forKey:@"title"];
    [cd setObject:sound forKey:@"sound"];
    [cd setObject:mod forKey:@"mod"];
    [cd setObject:url forKey:@"url"];
    
    [self.data addObject:cd];
    [self save];
    for (id<FavoritesDataDelegate> delegate in self.delegateArray) {
        [delegate didFavoritesDataChanged];
    }
}

-(void)delFav:(NSString*)url{
    for (NSMutableDictionary *cd in self.data) {
        if ([[cd objectForKey:@"url"]isEqualToString:url]){
            [[self data]removeObject:cd];
            break;
        }
    }
    [self save];
    for (id<FavoritesDataDelegate> delegate in self.delegateArray) {
        [delegate didFavoritesDataChanged];
    }
}

-(void)save{
    [[NSUserDefaults standardUserDefaults]setObject:self.data forKey:@"fav"];
    [[NSUserDefaults standardUserDefaults]synchronize];
}
-(void)load{
     NSMutableArray *a = [[NSUserDefaults standardUserDefaults]objectForKey:@"fav"];
    if (a!=nil){
        self.data = [[NSMutableArray alloc]initWithArray:a];
    }
}

-(void)addDelegate:(id<FavoritesDataDelegate>) delegate{
    [self.delegateArray addObject:delegate];
}
-(void)removeDelegate:(id<FavoritesDataDelegate>) delegate{
    [self.delegateArray removeObject:delegate];
}

@end

