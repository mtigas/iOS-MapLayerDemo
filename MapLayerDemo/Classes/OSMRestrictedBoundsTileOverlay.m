#import "OSMRestrictedBoundsTileOverlay.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@implementation OSMRestrictedBoundsTileOverlay
@synthesize boundingMapRect; // from <MKOverlay>
@synthesize coordinate;      // from <MKOverlay>
@synthesize defaultAlpha;

-(id) init {
    self = [super init];
    
    defaultAlpha = 0.6;
    
    // I am still not well-versed in map projections, but the Google Mercator projection
    // is slightly off from the "standard" Mercator projection, used by MapKit. (GMerc is used
    // by the demo tileserver to serve to the Google Maps API script in a user's
    // browser.)
    //
    // My understanding is that this is due to Google Maps' use of a Spherical Mercator
    // projection, where the poles are cut off -- the effective map ending at approx. +/- 85º.
    // MapKit does not(?), therefore, our origin point (top-left) must be moved accordingly.
    
    boundingMapRect = MKMapRectWorld;
    boundingMapRect.origin.x += 1048600.0;
    boundingMapRect.origin.y += 1048600.0;
    
    coordinate = CLLocationCoordinate2DMake(0, 0);
    
    return self;
}

- (NSString *)urlForPointWithX:(NSUInteger)x andY:(NSUInteger)y andZoomLevel:(NSUInteger)zoomLevel {
    return [NSString stringWithFormat:@"http://tile.openstreetmap.org/%d/%d/%d.png",zoomLevel,x,y];
}

- (BOOL)canDrawMapRect:(MKMapRect)mapRect zoomScale:(MKZoomScale)zoomScale {
    // Limit this overlay to only display within the continental United States.
    // Roughly within (50, -127), (24, -66), in degrees.
    
    // Turn center to bounds
    MKCoordinateRegion _region = MKCoordinateRegionForMapRect(mapRect);
    CLLocationDegrees top_bound = _region.center.latitude + (_region.span.latitudeDelta / 2.0);
    CLLocationDegrees bottom_bound = _region.center.latitude - (_region.span.latitudeDelta / 2.0);
    CLLocationDegrees left_bound = _region.center.longitude - (_region.span.longitudeDelta / 2.0);
    CLLocationDegrees right_bound = _region.center.longitude + (_region.span.longitudeDelta / 2.0);
    
    if ( (left_bound > -66.0f) ||   // The "west end" of this tile is east of -66
        (right_bound < -127.0f) || // The "east end" of this tile is west of -127
        (top_bound < 24.0f) ||     // The "top" of this tile is south of 24
        (bottom_bound > 50.0f) ) { // The "bottom" of this tile is north of 50
        return NO;
    }
    return YES;
}
@end
