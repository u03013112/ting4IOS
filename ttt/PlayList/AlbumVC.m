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
@property (weak, nonatomic) IBOutlet UINavigationItem *ntitle;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *c;
@property (weak, nonatomic) IBOutlet UIButton *favButton;

@property (strong,nonatomic)AlbumData* albumData;

@end

@implementation AlbumVC
-(void)didAlbumDataRecv:(AlbumData*)data{
//    NSLog(@"%@",data.sounds[0]);
    self.albumData = data;
    [self.songArrayTV reloadData];
    [self.songArrayTV setContentOffset:CGPointMake(0, 44*[[[[AppDelegate getInstance].usrData getAlbumConfig:self.url]objectForKey:@"currentSongIndex"]intValue])];
    [self ntitle].title=self.albumData.name;
    [self.c removeFromSuperview];
    [self.playButton setTitle:@"继续收听" forState:UIControlStateNormal];
    
    [[self favButton]setTitle:@"收藏" forState:UIControlStateNormal];
    for (NSDictionary *album in [AppDelegate getInstance].favData.data) {
        if([album objectForKey:@"url"] == self.url){
            [[self favButton]setTitle:@"取消收藏" forState:UIControlStateNormal];
            [[AppDelegate getInstance].favData setTotalCountForAlbumUrl:self.url count:[[[self albumData]sounds]count]];
            [[AppDelegate getInstance].favData setCurrentIndexForAlbumUrl:self.url index:[[[[AppDelegate getInstance].usrData getAlbumConfig:self.url]objectForKey:@"currentSongIndex"]intValue]+1];
            break;
        }
    }
    [self.favButton setEnabled:YES];
    [self.playButton setEnabled:YES];
}
- (IBAction)didFavoritButtonClicked:(id)sender {
    BOOL isFaved = NO;
    
    for (NSDictionary *album in [AppDelegate getInstance].favData.data) {
        if([[album objectForKey:@"url"] isEqualToString:self.url]){
            [[AppDelegate getInstance].favData delFav:self.url];
            [[self favButton]setTitle:@"收藏" forState:UIControlStateNormal];
            isFaved = YES;
            break;
        }
    }
    if (isFaved == NO){
        [[AppDelegate getInstance].favData addFav:self.albumData.name Sound:@"" Mod:self.mod Url:self.url];
        [[self favButton]setTitle:@"取消收藏" forState:UIControlStateNormal];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.c startAnimating];
    [[self songArrayTV]setDataSource:self];
    [[self songArrayTV]setDelegate:self];
    
    self.albumData = nil;
    [AlbumData getAlbumInfoByURL:[self url] mod:[self mod] delegate:self];
    
    UsrData *usrData = [AppDelegate getInstance].usrData;
    
    if ([[[usrData getAlbumConfig:self.url]objectForKey:@"currentSongIndex"]intValue] <= 0){
        self.lastPlayLabel.text=@"开始收听吧！";
    }else{
        self.lastPlayLabel.text=[NSString stringWithFormat:@"上次听到%d了",[[[usrData getAlbumConfig:self.url]objectForKey:@"currentSongIndex"]intValue]+1];
        [self.playButton setTitle:@"继续收听" forState:UIControlStateNormal];
    }

    NSMutableDictionary *config = [usrData getAlbumConfig:[self url]];

    [[self jStartSlider]setValue:[[config objectForKey:@"startSeekSec"]intValue]];
    [self jStartLabel].text = [NSString stringWithFormat:@"%.0fs",self.jStartSlider.value];
    [[self jEndSlider]setValue:[[config objectForKey:@"endSeekSec"]intValue]];
    [self jEndLabel].text = [NSString stringWithFormat:@"%.0fs",self.jEndSlider.value];
    [[self rateSlider]setValue:[[config objectForKey:@"rate"]floatValue]];
    [self rateLabel].text = [NSString stringWithFormat:@"%.2fx",self.rateSlider.value];
    
    [NSTimer scheduledTimerWithTimeInterval:1.0 repeats:YES block:^(NSTimer * _Nonnull timer) {
        [self updatePerSec];
    }];
    
    [self.favButton setTitle:@"加载中" forState:UIControlStateDisabled];
    [self.playButton setTitle:@"加载中" forState:UIControlStateDisabled];
    [self.favButton setEnabled:NO];
    [self.playButton setEnabled:NO];
}

- (IBAction)didBackButtonClicked:(id)sender {
    NSLog(@"didBackButtonClicked");
//    [self dismissViewControllerAnimated:YES completion:^{
//        //
//    }];
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
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
    UsrData *ud = [[AppDelegate getInstance]usrData];
    long index = [[[ud getAlbumConfig:self.url]objectForKey:@"currentSongIndex"]intValue];
    [[AppDelegate getInstance].player playFromAlbumVC:self.albumData Index:index];
    [[self songArrayTV]reloadData];
    
    self.parentViewController.tabBarController.selectedIndex =  1;

    [self.view removeFromSuperview];
    [self removeFromParentViewController];
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    if([self albumData]!=nil){
        SongCell *cell = [self.songArrayTV dequeueReusableCellWithIdentifier:@"SongCell"];
        NSDictionary *dict =[[self albumData]sounds][indexPath.row];
        cell.songLabel.text = [dict objectForKey:@"title"];
        cell.statusLabel.text = @"";

        Player *p = [[AppDelegate getInstance]player];
        if ([self.url isEqualToString:p.loadingUrl]){
            if(p.loadingIndex == indexPath.row){
                cell.statusLabel.text =@"正在准备";
            }
        }
        if ([self.url isEqualToString:p.currentUrl]){
            if(p.currentIndex == indexPath.row){
                cell.statusLabel.text =@"正在播放";
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
    [[AppDelegate getInstance].player playFromAlbumVC:self.albumData Index:indexPath.row FromBegain:YES];
    [[self songArrayTV]reloadData];
    self.parentViewController.tabBarController.selectedIndex =  1;
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
}

-(void)updatePerSec{
    [[self songArrayTV]reloadData];
}

@end
