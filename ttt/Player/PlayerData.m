//
//  PlayerData.m
//  ttt
//
//  Created by 宋志京 on 2019/6/9.
//  Copyright © 2019 宋志京. All rights reserved.
//

#import "PlayerData.h"
#import "../PlayList/AlbumData.h"
#import "../AppDelegate.h"

@interface PlayerData()<AlbumDataDelegate>
@property (strong,nonatomic)AlbumData *albumData;
@end

@implementation PlayerData
static PlayerData *instance = nil;
+(PlayerData*) getInstance{
    if(instance == nil){
        instance = [[PlayerData alloc]init];
        instance.albumData = nil;
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
        long sIndex = [[AppDelegate getInstance].usrData getCurrentSongIndex];
        NSDictionary *soundInfo = [[self albumData]sounds][sIndex];
        return [soundInfo objectForKey:@"title"];
    }
    return @"";
}

-(void)preper4Play{
    UsrData *ud = [AppDelegate getInstance].usrData;
    NSURL *url = [NSURL URLWithString:@"http://frp.u03013112.win:18004/getmp3url"];
    NSMutableURLRequest *mutableRequest = [NSMutableURLRequest requestWithURL:url];
    
    NSDictionary *head = [[NSDictionary alloc]initWithObjectsAndKeys:@"application/json",@"Content-Type", nil];
    NSMutableDictionary *postBodyDict = [[NSMutableDictionary alloc]init];
    [postBodyDict setObject:ud.mod forKey:@"mod"];
    [postBodyDict setObject:ud.currentAlbumURL forKey:@"url"];
    [postBodyDict setObject:[NSNumber numberWithInteger:[ud getCurrentSongIndex]] forKey:@"index"];
    NSData *postData = [NSJSONSerialization dataWithJSONObject:postBodyDict options:NSJSONWritingPrettyPrinted error:nil];
    
    [mutableRequest setHTTPMethod:@"POST"];
    [mutableRequest setHTTPBody:postData];
    [mutableRequest setAllHTTPHeaderFields:head];
    
    NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:mutableRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error == nil) {
//            let server return a json
            dispatch_async(dispatch_get_main_queue(), ^{
//            call player play this url,dont ask why
            });
        }
    }];
    
    [task resume];
}
-(NSString*)getCurrentSongUrl{
        return @"";
}

-(NSString*)getNextSongUrl{
//    UsrData *usrData = [AppDelegate getInstance].usrData;
//    AlbumData *albumData = [AlbumData getInstance];
//    long aIndex = usrData.currentAlbumIndex;
//
//    AlbumData *albumInfo = albumData.AlbumArray[aIndex];
//    if ([[usrData getAlbumData:aIndex] currentSongIndex] >=albumInfo->songInfoArray.count-1){
//        return nil;
//    }
//    [usrData getAlbumData:aIndex].currentSongIndex += 1;
//    SongInfo *songInfo = albumInfo->songInfoArray[[usrData getAlbumData:aIndex].currentSongIndex];
//    [usrData saveUsrData];
//    return songInfo->url;
    return @"";
}
-(NSString*)getprevSongUrl{
//    UsrData *usrData = [AppDelegate getInstance].usrData;
//    AlbumData *albumData = [AlbumData getInstance];
//    long aIndex = usrData.currentAlbumIndex;
//    
//    AlbumData *albumInfo = albumData.AlbumArray[aIndex];
//    if ([[usrData getAlbumData:aIndex] currentSongIndex] <= 0){
//        return nil;
//    }
//    [usrData getAlbumData:aIndex].currentSongIndex -= 1;
//    SongInfo *songInfo = albumInfo->songInfoArray[[usrData getAlbumData:aIndex].currentSongIndex];
//    [usrData saveUsrData];
//    return songInfo->url;
    return @"";
}
- (void)didAlbumDataRecv:(AlbumData *)data {
    self.albumData = data;
}


//1 get playing list albumData,can copy from albumData,or get From intelnet
//2 preper 4 play
//3 play
//4 try2next or try2Prev
@end
