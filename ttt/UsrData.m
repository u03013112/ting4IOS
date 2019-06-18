//
//  UsrData.m
//  ttt
//
//  Created by 宋志京 on 2019/6/10.
//  Copyright © 2019 宋志京. All rights reserved.
//

#import "UsrData.h"

@implementation UsrDataWithAlbum

@end

@implementation UsrData

-(id)init{
    if(self = [super init]){
        self.albumData = [[NSMutableDictionary alloc]init];
    }
    return self;
}

-(void)loadUsrData{
//    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"save"];
    NSDictionary *dict = [[NSUserDefaults standardUserDefaults]objectForKey:@"save"];
    if (dict == nil){
        [self defaultUsrData];
        UsrDataWithAlbum *a0= [self getAlbumData:0];
        a0.currentSongIndex =[[NSUserDefaults standardUserDefaults] integerForKey:@"index"];
    }else{
        self.currentAlbumIndex = [[dict objectForKey:@"currentAlbumIndex"]integerValue];
        
        for (NSString *key in [[dict objectForKey:@"albumData"] allKeys]) {
            NSDictionary *d =[[dict objectForKey:@"albumData"]objectForKey:key];
            UsrDataWithAlbum *u0 = [[UsrDataWithAlbum alloc]init];
            u0.albumIndex = [[d objectForKey:@"albumIndex"]integerValue];
            u0.currentSongIndex = [[d objectForKey:@"currentSongIndex"]integerValue];
            u0.startSeekSec = [[d objectForKey:@"startSeekSec"]integerValue];
            u0.endSeekSec = [[d objectForKey:@"endSeekSec"]integerValue];
            u0.currentSeekSec = [[d objectForKey:@"currentSeekSec"]integerValue];
            u0.rate = [[d objectForKey:@"rate"]floatValue];
            [[self albumData]setObject:u0 forKey:key];
        }
    }
    NSLog(@"loaded");
}
-(void)defaultUsrData{
    self.name = @"u0";
    self.currentAlbumIndex = 0;
    
    UsrDataWithAlbum *data = [[UsrDataWithAlbum alloc]init];
    data.albumIndex = 0;
    data.startSeekSec = 20;
    data.endSeekSec = 20;
    data.rate = 1.15;

    [[self albumData]setValue:data forKey:[NSString stringWithFormat:@"0"]];
}

+ (NSString *)getDocumentPath{
    NSArray *filePaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [filePaths objectAtIndex:0];
}

-(void)saveUsrData{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
    
    [dict setObject:[NSNumber numberWithInteger:[self currentAlbumIndex]] forKey:@"currentAlbumIndex"];
    
    NSMutableDictionary *albumDict = [[NSMutableDictionary alloc]init];
    for (NSString *key in [[self albumData]allKeys]) {
        NSMutableDictionary *albumData = [[NSMutableDictionary alloc]init];
        UsrDataWithAlbum *data = [[self albumData]objectForKey:key];
        [albumData setObject:[NSNumber numberWithInteger:[data albumIndex]] forKey:@"albumIndex"];
        [albumData setObject:[NSNumber numberWithInteger:[data currentSongIndex]] forKey:@"currentSongIndex"];
        [albumData setObject:[NSNumber numberWithInteger:[data startSeekSec]] forKey:@"startSeekSec"];
        [albumData setObject:[NSNumber numberWithInteger:[data endSeekSec]] forKey:@"endSeekSec"];
        [albumData setObject:[NSNumber numberWithInteger:[data currentSeekSec]] forKey:@"currentSeekSec"];
        [albumData setObject:[NSNumber numberWithFloat:[data rate]] forKey:@"rate"];
        [albumDict setObject:albumData forKey:key];
    }
    [dict setObject:albumDict forKey:@"albumData"];
//    转成json备用
    if ([NSJSONSerialization isValidJSONObject:dict]){
        NSData *jdata = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
        NSLog(@"%@",[[NSString alloc]initWithData:jdata encoding:NSUTF8StringEncoding]);
    }
    [[NSUserDefaults standardUserDefaults]setObject:dict forKey:@"save"];
    [[NSUserDefaults standardUserDefaults]synchronize];
}

-(UsrDataWithAlbum*)getAlbumData:(long) albumIndex{
    UsrDataWithAlbum *data = [[self albumData]objectForKey:[NSString stringWithFormat:@"%ld",albumIndex]];
    if (data == nil){
        data = [[UsrDataWithAlbum alloc]init];
        data.albumIndex = albumIndex;
        data.rate = 1.0;
        
        [[self albumData]setValue:data forKey:[NSString stringWithFormat:@"%ld",albumIndex]];
    }
    return data;
}

-(long)getCurrentStartSeekSec{
    UsrDataWithAlbum *data = [[self albumData]objectForKey:[NSString stringWithFormat:@"%ld",self.currentAlbumIndex]];
    if (data == nil){
        return 0;
    }
    return data.startSeekSec;
}

-(long)getCurrentEndSeekSec{
    UsrDataWithAlbum *data = [[self albumData]objectForKey:[NSString stringWithFormat:@"%ld",self.currentAlbumIndex]];
    if (data == nil){
        return 0;
    }
    return data.endSeekSec;
}

-(float)getCurrentRate{
    UsrDataWithAlbum *data = [[self albumData]objectForKey:[NSString stringWithFormat:@"%ld",self.currentAlbumIndex]];
    if (data == nil){
        return 1.0;
    }
    return data.rate;
}
-(float)getCurrentSeekSec{
    UsrDataWithAlbum *data = [[self albumData]objectForKey:[NSString stringWithFormat:@"%ld",self.currentAlbumIndex]];
    if (data == nil){
        return .0;
    }
    return data.currentSeekSec;
}
-(void)setCurrentSeekSec:(float)c{
    UsrDataWithAlbum *data = [[self albumData]objectForKey:[NSString stringWithFormat:@"%ld",self.currentAlbumIndex]];
    if (data != nil){
        data.currentSeekSec = c;
    }
}
@end
