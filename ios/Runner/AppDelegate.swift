import UIKit
import Flutter

@main
@objc class AppDelegate: FlutterAppDelegate {
  var pendingPath: String?
  var fileChannel: FlutterMethodChannel?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    let controller = window?.rootViewController as! FlutterViewController
    fileChannel = FlutterMethodChannel(name: "app/openfile", binaryMessenger: controller.binaryMessenger)
    fileChannel?.setMethodCallHandler { [weak self] call, result in
      if call.method == "getInitialFile" {
        result(self?.pendingPath)
        self?.pendingPath = nil
      } else {
        result(FlutterMethodNotImplemented)
      }
    }

    if let url = launchOptions?[.url] as? URL {
      pendingPath = url.path
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  override func application(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey: Any] = [:]
  ) -> Bool {
    if url.isFileURL {
      fileChannel?.invokeMethod("openFile", arguments: url.path)
      return true
    }
    return super.application(app, open: url, options: options)
  }
}