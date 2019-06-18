//
//  PlayListData.h
//  ttt
//
//  Created by 宋志京 on 2019/6/8.
//  Copyright © 2019 宋志京. All rights reserved.
//

#ifndef PlayListData_h
#define PlayListData_h

@protocol AlbumDataDelegate<NSObject>
@required
-(void)didAlbumDataChanged;
@end

@interface SongInfo : NSObject{
    @public
    NSString *name;
    NSString *url;
}
@end

@interface AlbumInfo : NSObject<NSURLConnectionDataDelegate>{
    @public
    NSString *name;
    NSArray *songInfoArray;
};
-(id)initWithName:(NSString *)name SongArray:(NSArray*)songInfoArray;

@end

@interface AlbumData : NSObject
@property (strong,nonatomic) NSMutableArray *AlbumArray;//所有专辑列表
@property (strong,nonatomic) id<AlbumDataDelegate> delegate;

+(AlbumData*) getInstance;

@end

#endif /* PlayListData_h */
