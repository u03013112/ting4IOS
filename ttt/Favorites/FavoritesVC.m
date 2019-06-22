//
//  FavoritesVC.m
//  ttt
//
//  Created by u03013112 on 2019/6/21.
//  Copyright © 2019 宋志京. All rights reserved.
//

#import "FavoritesVC.h"
#import "../Search/SearchCell.h"//暂时就用这个吧
#import "../PlayList/AlbumVC.h"
#import "../PlayList/AlbumData.h"
#import "../AppDelegate.h"

@interface FavoritesVC ()<UITableViewDataSource,UITableViewDelegate,AlbumDataDelegate>
@property (weak, nonatomic) IBOutlet UILabel *lastLabel;
@property (weak, nonatomic) IBOutlet UILabel *loadingLabel;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UILabel *scheduleLabel;
@property (weak, nonatomic) IBOutlet UITableView *AlbumTV;

@property (strong,nonatomic) AlbumData *albumData;
@end

@implementation FavoritesVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if([AppDelegate getInstance].usrData.albumFavorites.count >0){
        for (unsigned long i=[AppDelegate getInstance].usrData.albumFavorites.count-1;i>0;--i){
            NSDictionary *d = [AppDelegate getInstance].usrData.albumFavorites[i];
            if([d objectForKey:@"title"]==nil){
                [[AppDelegate getInstance].usrData.albumFavorites removeObject:d];
            }
        }
    }
    [[self AlbumTV]setDelegate:self];
    [[self AlbumTV]setDataSource:self];
    
    UsrData *ud = [[AppDelegate getInstance]usrData];
    [AlbumData getAlbumInfoByURL:ud.currentAlbumURL mod:ud.mod delegate:self];
    [NSTimer scheduledTimerWithTimeInterval:1.0 repeats:YES block:^(NSTimer * _Nonnull timer) {
        if ([self albumData]!=nil){
            [self updatePerSec];
        }
    }];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 70.0f;
}
- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    SearchCell *cell = [self.AlbumTV dequeueReusableCellWithIdentifier:@"SearchCell"];
    
    NSDictionary *info = [AppDelegate getInstance].usrData.albumFavorites[indexPath.row];
    cell.nameLabel.text = [info objectForKey:@"title"];
    cell.authorLabel.text = [info objectForKey:@"mod"];
    cell.soundLabel.text = @"";
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[AppDelegate getInstance].usrData.albumFavorites count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *data = [AppDelegate getInstance].usrData.albumFavorites[indexPath.row];
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Album" bundle:nil];
    AlbumVC *vc = [sb instantiateViewControllerWithIdentifier:@"AlbumMain"];
    vc.url = [data objectForKey:@"url"];
    vc.mod = [data objectForKey:@"mod"];
    [self presentViewController:vc animated:YES completion:^{
        //
    }];
}
- (IBAction)didReflushButtonClicked:(id)sender {
    [[self AlbumTV]reloadData];
    UsrData *ud = [[AppDelegate getInstance]usrData];
    [AlbumData getAlbumInfoByURL:ud.currentAlbumURL mod:ud.mod delegate:self];
}

-(void)didAlbumDataRecv:(AlbumData*)data{
    [self lastLabel].text = data.name;
    [[self playButton]setTitle:@"继续播放" forState:UIControlStateNormal];
    self.albumData = data;
    UsrData *usrData = [AppDelegate getInstance].usrData;
    
    self.loadingLabel.text=[NSString stringWithFormat:@"第%d集",[[[usrData getAlbumConfig:data.url]objectForKey:@"currentSongIndex"]intValue]+1];
}
- (IBAction)didPlayButtonClicked:(id)sender {
    if(self.albumData != nil){
        if([[[AppDelegate getInstance]player] isPlaying]){
            [[[AppDelegate getInstance]player] pause];
        }else{
            if ([[AppDelegate getInstance]player].player.currentItem !=nil){
                [[[AppDelegate getInstance]player] resume];
            }else{
                UsrData *ud = [[AppDelegate getInstance]usrData];
                long index = [[[ud getAlbumConfig:self.albumData.url]objectForKey:@"currentSongIndex"]intValue];
                [[AppDelegate getInstance].player playFromAlbumVC:self.albumData Index:index];
            }
            
            UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Player" bundle:nil];
            AlbumVC *vc = [sb instantiateViewControllerWithIdentifier:@"PlayerVC"];
            [self addChildViewController:vc];
            [self.view addSubview:vc.view];
        }
    }
}
- (IBAction)didScheduleButtonClicked:(id)sender {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Player" bundle:nil];
    AlbumVC *vc = [sb instantiateViewControllerWithIdentifier:@"ScheduleCV"];
    [self addChildViewController:vc];
    [self.view addSubview:vc.view];
}
-(void)updatePerSec{
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

@end
