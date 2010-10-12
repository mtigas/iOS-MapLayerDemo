#import <MapKit/MapKit.h>
#import "TileOverlay.h"

/**
 * Tile layer that uses MapBox's U.S. Congressional Districts tileset.
 * http://mapbox.com/tileset/us-congressional-districts
 *
 * Please see the MapBox tile layer terms of use:
 * http://mapbox.com/
 */
@interface CDistrictsTileOverlay : NSObject <TileOverlay> {
    CGFloat defaultAlpha;
}
@end
