//
//  ANPlace.h
//  MapView
//
//  Created by Aditya Narayan on 2/19/15.
//  Copyright (c) 2015 Aditya. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ANPlace : NSObject

@property (nonatomic, copy)NSString *name;
@property (nonatomic, copy)NSString *address;
@property (nonatomic, copy)NSNumber *latitude;
@property (nonatomic, copy)NSNumber *longitude;
@property (nonatomic, retain)NSURL *image;

//- (id)initWithName:(NSString *)name address:(NSString *)address latitude:(NSString *)location longitude:(NSString *)longitude image:(NSString *)image;

@end
