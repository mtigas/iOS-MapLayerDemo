#import "CustomOverlayView.h"
#import "TileOverlay.h"

#pragma mark Private methods
@interface CustomOverlayView()
- (NSUInteger)zoomLevelForMapRect:(MKMapRect)mapRect;
- (NSUInteger)zoomLevelForZoomScale:(MKZoomScale)zoomScale;
- (NSUInteger)worldTileWidthForZoomLevel:(NSUInteger)zoomLevel;
- (CGPoint)mercatorTileOriginForMapRect:(MKMapRect)mapRect;
@end

#pragma mark -
#pragma mark Implementation

@implementation CustomOverlayView

#pragma mark Private utility methods
/**
 * Given a MKMapRect, this returns the zoomLevel based on 
 * the longitude width of the box.
 *
 * This is because the Mercator projection, when tiled,
 * normally operates with 2^zoomLevel tiles (1 big tile for
 * world at zoom 0, 2 tiles at 1, 4 tiles at 2, etc.)
 * and the ratio of the longitude width (out of 360º)
 * can be used to reverse this.
 *
 * This method factors in screen scaling for the iPhone 4:
 * the tile layer will use the *next* zoomLevel. (We are given
 * a screen that is twice as large and zoomed in once more
 * so that the "effective" region shown is the same, but
 * of higher resolution.)
 */
- (NSUInteger)zoomLevelForMapRect:(MKMapRect)mapRect {
    MKCoordinateRegion region = MKCoordinateRegionForMapRect(mapRect);
    CGFloat lon_ratio = region.span.longitudeDelta/360.0;
    NSUInteger z = (NSUInteger)(log(1/lon_ratio)/log(2.0)-1.0);

    z += ([[UIScreen mainScreen] scale] - 1.0);
    return z;
}
/**
 * Similar to above, but uses a MKZoomScale to determine the
 * Mercator zoomLevel. (MKZoomScale is a ratio of screen points to
 * map points.)
 */
- (NSUInteger)zoomLevelForZoomScale:(MKZoomScale)zoomScale {
    CGFloat realScale = zoomScale / [[UIScreen mainScreen] scale];
    NSUInteger z = (NSUInteger)(log(realScale)/log(2.0)+20.0);

    z += ([[UIScreen mainScreen] scale] - 1.0);
    return z;
}
/**
 * Shortcut to determine the number of tiles wide *or tall* the
 * world is, at the given zoomLevel. (In the Spherical Mercator
 * projection, the poles are cut off so that the resulting 2D
 * map is "square".)
 */
- (NSUInteger)worldTileWidthForZoomLevel:(NSUInteger)zoomLevel {
    return (NSUInteger)(pow(2,zoomLevel));
}

/**
 * Given a MKMapRect, this reprojects the center of the mapRect
 * into the Mercator projection and calculates the rect's top-left point
 * (so that we can later figure out the tile coordinate).
 *
 * See http://wiki.openstreetmap.org/wiki/Slippy_map_tilenames#Derivation_of_tile_names
 */
- (CGPoint)mercatorTileOriginForMapRect:(MKMapRect)mapRect {
    MKCoordinateRegion region = MKCoordinateRegionForMapRect(mapRect);
    
    // Convert lat/lon to radians
    CGFloat x = (region.center.longitude) * (M_PI/180.0); // Convert lon to radians
    CGFloat y = (region.center.latitude) * (M_PI/180.0); // Convert lat to radians
    y = log(tan(y)+1.0/cos(y));
    
    // X and Y should actually be the top-left of the rect (the values above represent
    // the center of the rect)
    x = (1.0 + (x/M_PI)) / 2.0;
    y = (1.0 - (y/M_PI)) / 2.0;

    return CGPointMake(x, y);
}
#pragma mark MKOverlayView methods

/**
 * Called by MapKit when a tile is on the visible space of the map.
 * This method tests the cache to see if a tile is available to be drawn.
 * If not, an asynchronous HTTP request is performed.
 *
 * Returns YES if a tile can be draw immediately. MapKit will then call
 * drawMapRect:zoomScale:context:.
 *
 * Returns NO if significant processing (HTTP requests, etc.) must be performed
 * before a tile can be drawn. MapKit will skip over this tile and only
 * attempt to reload this if the tile leaves and re-enters the view. (A reload
 * can be forced by calling setNeedsDisplayInMapRect:zoomScale:)
 */
