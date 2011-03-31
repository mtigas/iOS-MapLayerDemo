#import <MapKit/MapKit.h>
#import "TileOverlay.h"

/**
 * Tile layer that uses MapBox's Haiti Terrain tileset.
 * http://mapbox.com/tileset/haiti-terrain
 *
 * Please see the MapBox tile layer terms of use:
 * http://mapbox.com/
 */
@interface HaitiTileOverlay : NSObject <TileOverlay> {
    CGFloat defaultAlpha;
}
@end
