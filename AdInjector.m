//
//  AdInjectLibrary.m
//  AdInjectLibrary
//
//  Created by Huseyin Guler on 22/10/14.
//  Copyright (c) 2014 Huseyin Guler. All rights reserved.
//

#import "AdInjector.h"
#import "AdRequest.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface AdInjector () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *adTable;
@property (nonatomic, strong) NSMutableArray *adRequests;
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
    
    self.adRequests = [[NSMutableArray alloc] init];
    
    return self;
}

- (void)injectAd:(NSString *)adUrl atIndex:(NSNumber *) index withTrackingUrl:(NSString *) trackingUrl
{
    AdRequest *req = [[AdRequest alloc] init];
    req.adUrl = adUrl;
    req.trackingUrl = trackingUrl;
    req.index = index;
    req.isDisplayed = NO;
    
    [self.adRequests addObject:req];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[index integerValue] inSection:0];
    [self.adTable insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

-(NSInteger)checkAdIndex:(NSUInteger) index
{
    // Since we will have only 25 ads brute force search is implemented.
    // In production a better search can be applied (e.g. binary search by sorting the indices)
    // sorting will also ensure the method 'getActualIndex' working for all random ad insertion
    for(NSInteger i=0; i<[self.adRequests count]; i++){
        if([[(AdRequest *)[self.adRequests objectAtIndex:i] index] integerValue] == index)
            return i;
    }
    return -1;
}

-(long)getActualIndex:(NSIndexPath *)indexPath
{
    long numberOfPreviousAds = 0;
    for(NSUInteger i=0; i<[self.adRequests count]; i++){
        if([[[self.adRequests objectAtIndex:i] index] integerValue]< indexPath.row)
            numberOfPreviousAds++;
        else
            break;
    }
    return indexPath.row - numberOfPreviousAds;
}

//method to check if at least 50% of the row frame is visible
-(BOOL)checkIfHalfVisible:(NSIndexPath *)indexPath
{
    CGRect cellFrame = [self.adTable rectForRowAtIndexPath:indexPath];
    CGRect halfFrame = CGRectMake(cellFrame.origin.x, cellFrame.origin.y, cellFrame.size.width, cellFrame.size.height/2);
    CGRect tableFrame = [self.adTable bounds];
    //NSLog(@"%f %f %f %f", cellFrame.origin.x, cellFrame.origin.y, tableFrame.origin.x, tableFrame.origin.y);
    return CGRectContainsRect(tableFrame, halfFrame);
}

#pragma mark - <UITableViewDataSource>

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return ([self.userSource tableView:tableView numberOfRowsInSection:section] + [self.adRequests count]);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // if it's an ad index place the add
    NSInteger adIndex = [self checkAdIndex:indexPath.row];
    
    //NSLog(@"%f   %f", (self.adTable.contentOffset.y + self.adTable.frame.size.height) - (self.adTable.contentInset.top-self.adTable.contentInset.bottom), cellFrame.origin.y + (cellFrame.size.height/2));
    
    
    if (adIndex >= 0) {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        UIImageView *adImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 0, 300, 250)];
        NSString *imageUrl = [[self.adRequests objectAtIndex:adIndex] adUrl];
        SDWebImageManager *manager = [SDWebImageManager sharedManager];
        UIImage *cachedImage = [[manager imageCache] imageFromDiskCacheForKey:imageUrl];
        if(cachedImage){
            adImageView.image = cachedImage;
        }
        else{
            [manager downloadWithURL:[NSURL URLWithString:imageUrl]
                             options:SDWebImageCacheMemoryOnly
                            progress:nil
                           completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished)
             {
                 if (image)
                 {
                     adImageView.image = image;
                     [[SDImageCache sharedImageCache] storeImage:image forKey:imageUrl];
                     [self.adTable reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationNone];
                 }
             }];
        }
        
        [[cell contentView] addSubview:adImageView];
        return cell;
    }
    // if it is not an ad index use the original user source data
    // normally we need to map the indexPath.row with the actual user data source index,
    // however in the sample app we know that we place 1 ad after 4 non-ad cell
    return [self.userSource tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:[self getActualIndex:indexPath] inSection:0]];
}

#pragma mark - <UITableViewDelegate>

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // different row cell sizes can be implemented for ad views
    return tableView.rowHeight;
}

- (void)scrollViewDidScroll:(UIScrollView *)aScrollView {
    NSArray *indexPaths = self.adTable.indexPathsForVisibleRows;
    for (NSUInteger i = 0; i < [indexPaths count]; i++){
        NSInteger adIndex = [self checkAdIndex:[[indexPaths objectAtIndex:i] row]];
        if (adIndex >= 0) {
            if(![[self.adRequests objectAtIndex:adIndex] isDisplayed] && [self checkIfHalfVisible:[indexPaths objectAtIndex:i]]){
                [[self.adRequests objectAtIndex:adIndex] setIsDisplayed:YES];
                
                [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL: [NSURL URLWithString:[[self.adRequests objectAtIndex:adIndex] trackingUrl]]]
                                                   queue:[NSOperationQueue mainQueue]
                                       completionHandler:^(NSURLResponse *response, NSData *reply, NSError *error){
                                       
                }];
                
                NSLog(@"Ad with ID: %@ is fired.", [[self.adRequests objectAtIndex:adIndex] index]);
            }
        }
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*
    NSUInteger adIndex = [self checkAdIndex:indexPath.row];
    if(adIndex >= 0){
        
    }
     */
    
    /*
     CGRect cellFrame = [self.adTable rectForRowAtIndexPath:indexPath];
     CGRect halfFrame = CGRectMake(cellFrame.origin.x, cellFrame.origin.y, cellFrame.size.width, cellFrame.size.height/2);
     BOOL completelyVisible = CGRectContainsRect(self.adTable.frame, halfFrame);
     NSLog(@"%d", completelyVisible);
     */
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

@end
