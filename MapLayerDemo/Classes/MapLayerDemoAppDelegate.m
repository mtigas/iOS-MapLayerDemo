#import "MapLayerDemoAppDelegate.h"
#import <MapKit/MapKit.h>

@implementation MapLayerDemoAppDelegate

@synthesize window;


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];


	
    MKMapView *mapView = [[MKMapView alloc] initWithFrame:window.bounds];
    CLLocationCoordinate2D defaultPoint = CLLocationCoordinate2DMake(38.9517053, -92.3340724);
    MKCoordinateSpan defaultSpan = MKCoordinateSpanMake(40.0f, 40.0f);
    MKCoordinateRegion region = MKCoordinateRegionMake(defaultPoint, defaultSpan);
    [mapView setRegion:region animated:FALSE];
    [mapView regionThatFits:region];
        
    [window addSubview:mapView];
    [window makeKeyAndVisible];
    
    [mapView release];
    
	return YES;
}

#pragma mark -
#pragma mark Memory management

- (void)dealloc {
    [window release];
    [super dealloc];
}


@end
