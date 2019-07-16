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

-(void)setCurrentIndexForAlbumUrl:(NSString*)url index:(int)index{
    for (NSDictionary *d in self.data) {
        if ([[d objectForKey:@"url"] isEqualToString:url]){
            int oldIndex = [[d objectForKey:@"currentIndex"]intValue];
            if (oldIndex != index){
                NSMutableDictionary *md = [[NSMutableDictionary alloc]initWithDictionary:d];
                [md setObject:[NSNumber numberWithInteger:index] forKey:@"currentIndex"];
                [self.data replaceObjectAtIndex:[self.data indexOfObject:d] withObject:md];
                [self save];
                for (id<FavoritesDataDelegate> delegate in self.delegateArray) {
                    [delegate didFavoritesDataChanged];
                }
            }
            break;
        }
    }
}
-(int)getCurrentIndexForAlbumUrl:(NSString*)url{
    //TODO:
    return 0;
}

-(void)setTotalCountForAlbumUrl:(NSString*)url count:(NSUInteger)count{
    for (NSDictionary *d in self.data) {
        if ([[d objectForKey:@"url"] isEqualToString:url]){
            NSUInteger oldCount = [[d objectForKey:@"totalCount"]unsignedIntegerValue];
            if (oldCount != count){
                NSMutableDictionary *md = [[NSMutableDictionary alloc]initWithDictionary:d];
                [md setObject:[NSNumber numberWithUnsignedInteger:count] forKey:@"totalCount"];
                [self.data replaceObjectAtIndex:[self.data indexOfObject:d] withObject:md];
                [self save];
                for (id<FavoritesDataDelegate> delegate in self.delegateArray) {
                    [delegate didFavoritesDataChanged];
                }
            }
            break;
        }
    }
}
-(int)getTotalCountForAlbumUrl:(NSString*)url{
    //TODO:
    return 0;
}

@end

