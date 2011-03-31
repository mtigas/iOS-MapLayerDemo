#import <MapKit/MapKit.h>
#import "TileOverlay.h"

/**
 * Tile layer that uses tiles from the OpenStreetMap project.
 *
 * Identical to OSMTileOverlay except for that it uses the [-canDrawMapRect] hook
 * to only show the Continental United States and is not completely opaque.
 */
@interface OSMRestrictedBoundsTileOverlay : NSObject <TileOverlay> {
    CGFloat defaultAlpha;
}
@end
