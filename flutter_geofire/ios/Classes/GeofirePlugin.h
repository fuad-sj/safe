#import <Flutter/Flutter.h>
#import "GeoFire.h"

@interface GeofirePlugin : NSObject<FlutterPlugin, FlutterStreamHandler>

@property (nonatomic, strong) GeoFire *geoFire;
@property (nonatomic, strong) GFCircleQuery *circleQuery;
@property (nonatomic, strong) FlutterEventSink eventSink;
@end
