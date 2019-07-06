//
//  PlayerData.m
//  ttt
//
//  Created by 宋志京 on 2019/6/9.
//  Copyright © 2019 宋志京. All rights reserved.
//

#import "PlayerData.h"
#import "../AppDelegate.h"

@interface PlayerData()<AlbumDataDelegate>

@property (strong,nonatomic) NSString *currentUrl;
@property (strong,nonatomic) NSString *nextUrl;
@property BOOL isReady;

@end

@implementation PlayerData
static PlayerData *instance = nil;
+(PlayerData*) getInstance{
    if(instance == nil){
        instance = [[PlayerData alloc]init];
        instance.albumData = nil;
        instance.isReady = YES;
    }
    return instance;
}

-(NSString*)getCurrentAlbumName{
    if([self albumData]!=nil){
        return [[self albumData]name];
    }
    return @"";
}

-(NSString*)getCurrentSongName{
    if([self albumData]!=nil){
        if ([self.albumData.url isEqualToString:[[[AppDelegate getInstance]usrData] currentAlbumURL]]==NO){
            return @"";
        }
        long sIndex = [[AppDelegate getInstance].usrData getCurrentSongIndex];
        NSDictionary *soundInfo = [[self albumData]sounds][sIndex];
        return [soundInfo objectForKey:@"title"];
    }
    return @"";
}

-(void)getSongUrl:(NSString*)mod URL:(NSString*)url Index:(long)index FromBegain:(BOOL) isFromBegain{
    if (self.isReady == NO){
        return;
    }else{
        self.isReady = NO;
    }
    self.nextUrl = nil;
    
    NSURL *u = [NSURL URLWithString:@"http://frp.u03013112.win:18004/getmp3url"];
    NSMutableURLRequest *mutableRequest = [NSMutableURLRequest requestWithURL:u];
    
    NSDictionary *head = [[NSDictionary alloc]initWithObjectsAndKeys:@"application/json",@"Content-Type", nil];
    NSMutableDictionary *postBodyDict = [[NSMutableDictionary alloc]init];
    [postBodyDict setObject:mod forKey:@"mod"];
    [postBodyDict setObject:url forKey:@"url"];
    [postBodyDict setObject:[NSNumber numberWithInteger:index] forKey:@"index"];
    NSData *postData = [NSJSONSerialization dataWithJSONObject:postBodyDict options:NSJSONWritingPrettyPrinted error:nil];
    
    [mutableRequest setHTTPMethod:@"POST"];
    [mutableRequest setHTTPBody:postData];
    [mutableRequest setAllHTTPHeaderFields:head];
    
    NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:mutableRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        self.isReady = YES;
        if (error == nil) {
            NSError *error;
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
            if (error !=nil){
                NSLog(@"%@",error);
                // 手机网络有问题，或者服务器挂了，拼命重试
                [self getSongUrl:mod URL:url Index:index FromBegain:isFromBegain];
                return ;
            }
            if([[dict objectForKey:@"error"] isEqual:@"timeout"]){
                NSLog(@"timeout");
                //服务器连不上听书网了，重试到死
                [self getSongUrl:mod URL:url Index:index FromBegain:isFromBegain];
                return ;
            }
            if([[dict objectForKey:@"error"] isEqual:@"over"]){
                NSLog(@"timeout");
                //索引错了
                return ;
            }
            NSString *songUrl = [dict objectForKey:@"url"];
            NSLog(@"%@",songUrl);
            self.currentUrl = songUrl;
            
            UsrData *usrData = [AppDelegate getInstance].usrData;
            usrData.currentAlbumURL = url;
            usrData.mod = mod;
            [usrData setCurrentSongIndex:index];
            if (isFromBegain==YES){
                [usrData setCurrentSeekSec:0];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                //call player play this url,dont ask why
                [[[AppDelegate getInstance]player]playWithUrl:songUrl];
            });
            [self getNextSongUrl:mod URL:url Index:index];
        }
    }];
    [task resume];
}

//index 传入当前index，在这里面会+1的
-(void)getNextSongUrl:(NSString*)mod URL:(NSString*)url Index:(long)index{
    NSURL *u = [NSURL URLWithString:@"http://frp.u03013112.win:18004/getmp3url"];
    NSMutableURLRequest *mutableRequest = [NSMutableURLRequest requestWithURL:u];
    
    NSDictionary *head = [[NSDictionary alloc]initWithObjectsAndKeys:@"application/json",@"Content-Type", nil];
    NSMutableDictionary *postBodyDict = [[NSMutableDictionary alloc]init];
    
    [postBodyDict setObject:mod forKey:@"mod"];
    [postBodyDict setObject:url forKey:@"url"];
    [postBodyDict setObject:[NSNumber numberWithInteger:index+1] forKey:@"index"];
    
    NSData *postData = [NSJSONSerialization dataWithJSONObject:postBodyDict options:NSJSONWritingPrettyPrinted error:nil];
    
    [mutableRequest setHTTPMethod:@"POST"];
    [mutableRequest setHTTPBody:postData];
    [mutableRequest setAllHTTPHeaderFields:head];
    
    NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:mutableRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error == nil) {
            NSError *error;
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
            if (error !=nil){
                NSLog(@"%@",error);
//                下一首就不重试了
                return ;
            }
            if([[dict objectForKey:@"error"] isEqual:@"over"]){
                NSLog(@"over");
                self.nextUrl = nil;
                return ;
            }
            NSString *songUrl = [dict objectForKey:@"url"];
            
            NSLog(@"nextUrl:%@",dict);
            
            self.nextUrl = songUrl;
            dispatch_async(dispatch_get_main_queue(), ^{
                AVPlayerItem * item = [[AVPlayerItem alloc]initWithURL:[NSURL URLWithString:songUrl]];
                [[[AppDelegate getInstance]player].player2 replaceCurrentItemWithPlayerItem:item];
            });
        }
    }];
    [task resume];
}


-(NSString *)getNextSongUrl{
    return self.nextUrl;
}

- (void)didAlbumDataRecv:(AlbumData *)data {
    self.albumData = data;
}

@end
