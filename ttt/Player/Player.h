//
//  Player.h
//  ttt
//
//  Created by 宋志京 on 2019/6/9.
//  Copyright © 2019 宋志京. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "../PlayList/AlbumData.h"

NS_ASSUME_NONNULL_BEGIN

@interface Player : NSObject

@property BOOL isPlaying;
@property BOOL isLoading;//正在获取URL中

@property (strong, nonatomic) AVPlayer *player;
@property long scheduleSec;

//正在播放的信息
@property (strong,nonatomic)NSString *currentUrl;
@property long currentIndex;
@property (strong,nonatomic)NSString *mp3Url;
//正在准备的信息
@property (strong,nonatomic)NSString *loadingUrl;
@property long loadingIndex;

@property float current,total,ava;

-(void)playFromAlbumVC:(AlbumData*)ad Index:(long)index;
-(void)playFromAlbumVC:(AlbumData*)ad Index:(long)index FromBegain:(BOOL)isFromeBegain;

-(void)playWithUrl:(NSString *)url;
-(void)pause;
-(void)resume;
-(void)nextSong;
-(void)prevSong;

@end

NS_ASSUME_NONNULL_END
