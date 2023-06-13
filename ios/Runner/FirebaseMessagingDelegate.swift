// FirebaseMessagingDelegate.swift

import Flutter
import FirebaseMessaging

public class FirebaseMessagingDelegate: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "shared_ride_channel", binaryMessenger: registrar.messenger())
    let instance = FirebaseMessagingDelegate()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    // Handle method calls from Flutter here
    // ...
  }
}
