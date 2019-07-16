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
#import "ScheduleCV.h"

@interface PlayerVC ()<AlbumDataDelegate>
@property (weak)Player *player;
@property BOOL isSliding;
@property (weak, nonatomic) IBOutlet UILabel *scheduleLabel;
@property NSUInteger n;//AlbumData 重试次数

@property (strong,nonatomic) AlbumData *albumData;

@end

@implementation PlayerVC

-(void)didAlbumDataRecv:(AlbumData*)data{
    
    self.albumData = data;
    UsrData *ud = [[AppDelegate getInstance]usrData];
    long index = [[[ud getAlbumConfig:self.albumData.url]objectForKey:@"currentSongIndex"]intValue];
    [[AppDelegate getInstance].player playFromAlbumVC:self.albumData Index:index];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.player = [[AppDelegate getInstance]player];
    [NSTimer scheduledTimerWithTimeInterval:1.0 repeats:YES block:^(NSTimer * _Nonnull timer) {
        [self updatePerSec];
    }];
    self.isSliding = NO;
    
    if ([PlayerData getInstance].albumData == nil){
        //    尝试播放上次播放内容
        self.albumData = nil;
        UsrData *ud = [[AppDelegate getInstance]usrData];
        if (ud.currentAlbumURL != nil && [ud.currentAlbumURL isEqualToString:@""]==NO){
            self.url.text = @"加载中...";
            [AlbumData getAlbumInfoByURL:ud.currentAlbumURL mod:ud.mod delegate:self];
        }
        
    }
    self.nextUrl.text = @"";
    self.nextStatusLabel.text = @"";
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
        self.songLabel.text = [[PlayerData getInstance] getSongName:self.player.currentIndex];
    }
    
    self.url.text = self.player.currentUrl;
    
    if([self.player.currentUrl  isEqual: @""]){
        self.statusLabel.text = @"正在解析地址";
        if (self.player.loadingRetryTimes >0){
            self.nextStatusLabel.text = [NSString stringWithFormat:@"正在解析地址，重试第%d次",self.player.loadingRetryTimes];
        }
        self.playButton.enabled = NO;
    }else{
        self.playButton.enabled = YES;
        if(self.player.ava>=self.player.total-1){//-1是为了避免误差
            self.statusLabel.text=@"全部缓冲完成";
        }else{
            int ava = (int)self.player.ava;
            self.statusLabel.text=[NSString stringWithFormat:@"缓冲了%02d:%02d",ava/60,ava%60];
        }
    }
    
    if (self.albumData == nil){
        self.statusLabel.text = @"正在获取播放列表";
        if (self.n >0){
            self.statusLabel.text = [NSString stringWithFormat:@"正在获取播放列表,重试第%lu次",(unsigned long)self.n ];
        }
    }
    
    if ([self.player.nextURL  isEqual: @""]){
        self.nextStatusLabel.text = @"正在解析地址";
        if (self.player.nextRetryTimes >0){
            self.nextStatusLabel.text = [NSString stringWithFormat:@"正在解析地址，重试第%d次",self.player.nextRetryTimes];
        }
    }else{
        self.nextUrl.text = self.player.nextURL;
        if(self.player.ava2>=self.player.total2-1){//-1是为了避免误差
            self.nextStatusLabel.text=@"全部缓冲完成";
        }else{
            int ava2 = (int)self.player.ava2;
            self.nextStatusLabel.text = [NSString stringWithFormat:@"缓冲了%02d:%02d",ava2/60,ava2%60];
        }
    }
    
    
    
    if([[[AppDelegate getInstance]player] isPlaying]){
        [[self playButton]setTitle:@"暂停" forState:UIControlStateNormal];
    }else{
        [[self playButton]setTitle:@"继续播放" forState:UIControlStateNormal];
    }
    
    long s = [[[AppDelegate getInstance]player]scheduleSec];
    if (s>0){
        [self scheduleLabel].text = [NSString stringWithFormat:@"倒计时 %02ld:%02ld",s/60,s%60];
    }else{
        [self scheduleLabel].text = @"";
    }
}

- (IBAction)didScheduleButtonClicked:(id)sender {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Player" bundle:nil];
    ScheduleCV *vc = [sb instantiateViewControllerWithIdentifier:@"ScheduleCV"];
    [self addChildViewController:vc];
    [self.view addSubview:vc.view];
}

-(void)didRetry{
    self.n ++ ;
}

@end
