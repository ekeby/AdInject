//
//  SampleAdTableTableViewController.m
//  AdInject
//
//  Created by Huseyin Guler on 22/10/14.
//  Copyright (c) 2014 Huseyin Guler. All rights reserved.
//

#import "SampleAdTableTableViewController.h"
#import "AdInjector.h"

#define AD_COUNT 25
#define ITEM_COUNT 100

@interface SampleAdTableTableViewController ()

@property (strong, nonatomic) NSMutableArray *tableArray;
@property (strong, nonatomic) AdInjector *injector;

@end

@implementation SampleAdTableTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableArray = [[NSMutableArray alloc] init];
    
    // insert normal table items
    for(NSInteger i=0; i<ITEM_COUNT; i++){
        [self.tableArray addObject:[NSString stringWithFormat:@"Hey! I am not an ad!"]];
    }
    
    // initialize ad injector object
    self.injector = [AdInjector giveMeAdInjector:self.tableView];
    
    // use AdInjector object to inject ads with the required parameters
    for(NSInteger i=0; i<AD_COUNT; i++){
        [self.injector injectAd:@"http://media.mobworkz.com/adserver/seamless-300x250/seamless-300x250.png"
                        atIndex:[NSNumber numberWithLong:i*(ITEM_COUNT/AD_COUNT+1)]
                        withTrackingUrl:@"http://tracker.seamlessapi.com/track/imp/huseyinGuler"];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.tableArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    
    UILabel *itemLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 250)];
    itemLabel.text = [self.tableArray objectAtIndex:indexPath.row];
    [itemLabel setTextAlignment:NSTextAlignmentCenter];
    itemLabel.backgroundColor = [UIColor grayColor];
    itemLabel.textColor = [UIColor whiteColor];
    [[cell contentView] addSubview:itemLabel];
    
    return cell;
}

@end
