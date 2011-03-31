#import <MapKit/MapKit.h>


@protocol TileOverlay <MKOverlay>

@property (nonatomic) CGFloat defaultAlpha;
- (NSString *)urlForPointWithX:(NSUInteger)x andY:(NSUInteger)y andZoomLevel:(NSUInteger)zoomLevel;
- (BOOL)canDrawMapRect:(MKMapRect)mapRect zoomScale:(MKZoomScale)zoomScale;

@end
