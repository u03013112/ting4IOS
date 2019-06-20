//
//  UsrData.h
//  ttt
//
//  Created by 宋志京 on 2019/6/10.
//  Copyright © 2019 宋志京. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@interface UsrData : NSObject

@property (strong,nonatomic) NSString *name;
@property (strong,nonatomic) NSString *currentAlbumURL;
@property (strong,nonatomic) NSString *mod;

@property (strong,nonatomic) NSMutableDictionary *albumConfig;//基于专辑的用户配置

-(void)loadUsrData;
-(void)saveUsrData;

-(NSMutableDictionary*)getAlbumConfig:(NSString*)url;//use url for key

-(long)getCurrentStartSeekSec;
-(long)getCurrentEndSeekSec;
-(float)getCurrentRate;
-(long)getCurrentSeekSec;
-(long)getCurrentSongIndex;

-(void)setCurrentStartSeekSec:(long)s;
-(void)setCurrentEndSeekSec:(long)s;
-(void)setCurrentRate:(float)r;
-(void)setCurrentSeekSec:(long)s;
-(void)setCurrentSongIndex:(long)i;
@end

NS_ASSUME_NONNULL_END
