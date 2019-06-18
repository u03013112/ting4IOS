//
//  PlayListVC.h
//  ttt
//
//  Created by 宋志京 on 2019/6/8.
//  Copyright © 2019 宋志京. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PlayListVC : UIViewController <UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *playlistTV;
@property (weak, nonatomic) IBOutlet UILabel *lastLabel;
@end

NS_ASSUME_NONNULL_END
