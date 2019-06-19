//
//  UsrData.m
//  ttt
//
//  Created by 宋志京 on 2019/6/10.
//  Copyright © 2019 宋志京. All rights reserved.
//

#import "UsrData.h"
@implementation UsrData

-(id)init{
    if(self = [super init]){
        self.albumConfig = [[NSMutableDictionary alloc]init];
    }
    return self;
}

-(void)loadUsrData{
    NSDictionary *dict = [[NSUserDefaults standardUserDefaults]objectForKey:@"save"];
    if (dict == nil){
        [self defaultUsrData];
    }else{
        self.name = [dict objectForKey:@"name"];
        self.currentAlbumURL = [dict objectForKey:@"currentAlbumURL"];
        self.mod = [dict objectForKey:@"mod"];
        self.albumConfig = [dict objectForKey:@"albumConfig"];
    }
    NSLog(@"loaded");
}
-(void)defaultUsrData{
    self.name = @"u0";
}

+ (NSString *)getDocumentPath{
    NSArray *filePaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [filePaths objectAtIndex:0];
}

-(void)saveUsrData{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
    
    [dict setObject:self.name forKey:@"name"];
    [dict setObject:self.currentAlbumURL forKey:@"currentAlbumURL"];
    [dict setObject:self.mod forKey:@"mod"];
    [dict setObject:self.albumConfig forKey:@"albumConfig"];
//    转成json备用
    if ([NSJSONSerialization isValidJSONObject:dict]){
        NSData *jdata = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
        NSLog(@"%@",[[NSString alloc]initWithData:jdata encoding:NSUTF8StringEncoding]);
    }
    [[NSUserDefaults standardUserDefaults]setObject:dict forKey:@"save"];
    [[NSUserDefaults standardUserDefaults]synchronize];
}

-(NSDictionary*)getAlbumConfig:(NSString*)url{
    NSMutableDictionary *config = [[self albumConfig]objectForKey:url];
    if (config == nil){
        config = [[NSMutableDictionary alloc]initWithObjectsAndKeys:url,@"url",[NSNumber numberWithFloat:1.0],@"rate", nil];
        [[self albumConfig]setObject:config forKey:url];
    }
    return config;
}

-(long)getCurrentStartSeekSec{
    NSDictionary *config = [[self albumConfig]objectForKey:self.currentAlbumURL];
    if (config == nil){
        return 0;
    }
    return [[config objectForKey:@"startSeekSec"]intValue];
}

-(long)getCurrentEndSeekSec{
    NSDictionary *config = [[self albumConfig]objectForKey:self.currentAlbumURL];
    if (config == nil){
        return 0;
    }
    return [[config objectForKey:@"endSeekSec"]intValue];
}

-(float)getCurrentRate{
    NSDictionary *config = [[self albumConfig]objectForKey:self.currentAlbumURL];
    if (config == nil){
        return 1.0;
    }
    return [[config objectForKey:@"rate"]floatValue];
}
-(long)getCurrentSeekSec{
    NSDictionary *config = [[self albumConfig]objectForKey:self.currentAlbumURL];
    if (config == nil){
        return 0;
    }
    return [[config objectForKey:@"currentSeekSec"]intValue];
}
-(long)getCurrentSongIndex{
    NSDictionary *config = [[self albumConfig]objectForKey:self.currentAlbumURL];
    if (config == nil){
        return 0;
    }
    return [[config objectForKey:@"currentSongIndex"]intValue];
}


-(void)setCurrentStartSeekSec:(long)s{
    NSMutableDictionary *config = [[self albumConfig]objectForKey:self.currentAlbumURL];
    if (config != nil){
        [config setObject:[NSNumber numberWithInteger:s] forKey:@"startSeekSec"];
        [self saveUsrData];
    }
}
-(void)setCurrentEndSeekSec:(long)s{
    NSMutableDictionary *config = [[self albumConfig]objectForKey:self.currentAlbumURL];
    if (config != nil){
        [config setObject:[NSNumber numberWithInteger:s] forKey:@"endSeekSec"];
        [self saveUsrData];
    }
}
-(void)setCurrentRate:(float)r{
    NSMutableDictionary *config = [[self albumConfig]objectForKey:self.currentAlbumURL];
    if (config != nil){
        [config setObject:[NSNumber numberWithFloat:r] forKey:@"rate"];
        [self saveUsrData];
    }
}

-(void)setCurrentSeekSec:(long)s{
    NSMutableDictionary *config = [[self albumConfig]objectForKey:self.currentAlbumURL];
    if (config != nil){
        [config setObject:[NSNumber numberWithInteger:s] forKey:@"currentSeekSec"];
        [self saveUsrData];
    }
}
-(void)setCurrentSongIndex:(long)i{
    NSMutableDictionary *config = [[self albumConfig]objectForKey:self.currentAlbumURL];
    if (config != nil){
        [config setObject:[NSNumber numberWithInteger:i] forKey:@"currentSongIndex"];
        [self saveUsrData];
    }
}
@end
