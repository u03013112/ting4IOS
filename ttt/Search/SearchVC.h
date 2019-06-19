//
//  SearchVC.h
//  ttt
//
//  Created by 宋志京 on 2019/6/19.
//  Copyright © 2019 宋志京. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SearchVC : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *nameInput;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

NS_ASSUME_NONNULL_END
