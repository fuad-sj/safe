import Flutter
import UIKit
import GeoFire
import FirebaseDatabase

public class SwiftGeofirePlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
  var geoFireRef:DatabaseReference?
  var geoFire:GeoFire?
  private var eventSink: FlutterEventSink?
  var circleQuery : GFCircleQuery?

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "geofire", binaryMessenger: registrar.messenger())
    let instance = SwiftGeofirePlugin()

    let eventChannel = FlutterEventChannel(name: "geofireStream",
                                                  binaryMessenger: registrar.messenger())

    eventChannel.setStreamHandler(instance)
    
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    var key = [String]()
    
    let arguments = call.arguments as? NSDictionary
    
    if(call.method.elementsEqual("initialize")){
      let path = arguments!["path"] as! String
      let root = arguments!["root"] as! String
      let isDefault = arguments!["is_default"] as! Bool

      let databaseReference: DatabaseReference
      if isDefault {
          databaseReference = Database.database().reference(withPath: path)
      } else {
          databaseReference = Database.database(url: root).reference(withPath: path)
      }

      geoFire = GeoFire(firebaseRef: databaseReference)

      result(true)
    } else if(call.method.elementsEqual("setLocation")){
        let id = arguments!["id"] as! String
        let lat = arguments!["lat"] as! Double
        let lng = arguments!["lng"] as! Double

        geoFire?.setLocation(CLLocation(latitude: lat, longitude: lng), forKey: id ) { (error) in
            if (error != nil) {
                print("An error occurred: \(String(describing: error))")
                result("An error occurred: \(String(describing: error))")
            } else {
                print("Saved location successfully!")
                result(true)
            }
        }
    } else if(call.method.elementsEqual("removeLocation")){
        let id = arguments!["id"] as! String

        geoFire?.removeKey(id) { (error) in
            if (error != nil) {
                print("An error occurred: \(String(describing: error))")
                result("An error occurred: \(String(describing: error))")
            } else {
                print("Removed location successfully!")
                result(true)
            }
        }
    } else if(call.method.elementsEqual("stopListener")){
        circleQuery?.removeAllObservers()
        result(true);
    } else if(call.method.elementsEqual("getLocation")){
        let id = arguments!["id"] as! String

        geoFire?.getLocationForKey(id) { (location, error) in
            if (error != nil) {
                print("An error occurred getting the location for \(id): \(String(describing: error?.localizedDescription))")
            } else if (location != nil) {
                print("Location for \(id) is [\(String(describing: location?.coordinate.latitude)), \(location?.coordinate.longitude)]")
                
                var param=[String:AnyObject]()
                param["lat"]=location?.coordinate.latitude as AnyObject
                param["lng"]=location?.coordinate.longitude as AnyObject
                
                result(param)
            } else {
                var param=[String:AnyObject]()
                param["error"] = "GeoFire does not contain a location for \(id)" as AnyObject

                result(param)
                
                print("GeoFire does not contain a location for \"firebase-hq\"")
            }
        }
    }
    
    if(call.method.elementsEqual("queryAtLocation")){
        let lat = arguments!["lat"] as! Double
        let lng = arguments!["lng"] as! Double
        let radius = arguments!["radius"] as! Double

        let location:CLLocation = CLLocation(latitude: CLLocationDegrees(lat), longitude: CLLocationDegrees(lng))
        
        circleQuery = geoFire?.query(at: location, withRadius: radius)

        _ = circleQuery?.observe(.keyEntered, with: { (parkingKey, location) in
            var param=[String:Any]()
            
            param["callBack"] = "onKeyEntered"
            param["key"] = parkingKey
            param["latitude"] = location.coordinate.latitude
            param["longitude"] = location.coordinate.longitude
            
            key.append(parkingKey)
            print("Key is \(parkingKey)")
            
            self.eventSink!(param)
        })
        
        _ = circleQuery?.observe(.keyMoved, with: { (parkingKey, location) in
            var param=[String:Any]()
            
            param["callBack"] = "onKeyMoved"
            param["key"] = parkingKey
            param["latitude"] = location.coordinate.latitude
            param["longitude"] = location.coordinate.longitude
            
            key.append(parkingKey)
            print("Key is \(parkingKey)")
            
            self.eventSink!(param)
        })
        
        _ = circleQuery?.observe(.keyExited, with: { (parkingKey, location) in
            var param=[String:Any]()
            
            param["callBack"] = "onKeyExited"
            param["key"] = parkingKey
            param["latitude"] = location.coordinate.latitude
            param["longitude"] = location.coordinate.longitude
            
            self.eventSink!(param)
        })

        circleQuery?.observeReady {
            var param=[String:Any]()
            
            param["callBack"] = "onGeoQueryReady"
            param["result"] = key
            self.eventSink!(param)
        }
    }
  }

  public func onListen(withArguments arguments: Any?,
                     eventSink: @escaping FlutterEventSink) -> FlutterError? {
    self.eventSink = eventSink
    return nil
  }

  public func onCancel(withArguments arguments: Any?) -> FlutterError? {
    eventSink = nil
    return nil
  }
}
