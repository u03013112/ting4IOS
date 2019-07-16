//
//  Player.m
//  ttt
//
//  Created by 宋志京 on 2019/6/9.
//  Copyright © 2019 宋志京. All rights reserved.
//

#import "Player.h"
#import "PlayerData.h"
#import "../AppDelegate.h"
#import <MediaPlayer/MediaPlayer.h>
@interface Player()
@property NSUInteger n;

@property BOOL isFromBegain;
@property NSUInteger loadingID; //正要播放的id


@property NSUInteger nextID; //下一集的id


@end

@implementation Player

-(id)init{
    if (self = [super init]){
        self.player=[[AVPlayer alloc]init];
        self.player2=[[AVPlayer alloc]init];
        self.isPlaying = NO;
        self.isLoading = NO;
        [NSTimer scheduledTimerWithTimeInterval:1.0 repeats:YES block:^(NSTimer * _Nonnull timer) {
            if ([self isPlaying]){
                [self updatePerSec];
            }
        }];
        [self initContorller];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(nextSong) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
        self.n = 0;
        self.loadingID = 0;
        self.nextID = 0;
        self.isFromBegain = NO;
        
        self.currentUrl = @"";
        self.nextURL = @"";
    }
    return self;
}

-(void)playWithUrl:(NSString *)url{
    AVPlayerItem * item = [[AVPlayerItem alloc]initWithURL:[NSURL URLWithString:url]];
    [[self player] replaceCurrentItemWithPlayerItem:item];
    [[self player]play];
    
    self.isPlaying = YES;
    self.isLoading = NO;
    
    self.currentUrl = self.loadingUrl;
    self.currentIndex = self.loadingIndex;
    NSLog(@"play %@\n[%@]",[[PlayerData getInstance] getSongName:self.currentIndex],url);
//    self.mp3Url=url;
}

//直接切换下一个播放器，为了能够一次缓冲两集，解决网络波动
-(void)playNextPlayer{
    [self.player pause];
    self.player = self.player2;
    self.player2 = [[AVPlayer alloc]init];
    [self.player play];
    self.currentUrl = self.nextURL;
    self.currentIndex ++;
}

-(void)updatePerSec{
    float current = CMTimeGetSeconds([self player].currentItem.currentTime);
    float total = CMTimeGetSeconds([self player].currentItem.duration);
    self.current = current;
    self.total = total;
    
    self.total2 = CMTimeGetSeconds([self player2].currentItem.duration);
    if (current && total) {
//        NSLog(@"%@/%@\n",[NSString stringWithFormat:@"%.f",current],[NSString stringWithFormat:@"%.2f",total]);
        
        if([[NSString stringWithFormat:@"%.f",current]integerValue]%30==0){//每隔30秒存一次目前进度
            [[[AppDelegate getInstance]usrData]setCurrentSeekSec:current-1];//防止一读档就又要存档
            [[[AppDelegate getInstance]usrData]saveUsrData];
        }
        
        long startSeekSec = [[[AppDelegate getInstance] usrData]getCurrentStartSeekSec];
        long endSeekSec = [[[AppDelegate getInstance] usrData]getCurrentEndSeekSec];
        
        if(startSeekSec >0 && current < startSeekSec){
            [[self player] seekToTime:CMTimeMake(startSeekSec, 1)];
            [self reflushMPCenter];
        }
        long curSec = [[[AppDelegate getInstance]usrData]getCurrentSeekSec];
        if(curSec>0 && current < curSec){
            [[self player] seekToTime:CMTimeMake(curSec, 1)];
            [self reflushMPCenter];
        }
        if((endSeekSec>0 && current > total-endSeekSec) || current >=total-1){
            [self nextSong];
            [self reflushMPCenter];
        }
    }else{
//        [[self player]automaticallyWaitsToMinimizeStalling];
        
//        NSLog(@"%ld %@",(long)[[[self player]currentItem]status],[[self player]reasonForWaitingToPlay]);
    }
    
    self.ava = [self availableDuration:self.player];
    self.ava2 = [self availableDuration:self.player2];
    
    if ([self getCurrentPlayingTime]<[self availableDuration:self.player]-5){
        [[self player]playImmediatelyAtRate:[[[AppDelegate getInstance] usrData] getCurrentRate]];
        [self reflushMPCenter];
    }
    
//    NSLog(@"缓冲时间：%f",[self availableDuration:self.player2]);
    
    if([self scheduleSec]>0){
        self.scheduleSec --;
        if(self.scheduleSec ==0){
            [self pause];
            self.scheduleSec = -1;
        }
    }
    
}
-(void)pause{
    [[self player]pause];
    self.isPlaying = NO;
}

