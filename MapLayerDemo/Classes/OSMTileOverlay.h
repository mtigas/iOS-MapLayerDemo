#import <MapKit/MapKit.h>
#import "TileOverlay.h"

/**
 * Tile layer that uses tiles from the OpenStreetMap project.
 */
@interface OSMTileOverlay : NSObject <TileOverlay> {
    CGFloat defaultAlpha;
}
@end
