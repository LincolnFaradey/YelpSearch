//
//  ANPlace.m
//  MapView
//
//  Created by Aditya Narayan on 2/19/15.
//  Copyright (c) 2015 Aditya. All rights reserved.
//

#import "ANPlace.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface ANPlace ()

@end

@implementation ANPlace


- (id)init
{
    self = [super init];
    
    if (self) {
        
    }
    
    return self;
}
//
//- (id)initWithName:(NSString *)name address:(NSString *)address latitude:(NSString *)latitude longitude:(NSString *)longitude image:(NSString *)image
//{
//    self = [self init];
//    
//    if (self) {
//        _name = name;
//        _address = address;
//        _latitude = latitude;
//        _longitude = longitude;
//        _image = image;
//    }
//    
//    return self;
//}


- (MKCoordinateRegion)region
{
//    NSDecimalNumber *latitude = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%@", _latitude]];
//    NSDecimalNumber *longitude = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%@", _longitude]];
    

    CLLocationDegrees lat =[_latitude floatValue];
    CLLocationDegrees lon = [_longitude floatValue];
    CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(lat, lon);
    MKCoordinateRegion reg = MKCoordinateRegionMakeWithDistance(coord, 50, 50);
    
    return reg;
}

- (void)dealloc
{
    [_image release];
    [super dealloc];
}

@end
