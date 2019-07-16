//
//  FavoritesVC.m
//  ttt
//
//  Created by u03013112 on 2019/6/21.
//  Copyright © 2019 宋志京. All rights reserved.
//

#import "FavoritesVC.h"
#import "../PlayList/AlbumVC.h"
#import "../PlayList/AlbumData.h"
#import "../AppDelegate.h"
#import "FavoritesData.h"
#import "FavoritesCell.h"

@interface FavoritesVC ()<UITableViewDataSource,UITableViewDelegate,FavoritesDataDelegate>
@property (weak, nonatomic) IBOutlet UILabel *lastLabel;
@property (weak, nonatomic) IBOutlet UILabel *loadingLabel;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UILabel *scheduleLabel;
@property (weak, nonatomic) IBOutlet UITableView *AlbumTV;

@end

@implementation FavoritesVC

-(void)didFavoritesDataChanged{
    [self.AlbumTV reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    for (NSMutableDictionary *d in [AppDelegate getInstance].favData.data) {
        if([d objectForKey:@"title"]==nil){
            [[AppDelegate getInstance].favData.data removeObject:d];
        }
    }
    
    [[self AlbumTV]setDelegate:self];
    [[self AlbumTV]setDataSource:self];
    [[AppDelegate getInstance].favData addDelegate:self];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 100.0f;
}
- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    FavoritesCell *cell = [self.AlbumTV dequeueReusableCellWithIdentifier:@"FavoritesCell"];
    
    NSDictionary *info = [AppDelegate getInstance].favData.data[indexPath.row];
    cell.nameLabel.text = [info objectForKey:@"title"];
    cell.authorLabel.text = [info objectForKey:@"mod"];
    int index = [[info objectForKey:@"currentIndex"]intValue];
    NSUInteger total = [[info objectForKey:@"totalCount"]unsignedIntegerValue];
    if (index >0){
        cell.soundLabel.text = [NSString stringWithFormat:@"上次听到 %d 集， 本专辑共 %lu 集",index,(unsigned long)total];
    }else{
        cell.soundLabel.text = @"";
    }
    
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[AppDelegate getInstance].favData.data count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *data = [AppDelegate getInstance].favData.data[indexPath.row];
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Album" bundle:nil];
    AlbumVC *vc = [sb instantiateViewControllerWithIdentifier:@"AlbumMain"];
    vc.url = [data objectForKey:@"url"];
    vc.mod = [data objectForKey:@"mod"];

    [self addChildViewController:vc];
    [self.view addSubview:vc.view];
}
- (IBAction)didReflushButtonClicked:(id)sender {
    [[self AlbumTV]reloadData];
}

-(void)viewWillAppear:(BOOL)animated{
    [[AppDelegate getInstance].favData addDelegate:self];
    [self.AlbumTV reloadData];
    [super viewWillAppear:animated];
}
- (void)viewDidDisappear:(BOOL)animated {
    [[AppDelegate getInstance].favData removeDelegate:self];
    [super viewDidDisappear:animated];
}

@end
