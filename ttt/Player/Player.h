//
//  Player.h
//  ttt
//
//  Created by 宋志京 on 2019/6/9.
//  Copyright © 2019 宋志京. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "../PlayList/AlbumData.h"

NS_ASSUME_NONNULL_BEGIN

@interface Player : NSObject

@property bool isPlaying;
@property (strong, nonatomic) id timeObserve;
@property (strong, nonatomic) AVPlayer *player;
@property long scheduleSec;

-(void)playFromAlbumVC:(AlbumData*)ad Index:(long)index;

-(void)playWithUrl:(NSString *)url;
-(void)pause;
-(void)resume;
-(void)nextSong;
-(void)prevSong;

@end

NS_ASSUME_NONNULL_END
