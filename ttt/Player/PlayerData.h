//
//  PlayerData.h
//  ttt
//
//  Created by 宋志京 on 2019/6/9.
//  Copyright © 2019 宋志京. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "../PlayList/AlbumData.h"
NS_ASSUME_NONNULL_BEGIN

@interface PlayerData : NSObject
@property (strong,nonatomic)AlbumData *albumData;

+(PlayerData*) getInstance;

-(NSString*)getCurrentAlbumName;
-(NSString*)getCurrentSongName;

-(void)getSongUrl:(NSString*)mod URL:(NSString*)url Index:(long)index FromBegain:(BOOL) isFromBegain;

@end

NS_ASSUME_NONNULL_END
