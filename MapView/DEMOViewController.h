//
//  DEMOViewController.h
//  MapView
//
//  Created by Aditya on 13/11/13.
//  Copyright (c) 2013 Aditya. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>   
#import <CoreLocation/CoreLocation.h>


@interface DEMOViewController : UIViewController
<CLLocationManagerDelegate, MKMapViewDelegate>
{
    CLLocationManager *locationManager;
}

@property(nonatomic,retain)IBOutlet MKMapView *mapView;

-(IBAction)setMap:(id)sender;

@end
