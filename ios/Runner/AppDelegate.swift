import UIKit
import Flutter
import GoogleMaps
import GoogleMobileAds

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Provide API key for Google Maps
    GMSServices.provideAPIKey("AIzaSyBYBZZenOW9HLm1THl8_Sz1SepUZ-fXkiw")

    // Initialize Google Mobile Ads SDK
    GADMobileAds.sharedInstance().start(completionHandler: nil)

    // Notification setup
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self
      let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
      UNUserNotificationCenter.current().requestAuthorization(
        options: authOptions,
        completionHandler: { _, _ in }
      )
    } else {
      let settings: UIUserNotificationSettings =
        UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
      application.registerUserNotificationSettings(settings)
    }
    application.registerForRemoteNotifications()

    // Prevent the app from sleeping
    UIApplication.shared.isIdleTimerDisabled = true

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}