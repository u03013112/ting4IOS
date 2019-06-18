//
//  UsrData.h
//  ttt
//
//  Created by 宋志京 on 2019/6/10.
//  Copyright © 2019 宋志京. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface UsrDataWithAlbum : NSObject

@property long albumIndex;
@property long currentSongIndex;

@property long startSeekSec;
@property long endSeekSec;
@property long currentSeekSec;

@property float rate;

@end

@interface UsrData : NSObject

@property (strong,nonatomic) NSString *name;

@property long currentAlbumIndex;

@property (strong,nonatomic) NSMutableDictionary *albumData;//基于专辑的用户配置

-(void)loadUsrData;
-(void)saveUsrData;

-(UsrDataWithAlbum*)getAlbumData:(long) albumIndex;

-(long)getCurrentStartSeekSec;
-(long)getCurrentEndSeekSec;
-(float)getCurrentRate;
-(float)getCurrentSeekSec;
-(void)setCurrentSeekSec:(float)c;
@end

NS_ASSUME_NONNULL_END
