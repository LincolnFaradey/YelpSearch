//
//  ANYelpParser.m
//  MapView
//
//  Created by Aditya Narayan on 2/19/15.
//  Copyright (c) 2015 Aditya. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import "ANYelpParser.h"
#import "NSURLRequest+OAuth.h"
#import "ANPlace.h"


@implementation ANYelpParser


static NSString * const kAPIHost           = @"api.yelp.com";
static NSString * const kSearchPath        = @"/v2/search";


- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    
    return self;
}



//oauth_consumer_key	Your OAuth consumer key (from Manage API Access).
//oauth_token	The access token obtained (from Manage API Access).
//oauth_signature_method	hmac-sha1
//oauth_signature	The generated request signature, signed with the oauth_token_secret obtained (from Manage API Access).
//oauth_timestamp	Timestamp for the request in seconds since the Unix epoch.
//oauth_nonce	A unique string randomly generated per request.


- (void)queryTopBusinessInfoForTerm:(NSString *)term locationCLL:(NSString *)location completionHandler:(void (^)(NSDictionary *topBusinessJSON, NSError *error))completionHandler {
    
    NSLog(@"Querying the Search API with term \'%@\' and location \'%@'", term, location);
    
    //Make a first request to get the search results with the passed term and location
    NSURLRequest *searchRequest = [self _searchRequestWithTerm:term locationCLL:location];
    
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithRequest:searchRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;

        if (!error && httpResponse.statusCode == 200) {
            
            NSDictionary *searchResponseJSON = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];

            if ([NSJSONSerialization isValidJSONObject:searchResponseJSON]) {
                NSLog(@"Valid JSON");
                completionHandler(searchResponseJSON, error);
            } else {
                NSLog(@"%s", __FUNCTION__);
            }
        } else {
            NSLog(@"Status code is not 200\n%@", response);
        }
    }] resume];
}




#pragma mark - API Request Builders

/**
 Builds a request to hit the search endpoint with the given parameters.
 
 @param term The term of the search, e.g: dinner
 @param location The location request, e.g: San Francisco, CA
 @return The NSURLRequest needed to perform the search
 */
- (NSURLRequest *)_searchRequestWithTerm:(NSString *)term locationCLL:(NSString *)location {
    NSDictionary *params = @{
                             @"term": term,
                             @"location": self.city,
                             @"cll":location,
                             @"limit": @"20"
                             };
    
    return [NSURLRequest requestWithHost:kAPIHost path:kSearchPath params:params];
}

- (void)currentCity:(CLLocation *)location
{
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error) {
            NSLog(@"Geocoder failed with error - %@", [error localizedDescription]);
        }
        
        CLPlacemark *tmpPlacemark = placemarks[0];
        
        self.city = [tmpPlacemark.postalCode copy];
        NSLog(@"Placemark - %@", self.city);
    }];
}

- (void)dealloc
{
    [super dealloc];
}


@end
