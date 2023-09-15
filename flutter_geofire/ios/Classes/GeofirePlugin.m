#import "GeofirePlugin.h"
#import <UIKit/UIKit.h>
#import <FirebaseDatabase/FirebaseDatabase.h>
#import "GeoFire/API/GeoFire.h"

@implementation GeofirePlugin {
  FlutterMethodChannel *_channel;
  FlutterEventChannel *_eventChannel;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    @synchronized(self) {
        [[GeofirePlugin alloc] init:registrar];
    }
}

- (instancetype)init:(NSObject<FlutterPluginRegistrar> *)registrar {
  self = [super init];

  _channel = [FlutterMethodChannel methodChannelWithName:@"geofire" binaryMessenger:registrar.messenger];

  _eventChannel = [FlutterEventChannel eventChannelWithName:@"geofireStream" binaryMessenger:registrar.messenger];

  [_eventChannel setStreamHandler:self];

  [registrar addMethodCallDelegate:self channel:_channel];

  return self;
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
  NSMutableDictionary *key = [NSMutableDictionary dictionary];

  NSDictionary *arguments = call.arguments;

  if ([call.method isEqualToString:@"initialize"]) {
    NSString *path = arguments[@"path"];
    NSString *root = arguments[@"root"];
    int is_default = ((NSNumber *)arguments[@"is_default"]).intValue;
      
    // If the isDefault flag is true, get the reference to the default database.
    FIRDatabaseReference *databaseReference;
    if (is_default == 1) {
      databaseReference = [[FIRDatabase database] referenceWithPath:path];
    } else {
      // Otherwise, get the reference to the database with the specified root.
      databaseReference = [[FIRDatabase databaseWithURL:root] referenceWithPath:path];
    }

    self.geoFire = [[GeoFire alloc] initWithFirebaseRef:databaseReference];

    result(@(YES));
  } else if ([call.method isEqualToString:@"setLocation"]) {
    NSString *id = arguments[@"id"];
    double lat = [arguments[@"lat"] doubleValue];
    double lng = [arguments[@"lng"] doubleValue];

    CLLocation *location = [[CLLocation alloc] initWithLatitude:lat longitude:lng];

    [self.geoFire setLocation:location forKey:id withCompletionBlock:^(NSError *error) {
      if (error) {
        result(@(NO));
      } else {
        result(@(YES));
      }
    }];
  } else if ([call.method isEqualToString:@"removeLocation"]) {
    NSString *id = arguments[@"id"];

    [self.geoFire removeKey:id withCompletionBlock:^(NSError *error) {
      if (error) {
        result(@(NO));
      } else {
        result(@(YES));
      }
    }];
  } else if ([call.method isEqualToString:@"stopListener"]) {
    [self.circleQuery removeAllObservers];

    result(@(YES));
  } else if ([call.method isEqualToString:@"getLocation"]) {
    NSString *id = arguments[@"id"];

    [self.geoFire getLocationForKey:id withCallback:^(CLLocation *location, NSError *error) {
      if (error) {
        //result([FlutterError message:error.localizedDescription]);
        result(key);
      } else {
        if (location) {
          [key setValue:@(location.coordinate.latitude) forKey:@"lat"];
          [key setValue:@(location.coordinate.longitude) forKey:@"lng"];
          result(key);
        } else {
          //result([FlutterError message:@"Location not found"]);
          result(key);
        }
      }
    }];
  } else if ([call.method isEqualToString:@"queryAtLocation"]) {
    double lat = [arguments[@"lat"] doubleValue];
    double lng = [arguments[@"lng"] doubleValue];
    double radius = [arguments[@"radius"] doubleValue];

    CLLocation *location = [[CLLocation alloc] initWithLatitude:lat longitude:lng];

    self.circleQuery = [self.geoFire queryAtLocation:location withRadius:radius];

    [self.circleQuery observeEventType:GFEventTypeKeyEntered withSnapshotBlock:^(NSString *key, CLLocation *location, FIRDataSnapshot *snapshot) {
      NSMutableDictionary *param = [NSMutableDictionary dictionary];

      [param setValue:@"onKeyEntered" forKey:@"callBack"];
      [param setValue:key forKey:@"key"];
      [param setValue:@(location.coordinate.latitude) forKey:@"latitude"];
      [param setValue:@(location.coordinate.longitude) forKey:@"longitude"];
      [param setValue:[snapshot.value copy] forKey:@"val"];

      self.eventSink(param);
    }];

    [self.circleQuery observeEventType:GFEventTypeKeyMoved withSnapshotBlock:^(NSString *key, CLLocation *location, FIRDataSnapshot *snapshot) {
      NSMutableDictionary *param = [NSMutableDictionary dictionary];

      [param setValue:@"onKeyMoved" forKey:@"callBack"];
      [param setValue:key forKey:@"key"];
      [param setValue:@(location.coordinate.latitude) forKey:@"latitude"];
      [param setValue:@(location.coordinate.longitude) forKey:@"longitude"];
      [param setValue:[snapshot.value copy] forKey:@"val"];

      self.eventSink(param);
    }];

    [self.circleQuery observeEventType:GFEventTypeKeyExited withSnapshotBlock:^(NSString *key, CLLocation *location, FIRDataSnapshot *snapshot) {
      NSMutableDictionary *param = [NSMutableDictionary dictionary];

      [param setValue:@"onKeyExited" forKey:@"callBack"];
      [param setValue:key forKey:@"key"];
      [param setValue:@(location.coordinate.latitude) forKey:@"latitude"];
      [param setValue:@(location.coordinate.longitude) forKey:@"longitude"];

      self.eventSink(param);
    }];

    [self.circleQuery observeReadyWithBlock:^{
      NSMutableDictionary *param = [NSMutableDictionary dictionary];

      [param setValue:@"onGeoQueryReady" forKey:@"callBack"];
      [param setValue:key forKey:@"result"];

      self.eventSink(param);
    }];
  }
}

- (FlutterError*)onListenWithArguments:(id)arguments eventSink:(FlutterEventSink)sink {
  self.eventSink = sink;
  return nil;
}

- (FlutterError*)onCancelWithArguments:(id)arguments {
  self.eventSink = nil;
  return nil;
}

@end
