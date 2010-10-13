#import "Three20Network/Three20Network.h"
#import "MapLayerDemoAppDelegate.h"
#import "GheatTileOverlay.h"
#import "OSMTileOverlay.h"
#import "CDistrictsTileOverlay.h"
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
    OSMTileOverlay *overlay = [[OSMTileOverlay alloc] init];
    [mapView addOverlay:overlay];
    [overlay release];

    // ----- Render
    [window addSubview:mapView];
    
    // Allow toggling map layers between the various classes of TileOverlay we have. (See -toggleLayers below)
    UIButton *toggleButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    toggleButton.frame = CGRectMake(window.bounds.size.width-110, 45, 100, 35);
    toggleButton.tag = 100;
    [toggleButton setTitle:@"OSM" forState:UIControlStateNormal];
    [toggleButton addTarget:self action:@selector(toggleLayers:) forControlEvents:UIControlEventTouchUpInside];
    [window addSubview:toggleButton];
    [window bringSubviewToFront:toggleButton];

    UILabel *attribution = [[UILabel alloc] initWithFrame:CGRectMake(
                                                                     window.bounds.size.width-250,
                                                                     window.bounds.size.height-30,
                                                                     240, 25)];
    attribution.text = @"OpenStreetMap (CC-BY-SA)";
    attribution.textAlignment = UITextAlignmentRight;
    attribution.backgroundColor = [UIColor clearColor];
    [window addSubview:attribution];
    [window bringSubviewToFront:attribution];
    
    [window makeKeyAndVisible];
    
    [mapView release];
    
	return YES;
}

#pragma mark -
#pragma mark Toggle button handler
/**
 * Handles the "toggle layers" button.
 */
- (void)toggleLayers:(id)sender {
    UIButton *toggleButton = (UIButton *)sender;
    
    // Find the current map view.
    MKMapView *mapView = nil;
    for (id subView in window.subviews) {
        if ([subView class] == [MKMapView class]) {
            mapView = (MKMapView *)subView;
            break;
        }
    }

    for (id subView in window.subviews) {
        if ([subView class] == [UILabel class]) {
            [(UILabel *)subView removeFromSuperview];
            break;
        }
    }
            
    // Just break if we somehow don't have a MKMapView attached to the window
    if (mapView == nil) return;
    
    // Remove all overlays from the map (if there are any)
    [mapView removeOverlays:mapView.overlays];

    
    if (toggleButton.tag == 99) {
        // Was at tweetmap, set to OSM
        
        [toggleButton setTitle:@"OSM" forState:UIControlStateNormal];
        toggleButton.tag = 100;
        
        OSMTileOverlay *overlay = [[OSMTileOverlay alloc] init];
        [mapView addOverlay:overlay];
        [overlay release];
        
        UILabel *attribution = [[UILabel alloc] initWithFrame:CGRectMake(
                                                                         window.bounds.size.width-250,
                                                                         window.bounds.size.height-30,
                                                                         240, 25)];
        attribution.text = @"OpenStreetMap (CC-BY-SA)";
        attribution.textAlignment = UITextAlignmentRight;
        attribution.backgroundColor = [UIColor clearColor];
        [window addSubview:attribution];
        [window bringSubviewToFront:attribution];
        
    } else if (toggleButton.tag == 100) {
        // Was at OSM, set to CDistricts
        
        [toggleButton setTitle:@"CDistricts" forState:UIControlStateNormal];
        toggleButton.tag = 101;
        
        CDistrictsTileOverlay *overlay = [[CDistrictsTileOverlay alloc] init];
        [mapView addOverlay:overlay];
        [overlay release];
        
        UILabel *attribution = [[UILabel alloc] initWithFrame:CGRectMake(
                                                                         window.bounds.size.width-250,
                                                                         window.bounds.size.height-30,
                                                                         240, 25)];
        attribution.text = @"MapBox (CC-BY-SA)";
        attribution.textAlignment = UITextAlignmentRight;
        attribution.backgroundColor = [UIColor clearColor];
        [window addSubview:attribution];
        [window bringSubviewToFront:attribution];
    } else if (toggleButton.tag == 101) {
        // Was at CDistricts, set to Tweetmap
        [toggleButton setTitle:@"Tweetmap" forState:UIControlStateNormal];
        toggleButton.tag = 102;
        
        GheatTileOverlay *overlay = [[GheatTileOverlay alloc] init];
        [mapView addOverlay:overlay];
        [overlay release];
    } else {
        // Was at Tweetmap, set to None
        

        [toggleButton setTitle:@"None" forState:UIControlStateNormal];
        toggleButton.tag = 99;
}
}


#pragma mark -
#pragma mark MKMapViewDelegate


- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay {
    // If using *several* MKOverlays simultaneously, you could test against the class
    // and return a different MKOverlayView as the handler for that overlay layer type.
    
    // CustomOverlayView handles both TileOverlay types in this demo.
    
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
