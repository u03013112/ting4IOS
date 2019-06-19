//
//  AlbumVC.h
//  ttt
//
//  Created by 宋志京 on 2019/6/8.
//  Copyright © 2019 宋志京. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AlbumVC : UIViewController<UITableViewDataSource,UITableViewDelegate>

@property (strong,nonatomic) NSString *url;//用url做key
@property (strong,nonatomic) NSString *mod;//mod只是参考，应该不会冲突

@end

NS_ASSUME_NONNULL_END
