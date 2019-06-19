//
//  AlbumVC.m
//  ttt
//
//  Created by 宋志京 on 2019/6/8.
//  Copyright © 2019 宋志京. All rights reserved.
//

#import "AlbumVC.h"
#import "AlbumData.h"
#import "SongCell.h"
#import "../AppDelegate.h"
#import <AVFoundation/AVFoundation.h>

@interface AlbumVC ()<AlbumDataDelegate>
//
@property (weak, nonatomic) IBOutlet UILabel *jStartLabel;
@property (weak, nonatomic) IBOutlet UILabel *jEndLabel;
@property (weak, nonatomic) IBOutlet UISlider *jStartSlider;
@property (weak, nonatomic) IBOutlet UISlider *jEndSlider;
@property (weak, nonatomic) IBOutlet UILabel *rateLabel;
@property (weak, nonatomic) IBOutlet UISlider *rateSlider;
@property (weak, nonatomic) IBOutlet UITableView *songArrayTV;
@property (weak, nonatomic) IBOutlet UILabel *lastPlayLabel;
@property (weak, nonatomic) IBOutlet UIButton *playButton;

@property (strong,nonatomic)AlbumData* albumData;

@end

@implementation AlbumVC
-(void)didAlbumDataRecv:(AlbumData*)data{
    NSLog(@"%@",data.sounds[0]);
    self.albumData = data;
    [self.songArrayTV reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[self songArrayTV]setDataSource:self];
    [[self songArrayTV]setDelegate:self];
    
    self.albumData = nil;
    [AlbumData getAlbumInfoByURL:[self url] mod:[self mod] delegate:self];
    
//    UsrData *usrData = [AppDelegate getInstance].usrData;
//    long aIndex = [self albumIndex];
//    if ([[usrData getAlbumData:aIndex] currentSongIndex] <= 0){
//        self.lastPlayLabel.text=@"开始收听吧！";
//    }else{
//        self.lastPlayLabel.text=[NSString stringWithFormat:@"上次听到%ld了",[[usrData getAlbumData:aIndex] currentSongIndex]+1];
//        [self.playButton setTitle:@"继续收听" forState:UIControlStateNormal];
//        [[self songArrayTV]setContentOffset:CGPointMake(0, [[usrData getAlbumData:aIndex] currentSongIndex]*43.5)];
//    }
//
//    UsrDataWithAlbum *uda = [usrData getAlbumData:[self albumIndex]];
//
//    [[self jStartSlider]setValue:[uda startSeekSec]];
//    [self jStartLabel].text = [NSString stringWithFormat:@"%lds",[uda startSeekSec]];
//    [[self jEndSlider]setValue:[uda endSeekSec]];
//    [self jEndLabel].text = [NSString stringWithFormat:@"%lds",[uda endSeekSec]];
//    [[self rateSlider]setValue:[uda rate]];
//    [self rateLabel].text = [NSString stringWithFormat:@"%.2fx",[uda rate]];
    
}

- (IBAction)didBackButtonClicked:(id)sender {
    NSLog(@"didBackButtonClicked");
    [self dismissViewControllerAnimated:YES completion:^{
        //
    }];
}

- (IBAction)didSlider1Changed:(id)sender {
    [self jStartLabel].text = [NSString stringWithFormat:@"%.0fs",[[self jStartSlider] value]];
}

- (IBAction)didSlider2Changed:(id)sender {
    [self jEndLabel].text = [NSString stringWithFormat:@"%.0fs",[[self jEndSlider] value]];
}
- (IBAction)didSlider3Changed:(id)sender {
    [self rateLabel].text = [NSString stringWithFormat:@"%.2fx",[[self rateSlider] value]];
}

- (IBAction)didSlider1OK:(id)sender {
    [[AppDelegate getInstance].usrData setCurrentStartSeekSec:self.jStartSlider.value];
}
- (IBAction)didSlider2OK:(id)sender {
    [[AppDelegate getInstance].usrData setCurrentEndSeekSec:self.jEndSlider.value];
}
- (IBAction)didSlider3OK:(id)sender {
    [[AppDelegate getInstance].usrData setCurrentRate:self.rateSlider.value];
}


- (IBAction)didPlayButtonClicked:(id)sender {
    UsrData *usrData = [AppDelegate getInstance].usrData;
    usrData.currentAlbumURL = self.url;
    [[AppDelegate getInstance].player play];
    [[self songArrayTV]reloadData];
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    if([self albumData]!=nil){
        SongCell *cell = [self.songArrayTV dequeueReusableCellWithIdentifier:@"SongCell"];
        NSDictionary *dict =[[self albumData]sounds][indexPath.row];
        cell.songLabel.text = [dict objectForKey:@"title"];
        cell.statusLabel.text = @"";
        if ([[AppDelegate getInstance].usrData getCurrentSongIndex]==indexPath.row){
            if([[AppDelegate getInstance].player isPlaying]== YES){
                cell.statusLabel.text = @"正在播放";
            }else{
                cell.statusLabel.text = @"上次播放";
            }
        }
        return  cell;
    }
    return nil;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if([self albumData]!=nil){
        return [[[self albumData]sounds]count];
    }
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UsrData *usrData = [AppDelegate getInstance].usrData;
    usrData.currentAlbumURL = self.url;
    [usrData setCurrentSongIndex:indexPath.row];
    [[AppDelegate getInstance].player play];
    [[self songArrayTV]reloadData];
}

@end
