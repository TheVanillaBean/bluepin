import UIKit;
import Foundation;
import SinchVerification;

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

        NSLog("Sinch Verification SDK version %@", SinchVerification.version());
        
        return true;
    }
}