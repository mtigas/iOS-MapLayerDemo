#import <MapKit/MapKit.h>

/**
 * Tile layer that uses MapBox's U.S. Congressional Districts tileset.
 * http://mapbox.com/tileset/us-congressional-districts
 *
 * Please see the MapBox tile layer terms of use:
 * http://mapbox.com/
 */
@interface CDistrictsTileOverlay : NSObject <MKOverlay> {
    CGFloat defaultAlpha;
}
@property (nonatomic) CGFloat defaultAlpha;
- (NSString *)urlForPointWithX:(NSUInteger)x andY:(NSUInteger)y andZoomLevel:(NSUInteger)zoomLevel;
@end
