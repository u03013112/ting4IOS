//
//  PlayListData.h
//  ttt
//
//  Created by 宋志京 on 2019/6/8.
//  Copyright © 2019 宋志京. All rights reserved.
//

#ifndef PlayListData_h
#define PlayListData_h

@protocol AlbumDataDelegate;

@interface AlbumData : NSObject
@property (strong,nonatomic) id<AlbumDataDelegate> delegate;
//暂时就这么多内容
@property (strong,nonatomic) NSString *name;
@property (strong,nonatomic) NSMutableArray *sounds;

//为http版本，只能先引用，然后等着结果，有了结果再根据结果做事
+(void) getAlbumInfoByURL:(NSString *)url mod:(NSString *)mod delegate:(id<AlbumDataDelegate>)delegate;

@end

@protocol AlbumDataDelegate<NSObject>
@required
-(void)didAlbumDataRecv:(AlbumData*)data;
@end

#endif /* PlayListData_h */
