import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // Handle Universal Links
  override func application(
    _ application: UIApplication,
    continue userActivity: NSUserActivity,
    restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void
  ) -> Bool {
    if let url = userActivity.webpageURL {
      // Handle the Universal Link URL
      print("Universal Link URL: \(url)")

      // Pass the URL to Flutter
      if let flutterViewController = window?.rootViewController as? FlutterViewController {
        let flutterChannel = FlutterMethodChannel(
          name: "app.channel.shared.data",
          binaryMessenger: flutterViewController.binaryMessenger
        )
        flutterChannel.invokeMethod("handleUniversalLink", arguments: url.absoluteString)
      }

      return true
    }

    return false
  }
}

/* OLD CODE  
override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
*/