-(void)resume{
    [[self player]play];
    self.isPlaying = YES;
}

-(void)playOrPause{
    if (self.isPlaying == YES){
        [self pause];
    }else{
        [self resume];
    }
}

/**
 *  返回 当前 视频 播放时长
 */
- (double)getCurrentPlayingTime{
    return self.player.currentTime.value/self.player.currentTime.timescale;
}

/**
 *  返回 当前 视频 缓存时长
 */
- (NSTimeInterval)availableDuration:(AVPlayer *)player{
    NSArray *loadedTimeRanges = [[player currentItem] loadedTimeRanges];
    CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue];// 获取缓冲区域
    float startSeconds = CMTimeGetSeconds(timeRange.start);
    float durationSeconds = CMTimeGetSeconds(timeRange.duration);
    NSTimeInterval result = startSeconds + durationSeconds;// 计算缓冲总进度
    
    return result;
}

-(void)initContorller{
    MPRemoteCommandCenter * commandCenter = [MPRemoteCommandCenter sharedCommandCenter];
//    PLAY
    commandCenter.playCommand.enabled = YES;
    [commandCenter.playCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        NSLog(@"remote_播放");
        [self resume];
        return MPRemoteCommandHandlerStatusSuccess;
    }];
//    PAUSE
    commandCenter.pauseCommand.enabled = YES;
    [commandCenter.pauseCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        NSLog(@"remote_暂停");
        [self pause];
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    commandCenter.togglePlayPauseCommand.enabled = YES;
    [commandCenter.togglePlayPauseCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        NSLog(@"耳机线控");
        [self playOrPause];
        return MPRemoteCommandHandlerStatusSuccess;
    }];
//    NEXT
    commandCenter.nextTrackCommand.enabled = YES;
    [commandCenter.nextTrackCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        NSLog(@"remote_下一首");
        [self nextSong];
        return MPRemoteCommandHandlerStatusSuccess;
    }];
//    PREV
    commandCenter.previousTrackCommand.enabled = YES;
    [commandCenter.previousTrackCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        NSLog(@"remote_上一首");
        [self prevSong];
        return MPRemoteCommandHandlerStatusSuccess;
    }];
//    SEEK
    commandCenter.changePlaybackPositionCommand.enabled = YES;
    [commandCenter.changePlaybackPositionCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        MPChangePlaybackPositionCommandEvent *positionCommandEvent = (MPChangePlaybackPositionCommandEvent*)event;
        if (positionCommandEvent == nil) {
            return MPRemoteCommandHandlerStatusCommandFailed;
        }
        NSTimeInterval positionTime = positionCommandEvent.positionTime;
        NSLog(@"[Player] Seek to time=%f", positionTime);
        [self.player seekToTime:CMTimeMake(positionTime,1)];
        return MPRemoteCommandHandlerStatusSuccess;
    }];
}

