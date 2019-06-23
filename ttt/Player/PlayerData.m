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
                return ;
            }
            if(![[dict objectForKey:@"error"] isEqual:@""]){
                NSLog(@"timeout");
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
            
//            for next
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
                        return ;
                    }
                    if(![[dict objectForKey:@"error"] isEqual:@""]){
                        NSLog(@"timeout");
                        return ;
                    }
                    NSString *songUrl = [dict objectForKey:@"url"];
                    NSLog(@"nextUrl:%@",songUrl);
                    self.nextUrl = songUrl;
                }
            }];
            [task resume];
        }
    }];
    
    [task resume];
}
- (void)didAlbumDataRecv:(AlbumData *)data {
    self.albumData = data;
}

@end
