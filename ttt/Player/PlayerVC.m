//
//  PlayerVC.m
//  ttt
//
//  Created by 宋志京 on 2019/6/9.
//  Copyright © 2019 宋志京. All rights reserved.
//

#import "PlayerVC.h"
#import "../AppDelegate.h"
#import "PlayerData.h"

@interface PlayerVC ()
@property (weak)Player *player;
@property BOOL isSliding;
@end

@implementation PlayerVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.player = [[AppDelegate getInstance]player];
    [NSTimer scheduledTimerWithTimeInterval:1.0 repeats:YES block:^(NSTimer * _Nonnull timer) {
        [self updatePerSec];
    }];
    self.isSliding = NO;
}

- (IBAction)didblackButtonClicked:(id)sender {
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
}

- (IBAction)didPlayButtonClicked:(id)sender {
    if([self.player isPlaying]){
        [self.player pause];
        [self.playButton setTitle:@"播放" forState:UIControlStateNormal];
    }else{
        [self.player resume];
        [self.playButton setTitle:@"暂停" forState:UIControlStateNormal];
    }
}

- (IBAction)didNextButtonClicked:(id)sender {
    [self.player nextSong];
}

- (IBAction)didPrevButtonClicked:(id)sender {
    [self.player prevSong];
}

- (IBAction)didSliderChanged:(id)sender {
    self.isSliding = YES;
    int current = (int)[self.slider value];
    int total = (int)self.player.total;
    self.timeLabel.text = [NSString stringWithFormat:@"%02d:%02d/%02d:%02d",current/60,current%60,total/60,total%60];
}

- (IBAction)didSliderClicked:(id)sender {
    self.isSliding = NO;
    int current = (int)[self.slider value];
    [self.player.player seekToTime:CMTimeMake(current,1)];
}

-(void)updatePerSec{
    int current = (int)self.player.current;
    int total = (int)self.player.total;
    if (current>0 && total>0){
        if([self.player isPlaying]){
            [self.playButton setTitle:@"暂停" forState:UIControlStateNormal];
        }else{
            [self.playButton setTitle:@"播放" forState:UIControlStateNormal];
        }
        self.timeLabel.text = [NSString stringWithFormat:@"%02d:%02d/%02d:%02d",current/60,current%60,total/60,total%60];
        if (self.isSliding == NO){
            [self.slider setMinimumValue:0];
            [self.slider setMaximumValue:total];
            [self.slider setValue:current];
        }
        self.albumLabel.text = [[PlayerData getInstance] getCurrentAlbumName];
        self.songLabel.text = [[PlayerData getInstance] getCurrentSongName];
    }
    
    self.url.text = self.player.mp3Url;
    
    if(self.player.isLoading){
        self.statusLabel.text=@"正在准备播放";
    }else if(self.player.isPlaying){
        if(self.player.ava>=self.player.total-1){//-1是为了避免误差
            self.statusLabel.text=@"全部缓冲完成";
        }else{
            int ava = (int)self.player.ava;
            self.statusLabel.text=[NSString stringWithFormat:@"缓冲了%02d:%02d",ava/60,ava%60];
        }
    }
}

@end
