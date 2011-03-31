#import "HaitiTileOverlay.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@implementation HaitiTileOverlay
@synthesize boundingMapRect; // from <MKOverlay>
@synthesize coordinate;      // from <MKOverlay>
@synthesize defaultAlpha;

-(id) init {
    self = [super init];
    
    defaultAlpha = .7;
    
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
    // The MapBox JS API helper ( http://js.mapbox.com/g/2/mapbox.js ) notes that the
    // "Y coordinate is flipped in Mapbox, compared to Google" and provides this conversion:
    NSUInteger newY = abs(y - (pow(2,zoomLevel) - 1));
    
    return [NSString stringWithFormat:@"http://c.tile.mapbox.com/1.0.0/haiti-terrain/%d/%d/%d.jpg",zoomLevel,x,newY];
}

- (BOOL)canDrawMapRect:(MKMapRect)mapRect zoomScale:(MKZoomScale)zoomScale {
    // This tile set is only available for zoom 5-16
    // See http://mapbox.com/tileset/haiti-terrain
    
    // TODO: shared code (zoomLevelForZoomScale from CustomOverlayView)
    CGFloat realScale = zoomScale / [[UIScreen mainScreen] scale];
    NSUInteger zoomLevel = (NSUInteger)(log(realScale)/log(2.0)+20.0);
    
    zoomLevel += ([[UIScreen mainScreen] scale] - 1.0);
    
    if ((zoomLevel < 5) || (zoomLevel > 16)) {
        return NO;
    }
    
    // Limit this overlay to only display tiles over the general Haiti area.
    // Roughly within (24.5, -83), (14, -60), in degrees.
    
    // Turn center to bounds
    MKCoordinateRegion _region = MKCoordinateRegionForMapRect(mapRect);
    CLLocationDegrees top_bound = _region.center.latitude + (_region.span.latitudeDelta / 2.0);
    CLLocationDegrees bottom_bound = _region.center.latitude - (_region.span.latitudeDelta / 2.0);
    CLLocationDegrees left_bound = _region.center.longitude - (_region.span.longitudeDelta / 2.0);
    CLLocationDegrees right_bound = _region.center.longitude + (_region.span.longitudeDelta / 2.0);
    
    if ( (left_bound > -60.0f) ||   // The "west end" of this tile is east of -66
        (right_bound < -83.0f) || // The "east end" of this tile is west of -127
        (top_bound < 14.0f) ||     // The "top" of this tile is south of 24
        (bottom_bound > 24.5f) ) { // The "bottom" of this tile is north of 50
        return NO;
    }
    return YES;
}
@end
