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
    for(int i=0; i<ITEM_COUNT; i++){
        [self.tableArray addObject:[NSString stringWithFormat:@"Hey! I am not an ad!"]];
    }
    
    // initialize ad injector object
    self.injector = [AdInjector giveMeAdInjector:self.tableView];
    
    // use AdInjector object to inject ads with the required parameters
    // to be shown in the table view
    for(int i=0; i<AD_COUNT; i++){
        [self.injector injectAd:@"http://media.mobworkz.com/adserver/seamless-300x250/"
                        atIndex:(i*5)
                        withTrackingUrl:@"http://tracker.seamlessapi.com/track/imp/huseyinGuler"];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.tableArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    
    UILabel *itemLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, 300, 200)];
    itemLabel.text = @"Hey! I am not an ad!";
    [[cell contentView] addSubview:itemLabel];
    
    return cell;
}

@end
