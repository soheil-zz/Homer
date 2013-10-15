//
//  HomerViewController.m
//  Homer
//
//  Created by Soheil Yasrebi on 10/15/13.
//  Copyright (c) 2013 Soheil Yasrebi. All rights reserved.
//

#import "HomerViewController.h"

@interface HomerViewController ()
{
    NSMutableArray *users;
    int perPage;
}

@end

@implementation HomerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Homer Stackoverflow Demo";
    
    self.viewDataSource = self;
    self.viewDelegate = self;
    
    NSString *url = @"http://api.stackoverflow.com/1.1/users";
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
        [self performSelectorOnMainThread:@selector(fetchedData:)
                               withObject:data waitUntilDone:YES];
    });
}

- (void)fetchedData:(NSData *)responseData
{
    NSLog(@"fetchedData");
    NSError* error;
    NSDictionary* json = [NSJSONSerialization JSONObjectWithData:responseData
                                                         options:kNilOptions
                                                           error:&error];
    
    users = [json objectForKey:@"users"];
    [self.homescreenView reloadData];
}

- (int)getFlattenIndexWithHomescreenView:(UIHomescreenView *)homescreenView withIndexPath3D:(IndexPath3D *)indexPath
{
    perPage = (int)(homescreenView.rows * homescreenView.columns);
    return (int)(indexPath.page * perPage + indexPath.row * homescreenView.columns + indexPath.column);
}

#pragma mark -
#pragma mark UIHomescreenController Datasource

- (UIHomescreenIcon *)homescreenView:(UIHomescreenView *)homescreenView iconForPositionAtIndexPath3D:(IndexPath3D *)indexPath
{
    UIHomescreenIcon *icon;
    
    int index = [self getFlattenIndexWithHomescreenView:homescreenView withIndexPath3D:indexPath];
    if (!users || index >= users.count) return icon;
    
    NSString *imageURL = [NSString stringWithFormat:@"http://www.gravatar.com/avatar/%@?s=64&d=identicon&r=PG", [users[index] objectForKey:@"email_hash"]];
    icon = [[UIHomescreenIcon alloc] initWithImageURL:imageURL];
    
    icon.label.text = [users[index] objectForKey:@"display_name"];

    return icon;
}

#pragma mark -
#pragma mark UIHomescreenController Delegate

- (void)homescreenView:(UIHomescreenView *)homescreenView didSelectRowAtIndexPath3D:(IndexPath3D *)indexPath
{
    int index = [self getFlattenIndexWithHomescreenView:homescreenView withIndexPath3D:indexPath];
    NSLog(@"tapped %d, %d, %d, flattened index: %d", indexPath.page, indexPath.row, indexPath.column, index);
    UIViewController *vc = [[UIViewController alloc] init];
    
    vc.title = [users[index] objectForKey:@"display_name"];
    
    vc.view.backgroundColor = [UIColor grayColor];
    
    UILabel *location = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 120)];
    [location setFont:[UIFont systemFontOfSize:22]];
    location.textAlignment = NSTextAlignmentCenter;
    location.text = [users[index] objectForKey:@"location"];
    [vc.view addSubview:location];
    
    [self.navigationController pushViewController:vc animated:YES];
}

@end
