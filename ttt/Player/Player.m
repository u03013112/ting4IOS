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
@end

@implementation Player

-(id)init{
    if (self = [super init]){
        self.player=[[AVPlayer alloc]init];
        self.isPlaying = NO;
        [NSTimer scheduledTimerWithTimeInterval:1.0 repeats:YES block:^(NSTimer * _Nonnull timer) {
            if ([self isPlaying]){
                [self updatePerSec];
            }
        }];
        [self initContorller];
    }
    return self;
}

-(void)play{
    NSString *url = [[PlayerData getInstance] getCurrentSongUrl];
    AVPlayerItem * item = [[AVPlayerItem alloc]initWithURL:[NSURL URLWithString:url]];
    [[self player] replaceCurrentItemWithPlayerItem:item];
    
    [[self player]seekToTime:CMTimeMake([[[AppDelegate getInstance]usrData]getCurrentSeekSec], 1)];
    
    [[self player]play];
    self.isPlaying = YES;
    NSLog(@"play %@\n%@",[[PlayerData getInstance] getCurrentSongName],[[PlayerData getInstance] getCurrentSongUrl]);
}

-(void)updatePerSec{
    float current = CMTimeGetSeconds([self player].currentItem.currentTime);
    float total = CMTimeGetSeconds([self player].currentItem.duration);
    
    if (current) {
        NSLog(@"%@/%@\n",[NSString stringWithFormat:@"%.f",current],[NSString stringWithFormat:@"%.2f",total]);
        
        if([[NSString stringWithFormat:@"%.f",current]integerValue]%30==0){//每隔30秒存一次目前进度
            [[[AppDelegate getInstance]usrData]setCurrentSeekSec:current+1];//防止一读档就又要存档
            [[[AppDelegate getInstance]usrData]saveUsrData];
//            [self reflushMPCenter];//也有空就刷一下，保障进度
        }
        
        long startSeekSec = [[[AppDelegate getInstance] usrData]getCurrentStartSeekSec];
        long endSeekSec = [[[AppDelegate getInstance] usrData]getCurrentEndSeekSec];
        if(startSeekSec >0 && current < startSeekSec){
            [[self player] seekToTime:CMTimeMake(startSeekSec, 1)];
            [self reflushMPCenter];
        }
        if((endSeekSec>0 && current > total-endSeekSec) || current >=total-1){
            [self nextSong];
            [self reflushMPCenter];
        }
    }
    
    NSLog(@"缓冲时间：%f",[self availableDuration]);
    if ([self getCurrentPlayingTime]<[self availableDuration]-5){
        [[self player]playImmediatelyAtRate:[[[AppDelegate getInstance] usrData] getCurrentRate]];
        [self reflushMPCenter];
    }
    
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
-(void)nextSong{
    NSString *url = [[PlayerData getInstance] getNextSongUrl];
    if (url==nil){
        return;
    }
    AVPlayerItem * item = [[AVPlayerItem alloc]initWithURL:[NSURL URLWithString:url]];
    [[self player] replaceCurrentItemWithPlayerItem:item];
}
-(void)prevSong{
    NSString *url = [[PlayerData getInstance] getprevSongUrl];
    if (url==nil){
        return;
    }
    AVPlayerItem * item = [[AVPlayerItem alloc]initWithURL:[NSURL URLWithString:url]];
    
    [[self player] replaceCurrentItemWithPlayerItem:item];
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
- (NSTimeInterval)availableDuration{
    NSArray *loadedTimeRanges = [[self.player currentItem] loadedTimeRanges];
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
    [info setObject:[[PlayerData getInstance] getCurrentSongName] forKey:MPMediaItemPropertyTitle];
    [info setObject:[[PlayerData getInstance] getCurrentAlbumName] forKey:MPMediaItemPropertyAlbumTitle];
    [info setObject:@(current) forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime];
    [info setObject:@(total) forKey:MPMediaItemPropertyPlaybackDuration];
    [info setObject:@([[[AppDelegate getInstance] usrData] getCurrentRate]) forKey:MPNowPlayingInfoPropertyPlaybackRate];
    [[MPNowPlayingInfoCenter defaultCenter]setNowPlayingInfo:info];
}
@end
