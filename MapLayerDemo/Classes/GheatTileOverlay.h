#import <MapKit/MapKit.h>
#import "TileOverlay.h"

/**
 * A "data model" of sorts, for this tile layer.
 *
 * This dummy model only contains a hardcoded offset for the server's map
 * projection and a method that returns the server URL for a given tile.
 *
 * Could possibly move HTTP data loading out of the "view" into here. Other
 * serious processing bits (custom drawing vector drawing with CoreGraphics,
 * for example) could also live here.
 */
@interface GheatTileOverlay : NSObject <TileOverlay> {
    CGFloat defaultAlpha;
}
@end
