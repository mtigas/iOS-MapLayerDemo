#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface MapLayerDemoAppDelegate : NSObject <UIApplicationDelegate, MKMapViewDelegate> {
    UIWindow *window;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;

- (void)toggleLayers:(id)sender;
@end

