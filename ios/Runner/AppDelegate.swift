// pub.dev의 google_maps_flutter 안의 ios에서 swift 사용하는 코드를 복사해서 그대로 붙여넣기 한 후,
//  "YOUR KEY HERE" 안에 API KEY 넣기!
import UIKit
import Flutter
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("AIzaSyDrpZh2C4s9ts8l7v8uDDeZrjOvqiUZegA")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
