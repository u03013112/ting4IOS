//
//  SearchVC.m
//  ttt
//
//  Created by 宋志京 on 2019/6/19.
//  Copyright © 2019 宋志京. All rights reserved.
//

#import "SearchVC.h"
#import "SearchCell.h"
#import "AlbumVC.h"

@interface SearchVC ()<UITableViewDataSource,UITableViewDelegate>
@property (strong,nonatomic) NSMutableArray *retArray;
@end

@implementation SearchVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.retArray = [[NSMutableArray alloc]init];
    [[self tableView]setDataSource:self];
    [[self tableView]setDelegate:self];
}

- (IBAction)didSearchButtonClicked:(id)sender {
    NSString *name = [[self nameInput]text];
    if([name length]>0){
        [self search:name];
        [[self nameInput] resignFirstResponder];
    }
}

-(void)search:(NSString*)name{
    NSURL *url = [NSURL URLWithString:@"http://192.168.1.12:18004/search"];
    NSMutableURLRequest *mutableRequest = [NSMutableURLRequest requestWithURL:url];
    
    NSDictionary *head = [[NSDictionary alloc]initWithObjectsAndKeys:@"application/json",@"Content-Type", nil];
    NSMutableDictionary *postBodyDict = [[NSMutableDictionary alloc]init];
    [postBodyDict setObject:name forKey:@"name"];
    NSData *postData = [NSJSONSerialization dataWithJSONObject:postBodyDict options:NSJSONWritingPrettyPrinted error:nil];

    [mutableRequest setHTTPMethod:@"POST"];
    [mutableRequest setHTTPBody:postData];
    [mutableRequest setAllHTTPHeaderFields:head];
    
    NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:mutableRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error == nil) {
            NSArray *a = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            self.retArray = [[NSMutableArray alloc]init];//之前的结果不重要了
            for (NSDictionary *d in a) {//多渠道结果
                NSString *mod = [d objectForKey:@"mod"];
                NSArray *data = [d objectForKey:@"data"];
                for (NSDictionary *info in data){//
                    NSMutableDictionary *d = [[NSMutableDictionary alloc]initWithDictionary:info];
                    [d setObject:mod forKey:@"mod"];//区分渠道
                    [self.retArray addObject:d];
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"%@",[self retArray]);
                [[self tableView]reloadData];
            });
        }
    }];
    
    [task resume];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 130.0f;
}
- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    SearchCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"SearchCell"];
    
    NSDictionary *info = [self retArray][indexPath.row];
    cell.nameLabel.text = [info objectForKey:@"title"];
    cell.authorLabel.text = [info objectForKey:@"author"];
    cell.soundLabel.text = [info objectForKey:@"sound"];
    
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self retArray]count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *data = [self retArray][indexPath.row];
    NSLog(@"%@",data);
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Album" bundle:nil];
    AlbumVC *vc = [sb instantiateViewControllerWithIdentifier:@"AlbumMain"];
    vc.url = [data objectForKey:@"url"];
    vc.mod = [data objectForKey:@"mod"];
    [self presentViewController:vc animated:YES completion:^{
        //
    }];
}
@end
