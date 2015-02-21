//
//  DEMOViewController.m
//  MapView
//
//  Created by Aditya on 13/11/13.
//  Copyright (c) 2013 Aditya. All rights reserved.
//

#import "DEMOViewController.h"
#import "ANPlace.h"
#import "ANYelpParser.h"
#import "ANPointAnnotation.h"

typedef enum : int {
    GREEN,
    ORANGE,
    BLUE,
    PURPLE
}COLORS;

@interface DEMOViewController () <UISearchBarDelegate>{
    CLLocation *_userLocation;
    NSMutableArray *placesInfo;
}

@property (nonatomic, retain) ANYelpParser *yelpParser;
@property (retain, nonatomic) IBOutlet UISearchBar *searchBar;

@end

@implementation DEMOViewController
@synthesize yelpParser;

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    yelpParser = [[ANYelpParser alloc] init];
    locationManager = [[CLLocationManager alloc]init];
    locationManager.delegate = self;
    [locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    [locationManager requestAlwaysAuthorization];
    [locationManager requestWhenInUseAuthorization];
    _userLocation = [[CLLocation alloc] init];
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.searchBar.alpha = 0.0;
    placesInfo = [NSMutableArray new];
    self.searchBar.delegate = self;
    self.mapView.showsUserLocation = YES;
    self.mapView.delegate = self;
}

- (void)getCityWithHandler:(void (^)(NSError *error))completion
{
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:_userLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        CLPlacemark *city = placemarks[0];
        yelpParser.city = city.postalCode;
        if (!error) {
            completion(error);
        }else{
            NSLog(@"%s", __FUNCTION__);
        }
    }];
    [geocoder release];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    NSLog(@"%s", __FUNCTION__);
    // Dispose of any resources that can be recreated.
}

- (void)addAnnotationsFromArray:(NSArray *)places
{
    [self.mapView removeAnnotations:self.mapView.annotations];
    NSMutableArray *tmpArr = [NSMutableArray new];
    for (ANPlace *place in places) {
        ANPointAnnotation *annotation = [[ANPointAnnotation alloc] init];
        annotation.coordinate = CLLocationCoordinate2DMake([place.latitude doubleValue], [place.longitude floatValue]);
        annotation.title = place.name;
        annotation.image = [self downloadFromURL:place.image];
        [tmpArr addObject:annotation];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.mapView addAnnotations:tmpArr];
    });
    [tmpArr release];
}

- (void)parsePlaces:(NSArray *)array
{
    [placesInfo removeAllObjects];
    ANPlace *tmp;
    for (id place in array) {
        if ([place isKindOfClass:[NSDictionary class]]) {
            tmp = [[ANPlace alloc] init];
            tmp.name = place[@"name"];
            tmp.image = [NSURL URLWithString:place[@"image_url"]];
            NSDictionary *location = [NSDictionary dictionaryWithDictionary:place[@"location"]];
            tmp.address = @"temp address";
            NSDictionary *coordinates = [NSDictionary dictionaryWithDictionary:location[@"coordinate"]];
            tmp.latitude = coordinates[@"latitude"];
            tmp.longitude = coordinates[@"longitude"];
            
            [placesInfo addObject:tmp];
        }
    }
    NSMutableArray *arr = [self mutableArrayValueForKey:@"placesInfo"];
    [arr addObject:tmp];
    
    [arr removeObjectAtIndex:[arr count] - 1];
}


#pragma mark - MKMapView delegate methods

-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    NSLog(@"%s", __FUNCTION__);
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(userLocation.location.coordinate, 250, 250);
    _userLocation = userLocation.location;

    [UIView animateWithDuration:0.4 animations:^{
        self.searchBar.alpha = 1.0;
    }];

    [self.mapView setRegion:region animated:YES];
}


- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if (self.mapView.userLocation.coordinate.latitude == [annotation coordinate].latitude) {
        return nil;
    }else {
        MKPinAnnotationView *pinAnnotation = [MKPinAnnotationView new];
        pinAnnotation.animatesDrop = YES;
        pinAnnotation.canShowCallout = YES;
        pinAnnotation.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        pinAnnotation.leftCalloutAccessoryView = [[UIImageView alloc] initWithImage:((ANPointAnnotation *)annotation).image];
        return pinAnnotation;
    }
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    [self.mapView removeOverlays:mapView.overlays];
    
    MKPlacemark *place = [[MKPlacemark alloc] initWithCoordinate:CLLocationCoordinate2DMake([view.annotation coordinate].latitude, [view.annotation coordinate].longitude) addressDictionary:nil];
    MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:place];
    
    MKDirectionsRequest *dRequest = [[MKDirectionsRequest alloc] init];
    dRequest.source = [MKMapItem mapItemForCurrentLocation];
    dRequest.destination = mapItem;
    dRequest.transportType = MKDirectionsTransportTypeAutomobile;
    dRequest.requestsAlternateRoutes = YES;
    
    MKDirections *directions = [[MKDirections alloc] initWithRequest:dRequest];
    [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
        if (!error){
            for (MKRoute *route in response.routes){
                [self.mapView addOverlay:[route polyline] level:MKOverlayLevelAboveRoads];
            }
        }
    }];
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    if ([overlay isKindOfClass:[MKPolyline class]]) {
        MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc] initWithOverlay:overlay];
        [renderer setLineWidth:5.0];
        renderer.strokeColor = [self getStrokeColor];
        
        return renderer;
    }

    return nil;
}

- (UIColor *)getStrokeColor
{
    static int i = 0;
    i = i < 3 ? ++i : 0;
    switch (i) {
        case BLUE:
            return [UIColor blueColor];
        case GREEN:
            return [UIColor greenColor];
        case ORANGE:
            return [UIColor orangeColor];
        case PURPLE:
            return [UIColor purpleColor];
        default:
            return [UIColor grayColor];
    }
}

#pragma mark - UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self.searchBar resignFirstResponder];
    self.searchBar.text = @"";
    [self getCityWithHandler:^(NSError *error) {
        NSString *cll = [NSString stringWithFormat:@"%f,%f",
                         _userLocation.coordinate.latitude,
                         _userLocation.coordinate.longitude];
        if (error) return;
        [yelpParser queryTopBusinessInfoForTerm:searchBar.text
                                    locationCLL:cll
                              completionHandler:^(NSDictionary *JSON, NSError *error) {
                                  NSLog(@"%s", __FUNCTION__);
                                  if (error) return;
                                  NSArray *businessArray = JSON[@"businesses"];
                                  [self parsePlaces:businessArray];
                                  [self addAnnotationsFromArray:placesInfo];
                              }];
    }];
}


- (UIImage *) downloadFromURL:(NSURL *)url
{
    NSURLRequest *request = [NSURLRequest requestWithURL:url];

    return [UIImage imageWithData:[NSURLConnection sendSynchronousRequest:request
                                                        returningResponse:nil
                                                                    error:nil]];

}


-(IBAction)setMap:(id)sender
{
    switch (((UISegmentedControl *)sender).selectedSegmentIndex) {
        case 0:
            self.mapView.mapType = MKMapTypeStandard;
            break;
        case 1:
            self.mapView.mapType = MKMapTypeHybrid;
            break;
        case 2:
            self.mapView.mapType = MKMapTypeSatellite;
            break;
        default:
            break;
    }
}


- (void)dealloc {
    [_mapView release];
    [_userLocation release];
    [yelpParser release];
    [_searchBar release];
    [super dealloc];
}
@end