-(void)reflushMPCenter{
    float current = CMTimeGetSeconds([self player].currentItem.currentTime);
    float total = CMTimeGetSeconds([self player].currentItem.duration);
    
    NSMutableDictionary * info = [NSMutableDictionary dictionary];
    [info setObject:[[PlayerData getInstance] getSongName:self.currentIndex] forKey:MPMediaItemPropertyTitle];
    [info setObject:[[PlayerData getInstance] getCurrentAlbumName] forKey:MPMediaItemPropertyAlbumTitle];
    [info setObject:@(current) forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime];
    [info setObject:@(total) forKey:MPMediaItemPropertyPlaybackDuration];
    [info setObject:@([[[AppDelegate getInstance] usrData] getCurrentRate]) forKey:MPNowPlayingInfoPropertyPlaybackRate];
    [[MPNowPlayingInfoCenter defaultCenter]setNowPlayingInfo:info];
}

-(void)playFromAlbumVC:(AlbumData*)ad Index:(long)index FromBegain:(BOOL)isFromeBegain{
    [PlayerData getInstance].albumData = ad;
    [self try2Play:ad.mod URL:ad.url Index:index FromBegain:isFromeBegain];
}

-(void)playFromAlbumVC:(AlbumData*)ad Index:(long)index{
    if(ad.url == nil || [ad.url isEqualToString:@""]){
        return;
    }
    [PlayerData getInstance].albumData = ad;
    [self try2Play:ad.mod URL:ad.url Index:index FromBegain:NO];
}

-(void)try2Play:(NSString*)mod URL:(NSString*)url Index:(long)index FromBegain:(BOOL) isFromBegain{
    UsrData *ud = [[AppDelegate getInstance]usrData];
    self.isLoading = YES;
    self.loadingUrl = url;
    self.loadingIndex = index;
    
    [ud setMod:mod];
    [ud setCurrentSongIndex:index];
    [ud setCurrentAlbumURL:url];
    
    self.isFromBegain = isFromBegain;
//    获取当前url
    self.loadingID = self.n ++;
    [[PlayerData getInstance]getSongUrl:mod URL:url Index:index n:self.loadingID];
    self.currentUrl = @"";
    self.loadingRetryTimes = 0;
//    获取下一首url
    self.nextID = self.n ++;
    [[PlayerData getInstance]getSongUrl:mod URL:url Index:index+1 n:self.nextID];
    self.nextURL = @"";
    self.nextRetryTimes = 0;
}
-(void)nextSong{
    if ([self canNext]==NO){
        return;
    }
    UsrData *ud = [[AppDelegate getInstance]usrData];
    long index = [ud getCurrentSongIndex];
    index++;

    [ud setCurrentSongIndex:index];
    [ud setCurrentSeekSec:0];
    [self playNextPlayer];

    //    获取下一首url
    self.nextID = self.n ++;
    AlbumData *ad = [PlayerData getInstance].albumData;
    [[PlayerData getInstance]getSongUrl:ad.mod URL:ad.url Index:index+1 n:self.nextID];
    self.nextURL = @"";
    self.nextRetryTimes = 0;
}
-(void)prevSong{
    UsrData *ud = [[AppDelegate getInstance]usrData];
    long index = [ud getCurrentSongIndex];
    index--;
    [self try2Play:[PlayerData getInstance].albumData.mod URL:[PlayerData getInstance].albumData.url Index:index FromBegain:YES];
}

-(void)getUrlRetry:(NSUInteger)n{
    if (n == self.loadingID){
        self.loadingRetryTimes ++;
    }
    if (n == self.nextID){
        self.nextRetryTimes ++;
    }
}

-(void)getUrlOver:(NSUInteger)n{
//
}
-(void)getUrlSuccess:(NSUInteger)n URL:(NSString*)url{
    if (n == self.loadingID){
        if (self.isFromBegain==YES){
            [[AppDelegate getInstance].usrData setCurrentSeekSec:0];
        }
        [self playWithUrl:url];
    }
    if (n == self.nextID){
        self.nextURL = url;
        AVPlayerItem * item = [[AVPlayerItem alloc]initWithURL:[NSURL URLWithString:url]];
        [[[AppDelegate getInstance]player].player2 replaceCurrentItemWithPlayerItem:item];
    }
}
-(BOOL)canNext{
    if ([self availableDuration:self.player2] >10.0f){
        return YES;
    }
    return NO;
}
@end
