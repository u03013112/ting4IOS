//
//  PlayListVC.m
//  ttt
//
//  Created by 宋志京 on 2019/6/8.
//  Copyright © 2019 宋志京. All rights reserved.
//

#import "PlayListVC.h"
#import "AlbumData.h"
#import "PlayListCell.h"
#import "AlbumVC.h"
#import "../Player/PlayerData.h"
#import "../AppDelegate.h"

@interface PlayListVC ()<AlbumDataDelegate>
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UILabel *scheduleLabel;

-(void)didAlbumDataChanged;
@end

@implementation PlayListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[self playlistTV]setDelegate:self];
    [[self playlistTV]setDataSource:self];
    
    [NSTimer scheduledTimerWithTimeInterval:1.0 repeats:YES block:^(NSTimer * _Nonnull timer) {
        [self updatePerSec];
    }];
    [[AlbumData getInstance]setDelegate:self];
}

-(void)didAlbumDataChanged{
    NSLog(@"%ld",[[[AlbumData getInstance]AlbumArray]count]);
    [[self playlistTV]reloadData];
    [self lastLabel].text = [NSString stringWithFormat:@"%@ %@",[[PlayerData getInstance] getCurrentAlbumName],[[PlayerData getInstance] getCurrentSongName]];
    long sec = [[[AppDelegate getInstance]player]scheduleSec];
    if(sec >0){
        self.scheduleLabel.text=[NSString stringWithFormat:@"倒计时 %ld:%02ld",sec/60,sec%60];
    }else{
        self.scheduleLabel.text=@"";
    }
    [[self playButton]setTitle:@"继续播放" forState:UIControlStateNormal];
}
- (IBAction)didPlayButtonClicked:(id)sender {
    if([[[AppDelegate getInstance]player]isPlaying]){
        [[[AppDelegate getInstance]player]pause];
        [[self playButton]setTitle:@"继续播放" forState:UIControlStateNormal];
    }else{
        [[[AppDelegate getInstance]player]play];
        [[self playButton]setTitle:@"暂停播放" forState:UIControlStateNormal];
        
    }
    
}

- (IBAction)didScheduleButtonClicked:(id)sender {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Player" bundle:nil];
    AlbumVC *vc = [sb instantiateViewControllerWithIdentifier:@"ScheduleCV"];
//    [self presentViewController:vc animated:YES completion:^{
//    }];
    [self addChildViewController:vc];
    [self.view addSubview:vc.view];
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    PlayListCell *cell = [self.playlistTV dequeueReusableCellWithIdentifier:@"PlayListCell"];
//    PlayListCell *cell = [self.playlistTV dequeueReusableCellWithIdentifier:@"PlayListCell" forIndexPath:indexPath];
    AlbumInfo *info = [[AlbumData getInstance]AlbumArray][indexPath.row];
    cell.label.text = info->name;
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[[AlbumData getInstance]AlbumArray]count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    AlbumInfo *info = [[AlbumData getInstance]AlbumArray][indexPath.row];
    NSLog(@"did select row %@\n",info->name);
    NSArray *songInfoList = info->songInfoArray;
    if (songInfoList!=nil){
        NSLog(@"%lu",(unsigned long)[songInfoList count]);
        
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Album" bundle:nil];
        AlbumVC *vc = [sb instantiateViewControllerWithIdentifier:@"AlbumMain"];
        vc.albumIndex = indexPath.row;
        [self presentViewController:vc animated:YES completion:^{
//            
        }];
    }
}

-(void)updatePerSec{
    [self lastLabel].text = [NSString stringWithFormat:@"%@ %@",[[PlayerData getInstance] getCurrentAlbumName],[[PlayerData getInstance] getCurrentSongName]];
    long sec = [[[AppDelegate getInstance]player]scheduleSec];
    if(sec >0){
        self.scheduleLabel.text=[NSString stringWithFormat:@"倒计时 %ld:%02ld",sec/60,sec%60];
    }else{
        self.scheduleLabel.text=@"";
    }
}

@end
