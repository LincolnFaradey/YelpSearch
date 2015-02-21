//
//  ANYelpParser.h
//  MapView
//
//  Created by Aditya Narayan on 2/19/15.
//  Copyright (c) 2015 Aditya. All rights reserved.
//

#import <Foundation/Foundation.h>
@class  CLLocation;

@interface ANYelpParser : NSObject

@property (nonatomic, retain) NSString *city;


- (void)queryTopBusinessInfoForTerm:(NSString *)term locationCLL:(NSString *)location completionHandler:(void (^)(NSDictionary *topBusinessJSON, NSError *error))completionHandler;

- (void)currentCity:(CLLocation *)location;
@end
