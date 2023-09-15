package in.appyflow.geofire;

import android.util.Log;

import androidx.annotation.NonNull;

import com.firebase.geofire.GeoFire;
import com.firebase.geofire.GeoLocation;
import com.firebase.geofire.GeoQuery;
import com.firebase.geofire.GeoQueryEventListener;
import com.firebase.geofire.LocationCallback;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;
import com.google.firebase.database.DataSnapshot;

import java.util.ArrayList;
import java.util.HashMap;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

public class GeofirePlugin implements FlutterPlugin, MethodCallHandler, EventChannel.StreamHandler {
    static MethodChannel channel;
    static EventChannel eventChannel;
    private EventChannel.EventSink events;

    GeoFire geoFire;
    DatabaseReference databaseReference;
    GeoQuery geoQuery;

    public static void pluginInit(BinaryMessenger messenger) {
        GeofirePlugin geofirePlugin = new GeofirePlugin();

        channel = new MethodChannel(messenger, "geofire");
        channel.setMethodCallHandler(geofirePlugin);

        eventChannel = new EventChannel(messenger, "geofireStream");
        eventChannel.setStreamHandler(geofirePlugin);
    }

    @Override
    public void onMethodCall(MethodCall call, final Result result) {
        if (call.method.equals("initialize")) {
            String path = call.argument("path").toString();
            String root = call.argument("root").toString();
            int is_default = call.argument("is_default");

            if (is_default == 1) {
                databaseReference = FirebaseDatabase.getInstance().getReference(path);
            } else {
                databaseReference = FirebaseDatabase.getInstance(root).getReference(path);
            }

            geoFire = new GeoFire(databaseReference);

            result.success(geoFire.getDatabaseReference() != null);
        } else if (call.method.equals("setLocation")) {
            geoFire.setLocation(call.argument("id").toString(), new GeoLocation(Double.parseDouble(call.argument("lat").toString()), Double.parseDouble(call.argument("lng").toString())), new GeoFire.CompletionListener() {
                @Override
                public void onComplete(String key, DatabaseError error) {
                    result.success(error == null);
                }
            });
        } else if (call.method.equals("removeLocation")) {
            geoFire.removeLocation(call.argument("id").toString(), new GeoFire.CompletionListener() {
                @Override
                public void onComplete(String key, DatabaseError error) {
                    result.success(error == null);
                }
            });
        } else if (call.method.equals("getLocation")) {
            geoFire.getLocation(call.argument("id").toString(), new LocationCallback() {
                @Override
                public void onLocationResult(String key, GeoLocation location) {
                    HashMap<String, Object> map = new HashMap<>();
                    if (location != null) {
                        map.put("lat", location.latitude);
                        map.put("lng", location.longitude);
                        map.put("error", null);
                    } else {
                        map.put("error", String.format("There is no location for key %s in GeoFire", key));
                    }

                    result.success(map);
                }

                @Override
                public void onCancelled(DatabaseError databaseError) {
                    HashMap<String, Object> map = new HashMap<>();
                    map.put("error", "There was an error getting the GeoFire location: " + databaseError);

                    result.success(map);
                }
            });
        } else if (call.method.equals("queryAtLocation")) {
            geoFireArea(Double.parseDouble(call.argument("lat").toString()), Double.parseDouble(call.argument("lng").toString()), result, Double.parseDouble(call.argument("radius").toString()));
        } else if (call.method.equals("stopListener")) {
            if (geoQuery != null) {
                geoQuery.removeAllListeners();
                geoQuery = null;
            }

            result.success(true);
        } else {
            result.notImplemented();
        }
    }

    HashMap<String, Object> hashMap = new HashMap<>();

    private void geoFireArea(final double latitude, double longitude, final Result result, double radius) {
        try {
            final ArrayList<String> arrayListKeys = new ArrayList<>();

            if (geoQuery != null) {
                geoQuery.setLocation(new GeoLocation(latitude, longitude), radius);
            } else {
                geoQuery = geoFire.queryAtLocation(new GeoLocation(latitude, longitude), radius);
            }

            geoQuery.addGeoQueryEventListener(new GeoQueryEventListener() {
                @Override
                public void onKeyEntered(String key, GeoLocation location, DataSnapshot snapshot) {
                    if (events != null) {
                        hashMap.clear();
                        hashMap.put("callBack", "onKeyEntered");
                        hashMap.put("key", key);
                        hashMap.put("latitude", location.latitude);
                        hashMap.put("longitude", location.longitude);
                        hashMap.put("val", snapshot.getValue());
                        events.success(hashMap);
                    } else {
                        geoQuery.removeAllListeners();
                    }

                    arrayListKeys.add(key);
                }

                @Override
                public void onKeyExited(String key) {
                    arrayListKeys.remove(key);

                    if (events != null) {
                        hashMap.clear();
                        hashMap.put("callBack", "onKeyExited");
                        hashMap.put("key", key);
                        events.success(hashMap);
                    } else {
                        geoQuery.removeAllListeners();
                    }
                }

                @Override
                public void onKeyMoved(String key, GeoLocation location, DataSnapshot snapshot) {
                    if (events != null) {
                        hashMap.clear();

                        hashMap.put("callBack", "onKeyMoved");
                        hashMap.put("key", key);
                        hashMap.put("latitude", location.latitude);
                        hashMap.put("longitude", location.longitude);
                        hashMap.put("val", snapshot.getValue());

                        events.success(hashMap);
                    } else {
                        geoQuery.removeAllListeners();
                    }
                }

                @Override
                public void onKeyChanged(String key, GeoLocation location, DataSnapshot snapshot) {
                    if (events != null) {
                        hashMap.clear();

                        hashMap.put("callBack", "onKeyChanged");
                        hashMap.put("key", key);
                        hashMap.put("latitude", location.latitude);
                        hashMap.put("longitude", location.longitude);
                        hashMap.put("val", snapshot.getValue());

                        events.success(hashMap);
                    } else {
                        geoQuery.removeAllListeners();
                    }
                }

                @Override
                public void onGeoQueryReady() {
                    if (events != null) {
                        hashMap.clear();

                        hashMap.put("callBack", "onGeoQueryReady");
                        hashMap.put("result", arrayListKeys);

                        events.success(hashMap);
                    } else {
                        geoQuery.removeAllListeners();
                    }
                }

                @Override
                public void onGeoQueryError(DatabaseError error) {
                    if (events != null) {
                        events.error("Error ", "GeoQueryError", error);
                    } else {
                        geoQuery.removeAllListeners();
                    }
                }
            });
        } catch (Exception e) {
            e.printStackTrace();
            result.error("Error ", "General Error", e);
        }
    }

    @Override
    public void onListen(Object o, EventChannel.EventSink eventSink) {
        events = eventSink;
    }

    @Override
    public void onCancel(Object o) {
        geoQuery.removeAllListeners();
        events = null;
    }

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
        pluginInit(binding.getBinaryMessenger());
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
        eventChannel.setStreamHandler(null);
    }
}