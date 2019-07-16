//
//  PlayerVC.h
//  ttt
//
//  Created by 宋志京 on 2019/6/9.
//  Copyright © 2019 宋志京. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PlayerVC : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *url;
@property (weak, nonatomic) IBOutlet UILabel *albumLabel;
@property (weak, nonatomic) IBOutlet UILabel *songLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UISlider *slider;

@property (weak, nonatomic) IBOutlet UILabel *nextUrl;
@property (weak, nonatomic) IBOutlet UILabel *nextStatusLabel;

@end

NS_ASSUME_NONNULL_END
