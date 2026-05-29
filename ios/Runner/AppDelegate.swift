import UIKit
import Flutter

@main
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        let controller = FlutterViewController(project: nil, nibName: nil, bundle: nil)
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = controller
        self.window?.makeKeyAndVisible()
        
        GeneratedPluginRegistrant.register(with: controller)
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}