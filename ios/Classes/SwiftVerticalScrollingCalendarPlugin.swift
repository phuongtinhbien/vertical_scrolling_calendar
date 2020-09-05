import Flutter
import UIKit

public class SwiftVerticalScrollingCalendarPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "vertical_scrolling_calendar", binaryMessenger: registrar.messenger())
    let instance = SwiftVerticalScrollingCalendarPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    result("iOS " + UIDevice.current.systemVersion)
  }
}
