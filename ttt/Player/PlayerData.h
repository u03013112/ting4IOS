//
//  PlayerData.h
//  ttt
//
//  Created by 宋志京 on 2019/6/9.
//  Copyright © 2019 宋志京. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PlayerData : NSObject

+(PlayerData*) getInstance;

-(NSString*)getCurrentAlbumName;
-(NSString*)getCurrentSongName;
-(NSString*)getCurrentSongUrl;

-(NSString*)getNextSongUrl;
-(NSString*)getprevSongUrl;

@end

NS_ASSUME_NONNULL_END
