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

@implementation PlayerData
PlayerData *instance1 = nil;
+(PlayerData*) getInstance{
    if(instance1 == nil){
        instance1 = [[PlayerData alloc]init];
    }
    return instance1;
}

-(NSString*)getCurrentAlbumName{
    AlbumData *albumData = [AlbumData getInstance];
    long aIndex = [AppDelegate getInstance].usrData.currentAlbumIndex;
    if(aIndex>=albumData.AlbumArray.count){
        return nil;
    }
    AlbumInfo *albumInfo = albumData.AlbumArray[aIndex];
    return albumInfo->name;
}

-(NSString*)getCurrentSongName{
    UsrData *usrData = [AppDelegate getInstance].usrData;
    AlbumData *albumData = [AlbumData getInstance];
    long aIndex = usrData.currentAlbumIndex;
    if(aIndex>=albumData.AlbumArray.count){
        return nil;
    }
    AlbumInfo *albumInfo = albumData.AlbumArray[aIndex];
    long sIndex = [[usrData getAlbumData:aIndex] currentSongIndex];
    SongInfo *songInfo = albumInfo->songInfoArray[sIndex];
    return songInfo->name;
}

-(NSString*)getCurrentSongUrl{
    UsrData *usrData = [AppDelegate getInstance].usrData;
    AlbumData *albumData = [AlbumData getInstance];
    long aIndex = usrData.currentAlbumIndex;
    
    AlbumInfo *albumInfo = albumData.AlbumArray[aIndex];
    long sIndex = [[usrData getAlbumData:aIndex] currentSongIndex];
    SongInfo *songInfo = albumInfo->songInfoArray[sIndex];
    [usrData saveUsrData];
    return songInfo->url;
}

-(NSString*)getNextSongUrl{
    UsrData *usrData = [AppDelegate getInstance].usrData;
    AlbumData *albumData = [AlbumData getInstance];
    long aIndex = usrData.currentAlbumIndex;
    
    AlbumInfo *albumInfo = albumData.AlbumArray[aIndex];
    if ([[usrData getAlbumData:aIndex] currentSongIndex] >=albumInfo->songInfoArray.count-1){
        return nil;
    }
    [usrData getAlbumData:aIndex].currentSongIndex += 1;
    SongInfo *songInfo = albumInfo->songInfoArray[[usrData getAlbumData:aIndex].currentSongIndex];
    [usrData saveUsrData];
    return songInfo->url;
}
-(NSString*)getprevSongUrl{
    UsrData *usrData = [AppDelegate getInstance].usrData;
    AlbumData *albumData = [AlbumData getInstance];
    long aIndex = usrData.currentAlbumIndex;
    
    AlbumInfo *albumInfo = albumData.AlbumArray[aIndex];
    if ([[usrData getAlbumData:aIndex] currentSongIndex] <= 0){
        return nil;
    }
    [usrData getAlbumData:aIndex].currentSongIndex -= 1;
    SongInfo *songInfo = albumInfo->songInfoArray[[usrData getAlbumData:aIndex].currentSongIndex];
    [usrData saveUsrData];
    return songInfo->url;
}
@end
