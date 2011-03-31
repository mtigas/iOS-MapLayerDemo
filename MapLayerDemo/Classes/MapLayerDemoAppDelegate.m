#import "Three20Network/Three20Network.h"
#import "MapLayerDemoAppDelegate.h"
#import "HaitiTileOverlay.h"
#import "OSMTileOverlay.h"
#import "OSMRestrictedBoundsTileOverlay.h"
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
    MKCoordinateRegion region = {{38.9f, -96.0f}, {45.0f, 45.0f}};
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
    toggleButton.frame = CGRectMake(window.bounds.size.width-140, 45, 130, 35);
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
        // Was at None, set to OSM
        
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
        // Was at OSM, set to OSM filtered
        
        [toggleButton setTitle:@"OSM-Bounded" forState:UIControlStateNormal];
        toggleButton.tag = 101;
        
        OSMRestrictedBoundsTileOverlay *overlay = [[OSMRestrictedBoundsTileOverlay alloc] init];
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
    } else if (toggleButton.tag == 101) {
        // Was at OSM Restricted, set to CDistricts
        
        [toggleButton setTitle:@"CDistricts" forState:UIControlStateNormal];
        toggleButton.tag = 102;
        
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
        
        // Zoom to a known good view for US congressional districts
        MKCoordinateRegion region = {{38.9f, -96.0f}, {45.0f, 45.0f}};
        [mapView setRegion:region animated:YES];
    } else if (toggleButton.tag == 102) {
        // Was at CDistricts, set to Haiti
        [toggleButton setTitle:@"Haiti" forState:UIControlStateNormal];
        toggleButton.tag = 103;
        
        HaitiTileOverlay *overlay = [[HaitiTileOverlay alloc] init];
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
        
        // Zoom to a valid region for Haiti (since the map is pretty resticted in where it will render)
        MKCoordinateRegion region = {{18.5f, -72.0f}, {3.0f, 3.0f}};
        [mapView setRegion:region animated:YES];
    } else {
        // Was at Haiti, set to None
        

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