- (BOOL)canDrawMapRect:(MKMapRect)mapRect zoomScale:(MKZoomScale)zoomScale {
    NSUInteger zoomLevel = [self zoomLevelForZoomScale:zoomScale];
    CGPoint mercatorPoint = [self mercatorTileOriginForMapRect:mapRect];
    
    // Hook on TileOverlay that allows an overlay to limit the boundaries it attempts to load.
    if ([(id<TileOverlay>)self.overlay canDrawMapRect:mapRect zoomScale:zoomScale] != YES) {
        return NO;
    }
    
    NSUInteger tilex = floor(mercatorPoint.x * [self worldTileWidthForZoomLevel:zoomLevel]);
    NSUInteger tiley = floor(mercatorPoint.y * [self worldTileWidthForZoomLevel:zoomLevel]);
    
    NSString *url = [(id<TileOverlay>)self.overlay urlForPointWithX:tilex andY:tiley andZoomLevel:zoomLevel];
        
    // Given the URL, check the cache to see if we have the tile requested.
    // (In theory, this cache/get/callback process *could* be part of the tile
    // overlay "data model".)
    NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%d%d%d", tilex, tiley, zoomLevel]];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        // This tile is in cache, so let MapKit know it can perform the render.
        return YES;
    } else {
        // Perform a background HTTP request for this map tile.
        
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:5.0];
        
        [NSURLConnection sendAsynchronousRequest:request 
                                           queue:[NSOperationQueue mainQueue] 
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {            
                                   [data writeToFile:path atomically:YES];
                                   
                                   NSNumber *mr_origin_x = [NSNumber numberWithDouble:mapRect.origin.x];
                                   NSNumber *mr_origin_y = [NSNumber numberWithDouble:mapRect.origin.y];
                                   NSNumber *mr_size_w = [NSNumber numberWithDouble:mapRect.size.width];
                                   NSNumber *mr_size_h = [NSNumber numberWithDouble:mapRect.size.height];
                                   
                                   MKMapRect mapRect = MKMapRectMake(
                                                                     [mr_origin_x doubleValue],
                                                                     [mr_origin_y doubleValue],
                                                                     [mr_size_w doubleValue],
                                                                     [mr_size_h doubleValue]);
                                   
                                   NSNumber *zoomScaleNumber = [NSNumber numberWithFloat:zoomScale];
                                   MKZoomScale zoomScale = [zoomScaleNumber floatValue];
                                   
                                   // "Invalidate" the image at the mapRect -- causes MapKit to attempt another
                                   // load for this tile.
                                   [self setNeedsDisplayInMapRect:mapRect zoomScale:zoomScale];
                               }];
        
        return NO;
    }
}

/**
 * If the above method returns YES, this method performs the actual screen render
 * of a particular tile.
 *
 * You should never perform long processing (HTTP requests, etc.) from this method
 * or else your application UI will become blocked. You should make sure that
 * canDrawMapRect ONLY EVER returns YES if you are positive the tile is ready
 * to be rendered.
 */
- (void)drawMapRect:(MKMapRect)mapRect zoomScale:(MKZoomScale)zoomScale inContext:(CGContextRef)context {
    id<TileOverlay> overlay = (id<TileOverlay>)self.overlay;
    
    NSUInteger zoomLevel = [self zoomLevelForZoomScale:zoomScale];
    CGPoint mercatorPoint = [self mercatorTileOriginForMapRect:mapRect];
    
    NSUInteger tilex = floor(mercatorPoint.x * [self worldTileWidthForZoomLevel:zoomLevel]);
    NSUInteger tiley = floor(mercatorPoint.y * [self worldTileWidthForZoomLevel:zoomLevel]);

    NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%d%d%d", tilex, tiley, zoomLevel]];
    
    // Load the image from cache.
    NSData *imageData = [NSData dataWithContentsOfFile:path];
    
    if (imageData != nil) {
        // Perform the image render on the current UI context
        UIImage *img = [[UIImage imageWithData:imageData] retain];
        
        UIGraphicsPushContext(context);
        [img drawInRect:[self rectForMapRect:mapRect] 
              blendMode:kCGBlendModeNormal 
                  alpha:overlay.defaultAlpha];
        UIGraphicsPopContext();
        
        [img release];
    }
}

@end
