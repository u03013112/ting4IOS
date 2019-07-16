//
//  FavoritesCell.h
//  ttt
//
//  Created by 宋志京 on 2019/7/13.
//  Copyright © 2019 宋志京. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FavoritesCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *authorLabel;
@property (weak, nonatomic) IBOutlet UILabel *soundLabel;
@property (weak, nonatomic) IBOutlet UILabel *modLabel;

@end

NS_ASSUME_NONNULL_END
