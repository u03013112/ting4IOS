//
//  PlayListData.m
//  ttt
//
//  Created by 宋志京 on 2019/6/8.
//  Copyright © 2019 宋志京. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AlbumData.h"

@implementation AlbumData

+(void) getAlbumInfoByURL:(NSString *)urlIN mod:(NSString *)mod delegate:(id<AlbumDataDelegate>)delegate{
    
    NSURL *url = [NSURL URLWithString:@"http://192.168.1.12:18004/getalbumData"];
    NSMutableURLRequest *mutableRequest = [NSMutableURLRequest requestWithURL:url];
    
    NSDictionary *head = [[NSDictionary alloc]initWithObjectsAndKeys:@"application/json",@"Content-Type", nil];
    NSMutableDictionary *postBodyDict = [[NSMutableDictionary alloc]init];
    [postBodyDict setObject:mod forKey:@"mod"];
    [postBodyDict setObject:urlIN forKey:@"url"];
    NSData *postData = [NSJSONSerialization dataWithJSONObject:postBodyDict options:NSJSONWritingPrettyPrinted error:nil];
    
    [mutableRequest setHTTPMethod:@"POST"];
    [mutableRequest setHTTPBody:postData];
    [mutableRequest setAllHTTPHeaderFields:head];
    
    NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:mutableRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error == nil) {
            AlbumData *albumInfo = [[AlbumData alloc]init];
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            albumInfo.url = urlIN;
            albumInfo.mod = mod;
            albumInfo.name = [dict objectForKey:@"title"];
            albumInfo.sounds = [[NSMutableArray alloc]init];
            NSArray *sounds = [dict objectForKey:@"sounds"];
            for (NSDictionary *d in sounds){
                NSDictionary *sound = [[NSDictionary alloc]initWithDictionary:d];
                [albumInfo.sounds addObject:sound];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [delegate didAlbumDataRecv:albumInfo];
            });
        }
    }];
    
    [task resume];
}
@end
