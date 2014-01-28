//
//  TBMapController.m
//  TicketBuying
//
//  Created by Владимир on 08.10.13.
//  Copyright (c) 2013 Rost's company. All rights reserved.
//

#import "TBMapController.h"
#import "Annotation.h"

@interface TBMapController ()

@end

@implementation TBMapController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    if (CLLocationCoordinate2DIsValid(_location))
        [self showAnnotation:_location];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) showAnnotation: (CLLocationCoordinate2D) location
{
    [_mapView removeAnnotations:_mapView.annotations];
    Annotation *annotation = [Annotation new];
    annotation.coordinate = location;
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(location, 3000, 3000);
    [self.mapView setRegion:region animated:NO];
    [_mapView addAnnotation:annotation];
}

@end
