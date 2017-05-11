//
//  AppDelegate.swift
//  Bizmi
//
//  Created by Alex on 7/19/16.
//  Copyright © 2016 Alex. All rights reserved.
//

import UIKit
import Firebase
import FirebaseInstanceID
import FirebaseMessaging
import UserNotifications
import BRYXBanner

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    fileprivate let HOTLINE_API_ID =  "8619ec6b-6c37-4b76-b6fa-88287d5c9c76"
    fileprivate let HOTLINE_API_KEY = " 07f98717-4061-4753-80a4-0c898d502c86"
    
    public var deviceTokenString: String!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
 
        let config = HotlineConfig.init(appID: HOTLINE_API_ID, andAppKey: HOTLINE_API_KEY)
        config?.voiceMessagingEnabled = true
        config?.pictureMessagingEnabled = true
        config?.cameraCaptureEnabled = true
        config?.agentAvatarEnabled = true
        config?.showNotificationBanner = true
        config?.notificationSoundEnabled = true
        
        Hotline.sharedInstance().initWith(config)
        
        Hotline.sharedInstance().unreadCount(completion: { (count:Int) -> Void in
            print("Unread count (Async) :\(count)")
        });
        
        if #available(iOS 10.0, *) {
            let authOptions : UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_,_ in })
            
            UNUserNotificationCenter.current().delegate = self
            FIRMessaging.messaging().remoteMessageDelegate = self
            
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        
        FIRApp.configure()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.tokenRefreshNotification),
                                               name: .firInstanceIDTokenRefresh,
                                               object: nil)
        
        if Hotline.sharedInstance().isHotlineNotification(launchOptions){
            Hotline.sharedInstance().handleRemoteNotification(launchOptions, andAppstate: application.applicationState)
        }
        
        self.customizeNavigationBar()
        
        return true
    }

    
    func customizeNavigationBar(){
        
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
        
        UINavigationBar.appearance().barTintColor = DARK_PRIMARY_COLOR
        
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName:UIColor.white]
        
        UINavigationBar.appearance().tintColor = UIColor.white
        
    }


    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        FIRMessaging.messaging().disconnect()

    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
//        let unreadCount : NSInteger = Hotline.u
//        UIApplication.shared.applicationIconBadgeNumber = unreadCount;
        
        Hotline.sharedInstance().unreadCount(completion: { (count:Int) -> Void in
            UIApplication.shared.applicationIconBadgeNumber = count;
        });
        
        connectToFcm()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Hotline.sharedInstance().updateDeviceToken(deviceToken as Data!)
        FIRInstanceID.instanceID().setAPNSToken(deviceToken, type: FIRInstanceIDAPNSTokenType.prod)
        
        var token: String = ""
        for i in 0..<deviceToken.count {
            token += String(format: "%02.2hhx", deviceToken[i] as CVarArg)
        }
        
        self.deviceTokenString = token
        
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        
        if Hotline.sharedInstance().isHotlineNotification(userInfo){
            Hotline.sharedInstance().handleRemoteNotification(userInfo, andAppstate: application.applicationState)
        }else{
            
            if let info = userInfo["aps"] as? Dictionary<String, AnyObject> {
                
                if  let alert = info["alert"] {
                    
                    let banner = Banner(title: "New Notification", subtitle: alert as? String, image: UIImage(named: "AppIcon"), backgroundColor: DARK_PRIMARY_COLOR)
                    banner.dismissesOnTap = true
                    banner.show(duration: 5.0)
                }
                
            }
        }
        
    }


    func tokenRefreshNotification(_ notification: Notification) {
        connectToFcm()
    }
    
    func connectToFcm() {
        FIRMessaging.messaging().connect { (error) in
            if (error != nil) {
                print("Unable to connect with FCM. \(error)")
            } else {
                print("Connected to FCM.")
            }
        }
    }

}

@available(iOS 10.0, *)
func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
}

@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        
        if let info = userInfo["aps"] as? Dictionary<String, AnyObject> {
            
            if  let alert = info["alert"] {
                
                let banner = Banner(title: "New Notification", subtitle: alert as? String, image: UIImage(named: "AppIcon"), backgroundColor: DARK_PRIMARY_COLOR)
                banner.dismissesOnTap = true
                banner.show(duration: 5.0)
            }
            
        }
    }
}

extension AppDelegate : FIRMessagingDelegate {
    func applicationReceivedRemoteMessage(_ remoteMessage: FIRMessagingRemoteMessage) {
    }
}

