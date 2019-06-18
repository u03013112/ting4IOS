//
//  PlayListData.m
//  ttt
//
//  Created by 宋志京 on 2019/6/8.
//  Copyright © 2019 宋志京. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AlbumData.h"

@implementation SongInfo
@end

@implementation AlbumInfo
-(id)initWithName:(NSString *)name SongArray:(NSArray*)songInfoArray{
    if (self = [super init]){
        self->name = name;
        self->songInfoArray = songInfoArray;
    }
    return self;
}
@end

@implementation AlbumData

AlbumData* instance = nil;

+(AlbumData*) getInstance{
    if(instance == nil){
        instance = [[AlbumData alloc]init];
    }
    return instance;
}

-(id)init{
    if (self = [super init]){
        self.AlbumArray = [[NSMutableArray alloc]init];
        [self getHTTPAlbumInfo];
    }
    return self;
}

-(void)getHTTPAlbumInfo{
//    NSString *urlString = @"http://frp.u03013112.win:18002/album";
    NSString *urlString = @"http://frp.u03013112.win:18002/album/album.json";
    NSURL *url = [NSURL URLWithString:urlString];

    NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSString *str = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"%ld>>%@",[str length],str);
        NSArray *a = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        for (NSDictionary *d in a) {
            if([[d objectForKey:@"md5"]length]>0){
                //                check here
            }
            if ([[d objectForKey:@"type"]isEqual:@"http"]){
                NSData * urlData =[NSData dataWithContentsOfURL:[NSURL URLWithString:[d objectForKey:@"url"]]];
                NSArray *jsonData = [NSJSONSerialization JSONObjectWithData:urlData options:NSJSONReadingAllowFragments error:nil];
                NSMutableArray *array = [[NSMutableArray alloc]init];
                for (NSDictionary *dict in jsonData) {
                    SongInfo *s = [[SongInfo alloc]init];
                    s->name = [dict objectForKey:@"title"];
                    s->url = [dict objectForKey:@"url"];
                    [array addObject:s];
                }
                AlbumInfo *info = [[AlbumInfo alloc]initWithName:[d objectForKey:@"title"] SongArray:[[NSArray alloc]initWithArray:array]];
                [[self AlbumArray] addObject:info];
            }
        }
        //        delegate here
        if([self delegate]!=nil){
            dispatch_async(dispatch_get_main_queue(), ^{
                [[self delegate]didAlbumDataChanged];
            });
            
        }
    }];
    
    [dataTask resume];
}
@end
