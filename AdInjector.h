//
//  AdInjectLibrary.h
//  AdInjectLibrary
//
//  Created by Huseyin Guler on 22/10/14.
//  Copyright (c) 2014 Huseyin Guler. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

@interface AdInjector : NSObject

// public interface for the client to create and interact with the AdInject Library

- (void) injectAd:(NSString *)adUrl atIndex:(NSNumber *)index withTrackingUrl:(NSString *) trackingUrl;

+ (instancetype) giveMeAdInjector:(UITableView *)tableView;

@end
