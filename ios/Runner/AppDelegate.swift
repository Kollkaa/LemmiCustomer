import UIKit
import Flutter
import GoogleMaps
//import Firebase


@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(

    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    
    
//    FirebaseApp.configure()
    //GMSServices.provideAPIKey("AIzaSyDQNmFyDJ9PWKjKwJkEo0yIl1dAoFJkANA")
    GMSServices.provideAPIKey("AIzaSyCBCCdxBWwC8mOJMKLGorr0Du7T6HNN3jg")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
      
//    override func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
//            super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
//    
//            InstanceID.instanceID().instanceID(handler: { (result, error) in
//                if let error = error {
//                    print("Error fetching remote instange ID: \(error)")
//                } else if let result = result {
//                    print("Remote instance ID token: \(result.token)")
//                }
//            })
//        }
}
