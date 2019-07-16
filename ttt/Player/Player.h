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
@property (strong, nonatomic) AVPlayer *player2;
@property long scheduleSec;

//正在播放的信息
@property (strong,nonatomic)NSString *currentUrl;
@property long currentIndex;

@property float current,total,ava;
@property float total2,ava2;

@property NSString *loadingUrl;
@property long loadingIndex;
@property int loadingRetryTimes;

@property NSString *nextURL;
@property int nextRetryTimes;

-(void)playFromAlbumVC:(AlbumData*)ad Index:(long)index;
-(void)playFromAlbumVC:(AlbumData*)ad Index:(long)index FromBegain:(BOOL)isFromeBegain;

-(void)playWithUrl:(NSString *)url;
-(void)pause;
-(void)resume;
-(void)nextSong;
-(void)prevSong;

//delegate function
-(void)getUrlRetry:(NSUInteger)n;
-(void)getUrlOver:(NSUInteger)n;
-(void)getUrlSuccess:(NSUInteger)n URL:(NSString*)url;

-(BOOL)canNext;

@end

NS_ASSUME_NONNULL_END
