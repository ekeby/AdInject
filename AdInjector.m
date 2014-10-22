//
//  AdInjectLibrary.m
//  AdInjectLibrary
//
//  Created by Huseyin Guler on 22/10/14.
//  Copyright (c) 2014 Huseyin Guler. All rights reserved.
//

#import "AdInjector.h"

@interface AdInjector () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *adTable;
@property (nonatomic, strong) NSMutableArray *adIndices;
@property (nonatomic, strong) NSMutableDictionary *adTrackingUrls;
@property (nonatomic, strong) NSMutableDictionary *adUrls;
@property (nonatomic, strong) id<UITableViewDataSource> userSource;
@property (nonatomic, strong) id<UITableViewDelegate> userDelegate;

@end

@implementation AdInjector

+(instancetype)giveMeAdInjector:(UITableView *)tableView
{
    AdInjector *injector = [[AdInjector alloc] initAdInjectorWithTable:tableView];
    return injector;
}

/*
 creates and initializes the AdInjector object with user's table view
 and also initializes dictionaries and arrays to hold indices, adUrls
 and trackingUrls provided by the user
 */
-(AdInjector *) initAdInjectorWithTable: (UITableView *) tableView
{
    self.adTable = tableView;
    self.userSource = tableView.dataSource;
    self.userDelegate = tableView.delegate;
    tableView.dataSource = self;
    tableView.delegate = self;
    
    self.adIndices = [[NSMutableArray alloc] init];
    self.adUrls = [[NSMutableDictionary alloc] init];
    self.adTrackingUrls = [[NSMutableDictionary alloc] init];
    
    return self;
}

- (void)injectAd:(NSString *)adUrl atIndex:(NSUInteger) index withTrackingUrl:(NSString *) trackingUrl
{
    [self.adIndices addObject:[NSNumber numberWithLong:index]];
    [self.adUrls setObject:trackingUrl forKey:[NSNumber numberWithLong:index]];
    [self.adTrackingUrls setObject:trackingUrl forKey:[NSNumber numberWithLong:index]];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    [self.adTable insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

-(BOOL)indexCheck:(NSUInteger) index
{
    // Since we will have only 25 ads brute force search is implemented.
    // In production a better search can be applied (e.g. binary search by sorting the indices)
    for(int i=0; i<[self.adIndices count]; i++){
        if([[self.adIndices objectAtIndex:i] integerValue] == index)
            return YES;
    }
    return NO;
}

//method to check if 50% of the row frame is visible on the table view
-(BOOL)checkIfPartiallyVisible:(NSIndexPath *)indexPath
{
    CGRect cellFrame = [self.adTable rectForRowAtIndexPath:indexPath];
    if (cellFrame.origin.y < self.adTable.contentOffset.y) { // the row is above visible rect
        //[self.adTable scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
        return NO;
    }
    else if(cellFrame.origin.y + (cellFrame.size.height/2) > (self.adTable.contentOffset.y + self.adTable.frame.size.height) - (self.adTable.contentInset.top-self.adTable.contentInset.bottom)){ // the row is below visible rect
        //[self.adTable scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
        return NO;
    }
    return YES;
}

#pragma mark - <UITableViewDataSource>

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.userSource tableView:tableView numberOfRowsInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // if it's an ad index place the add
    if ([self indexCheck:indexPath.row]) {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        
        
        //need more time to finish showing add with the given content
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setURL:[NSURL URLWithString:[self.adUrls objectForKey:[NSNumber numberWithLong:indexPath.row]]]];
        [request setHTTPMethod:@"GET"];
        [request setValue:@"application/json;charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
        
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *POSTReply, NSError *error)
         {
             if ([POSTReply length] > 0){
                 NSString *theReply = [[NSString alloc] initWithBytes:[POSTReply bytes] length:[POSTReply length] encoding: NSUTF8StringEncoding];
                 //NSLog(@"Reply: %@", theReply);
                 
                 NSData *data = [theReply dataUsingEncoding:NSUnicodeStringEncoding];
                 if(error == nil){
                     UIImageView *adImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 300, 250)];
                     adImageView.image = [[UIImage alloc] initWithData:data];
                     [[cell contentView] addSubview:adImageView];
                 }
             }
         }];
        
        // not enough time to implement tracking and calling the given url
        //if([self checkIfPartiallyVisible])
            // call the given url

        
        /*UIWebView *adView = [[UIWebView alloc] init];
        [adView loadRequest:[NSURLRequest requestWithURL:
                        [NSURL URLWithString:[self.adUrls objectForKey:[NSNumber numberWithLong:indexPath.row]]]]];
       [[cell contentView] addSubview:adView];
         */
        
        return cell;
    }
    //if it is not an ad index use the original user source data
    return [self.userSource tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:(indexPath.row - [self.adIndices count]) inSection:0]];
}

#pragma mark - <UITableViewDelegate>

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // different row cell sizes can be implemented for ad views
    return tableView.rowHeight;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

@end
