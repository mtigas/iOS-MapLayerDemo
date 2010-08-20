#import <MapKit/MapKit.h>

/**
 * Tile layer that uses tiles from the OpenStreetMap project.
 */
@interface OSMTileOverlay : NSObject <MKOverlay> {
    CGFloat defaultAlpha;
}
@property (nonatomic) CGFloat defaultAlpha;
- (NSString *)urlForPointWithX:(NSUInteger)x andY:(NSUInteger)y andZoomLevel:(NSUInteger)zoomLevel;
@end
