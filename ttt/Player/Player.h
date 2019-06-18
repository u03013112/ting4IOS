//
//  Player.h
//  ttt
//
//  Created by 宋志京 on 2019/6/9.
//  Copyright © 2019 宋志京. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Player : NSObject

@property bool isPlaying;
@property (strong, nonatomic) id timeObserve;
@property (strong, nonatomic) AVPlayer *player;
@property long scheduleSec;

//+(Player*)getInstance; 统一放到appdelegate里去做唯一

-(void)play;
-(void)pause;
-(void)resume;
-(void)nextSong;
-(void)prevSong;

@end

NS_ASSUME_NONNULL_END
