//
//  ViewController.m
//  ttt
//
//  Created by 宋志京 on 2019/6/6.
//  Copyright © 2019年 宋志京. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface ViewController (){
    AVPlayer * player;
    id timeObserve;
    NSArray *songArray;
    int index;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
//    index = 0;
//    songArray = [[NSArray alloc]initWithObjects:
//                 [NSURL URLWithString:@"http://mp3-f.ting89.com:9090/%E5%87%A1%E4%BA%BA%E4%BF%AE%E4%BB%99%E4%BC%A0/%E5%87%A1%E4%BA%BA%E4%BF%AE%E4%BB%99%E4%BC%A0001.mp3"],
//                 [NSURL URLWithString:@"http://mp3-f.ting89.com:9090/%E5%87%A1%E4%BA%BA%E4%BF%AE%E4%BB%99%E4%BC%A0/%E5%87%A1%E4%BA%BA%E4%BF%AE%E4%BB%99%E4%BC%A0002.mp3"],
//                 nil];
//
//    NSURL * url  = [NSURL URLWithString:@"http://mp3-f.ting89.com:9090/%E5%87%A1%E4%BA%BA%E4%BF%AE%E4%BB%99%E4%BC%A0/%E5%87%A1%E4%BA%BA%E4%BF%AE%E4%BB%99%E4%BC%A0001.mp3"];
//    AVPlayerItem * songItem = [[AVPlayerItem alloc]initWithURL:url];
//    player = [[AVPlayer alloc]initWithPlayerItem:songItem];
//
//    NSLog(@"total:%f\n",CMTimeGetSeconds(songItem.duration));
//
//    [songItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
//
//    timeObserve = [player addPeriodicTimeObserverForInterval:CMTimeMake(1.0, 1.0) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
//        float current = CMTimeGetSeconds(time);
//        float total = CMTimeGetSeconds(songItem.duration);
//        if (current) {
//            NSLog(@"%@/%@\n",[NSString stringWithFormat:@"%.f",current],[NSString stringWithFormat:@"%.2f",total]);
//        }
//    }];
//
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:songItem];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"status"]) {
        switch (player.status) {
            case AVPlayerStatusUnknown:
                NSLog(@"KVO：未知状态，此时不能播放");
                break;
            case AVPlayerStatusReadyToPlay:
                NSLog(@"KVO：准备完毕，可以播放");
                NSLog(@"total:%f\n",CMTimeGetSeconds(player.currentItem.duration));
                break;
            case AVPlayerStatusFailed:
                NSLog(@"KVO：加载失败，网络或者服务器出现问题");
                break;
            default:
                break;
        }
    }
}

- (void)playbackFinished:(NSNotification *)notice {
    NSLog(@"播放完成");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)didPlayButtonClicked{
    NSLog(@"didPlayButtonClicked");
    [player play];
}

-(IBAction)didPauseButtonClicked{
    NSLog(@"didPauseButtonClicked");
    [player pause];
}

-(IBAction)didNextButtonClicked{
    NSLog(@"didNextButtonClicked");
    if (index<[songArray count]-1){
        index ++;
        AVPlayerItem * songItem = [[AVPlayerItem alloc]initWithURL:songArray[index]];
        [songItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
        [player replaceCurrentItemWithPlayerItem:songItem];
    }
}

-(IBAction)didPrevButtonClicked{
    NSLog(@"didPrevButtonClicked");
    if (index>0){
        index --;
        [player replaceCurrentItemWithPlayerItem:songArray[index]];
    }
}
- (IBAction)didTestButtonClicked:(id)sender {
    NSLog(@"didTestButtonClicked");
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Player" bundle:nil];
    UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"PlayerVC"];

    [self addChildViewController:vc];
    [self.view addSubview:vc.view];
//    [self presentViewController:vc animated:YES completion:^{
//
//    }];
}
@end
