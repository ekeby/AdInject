//
//  AdRequest.h
//  AdInject
//
//  Created by Huseyin Guler on 22/10/14.
//  Copyright (c) 2014 Huseyin Guler. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AdRequest : NSObject

@property (nonatomic, strong) NSString *adUrl;
@property (nonatomic, strong) NSNumber *index;
@property (nonatomic, strong) NSString *trackingUrl;
@property (nonatomic) BOOL isDisplayed;

@end
