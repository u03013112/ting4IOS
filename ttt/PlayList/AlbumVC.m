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
    NSLog(@"%@",data.sounds[0]);
    self.albumData = data;
    [self.songArrayTV reloadData];
    [self.songArrayTV setContentOffset:CGPointMake(0, 44*[[[[AppDelegate getInstance].usrData getAlbumConfig:self.url]objectForKey:@"currentSongIndex"]intValue])];
    [self ntitle].title=self.albumData.name;
    [self.c removeFromSuperview];
}
- (IBAction)didFavoritButtonClicked:(id)sender {
    BOOL isFaved = NO;
    UsrData *usrData = [AppDelegate getInstance].usrData;
    for (NSDictionary *album in [usrData albumFavorites]) {
        if([album objectForKey:@"url"] == self.url){
            [[usrData albumFavorites]removeObject:album];
            [[self favButton]setTitle:@"收藏" forState:UIControlStateNormal];
            isFaved = YES;
            break;
        }
    }
    if (isFaved == NO){
        NSMutableDictionary *album = [[NSMutableDictionary alloc]initWithObjectsAndKeys:self.albumData.name,@"title",self.mod,@"mod",self.url,@"url", nil];
        [[usrData albumFavorites]addObject:album];
        [[self favButton]setTitle:@"取消收藏" forState:UIControlStateNormal];
    }
    [usrData saveUsrData];
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
    
    for (NSDictionary *album in [usrData albumFavorites]) {
        if([album objectForKey:@"url"] == self.url){
            [[self favButton]setTitle:@"取消收藏" forState:UIControlStateNormal];
            break;
        }
    }
    
    [NSTimer scheduledTimerWithTimeInterval:1.0 repeats:YES block:^(NSTimer * _Nonnull timer) {
        [self updatePerSec];
    }];
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
//    [self dismissViewControllerAnimated:YES completion:^{
//    }];
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    if([self albumData]!=nil){
        SongCell *cell = [self.songArrayTV dequeueReusableCellWithIdentifier:@"SongCell"];
        NSDictionary *dict =[[self albumData]sounds][indexPath.row];
        cell.songLabel.text = [dict objectForKey:@"title"];
        cell.statusLabel.text = @"";
//        NSDictionary *config =[[AppDelegate getInstance].usrData getAlbumConfig:self.url];
//        if ([[config objectForKey:@"currentSongIndex"]intValue]==indexPath.row){
//            cell.statusLabel.text = @"上次播放";
//        }
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
//    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Player" bundle:nil];
//    AlbumVC *vc = [sb instantiateViewControllerWithIdentifier:@"PlayerVC"];
//    [self addChildViewController:vc];
//    [self.view addSubview:vc.view];
    self.parentViewController.tabBarController.selectedIndex =  1;
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
}

-(void)updatePerSec{
    [[self songArrayTV]reloadData];
}

@end
