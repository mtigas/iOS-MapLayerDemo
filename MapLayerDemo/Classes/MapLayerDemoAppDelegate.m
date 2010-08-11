#import "Three20Network/Three20Network.h"
#import "MapLayerDemoAppDelegate.h"
#import "CustomTileOverlay.h"
#import "CustomOverlayView.h"

@implementation MapLayerDemoAppDelegate

@synthesize window;


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    // ----- Set options for all URL requests
    TTURLRequestQueue *queue = [[TTURLRequestQueue alloc] init];
    [queue setMaxContentLength:0];
    [TTURLRequestQueue setMainQueue:queue];
    [queue release];
    
    TTURLCache *cache = [[TTURLCache alloc] initWithName:@"MapTileCache"];
    cache.invalidationAge = 300.0f; // Five minutes
    [TTURLCache setSharedCache:cache];
    [cache release];
    
    // ----- Set up the map view
    MKMapView *mapView = [[MKMapView alloc] initWithFrame:window.bounds];
    CLLocationCoordinate2D defaultPoint = CLLocationCoordinate2DMake(38.9517053, -92.3340724);
    MKCoordinateSpan defaultSpan = MKCoordinateSpanMake(40.0f, 40.0f);
    MKCoordinateRegion region = MKCoordinateRegionMake(defaultPoint, defaultSpan);
    [mapView setRegion:region animated:FALSE];
    [mapView regionThatFits:region];
    
    [mapView setDelegate:self];

    // ----- Add our overlay layer to the map
    CustomTileOverlay *overlay = [[CustomTileOverlay alloc] init];
    [mapView addOverlay:overlay];
    [overlay release];

    
    // ----- Render
    [window addSubview:mapView];
    [window makeKeyAndVisible];
    
    [mapView release];
    
	return YES;
}


#pragma mark -
#pragma mark MKMapViewDelegate


- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay {
    // If using *several* MKOverlays simultaneously, you could test against the class
    // and return a different MKOverlayView as the handler for that overlay layer type.

    // This demo only uses one layer and so this will only be called once, for that
    // specific instance of that overlay layer.
    
    CustomOverlayView *overlayView = [[CustomOverlayView alloc] initWithOverlay:overlay];
    
    return [overlayView autorelease];
}

#pragma mark -
#pragma mark Memory management

- (void)dealloc {
    [window release];
    [super dealloc];
}


@end
