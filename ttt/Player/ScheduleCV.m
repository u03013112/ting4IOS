//
//  ScheduleCV.m
//  ttt
//
//  Created by 宋志京 on 2019/6/16.
//  Copyright © 2019 宋志京. All rights reserved.
//

#import "ScheduleCV.h"
#import "../AppDelegate.h"

@interface ScheduleCV ()
@property (weak, nonatomic) IBOutlet UISlider *slider;
@property (weak, nonatomic) IBOutlet UILabel *sliderLabel;

@end

@implementation ScheduleCV

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
- (IBAction)didBackButtonClicked:(id)sender {
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
}

- (IBAction)didSliderChanged:(id)sender {
    int v = (int)[[self slider]value];
    int v1 = v/10*10;
    [[self slider]setValue:v1];
    [self sliderLabel].text=[NSString stringWithFormat:@"%d分钟",v1];
}
- (IBAction)cancalSchedule:(id)sender {
    [[AppDelegate getInstance]player].scheduleSec = -1;
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
}
- (IBAction)didConfirmButtonClicked:(id)sender {
    [[AppDelegate getInstance]player].scheduleSec = [[self slider]value]*60;
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
}


@end

