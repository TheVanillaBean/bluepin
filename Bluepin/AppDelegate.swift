//
//  AppDelegate.swift
//  bluepin
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
        
        Messaging.messaging().delegate = self
        
        if #available(iOS 10.0, *) {
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_,_ in })
            
            UNUserNotificationCenter.current().delegate = self
            
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        
        FirebaseApp.configure()
        
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
        Messaging.messaging().shouldEstablishDirectChannel = false
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        Hotline.sharedInstance().unreadCount(completion: { (count:Int) -> Void in
            UIApplication.shared.applicationIconBadgeNumber = count;
        });
        
        Messaging.messaging().shouldEstablishDirectChannel = true

    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Hotline.sharedInstance().updateDeviceToken(deviceToken as Data!)

        Messaging.messaging().apnsToken = deviceToken

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
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Unable to register for remote notifications: \(error.localizedDescription)")
    }

}

@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {
    
    // Receive displayed notifications for iOS 10 devices.
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
        
        
        // Change this to your preferred presentation option
        completionHandler([])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
    }
}

extension AppDelegate : MessagingDelegate {

    func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
    }
    // [END refresh_token]
    // [START ios_10_data_message]
    // Receive data messages on iOS 10+ directly from FCM (bypassing APNs) when the app is in the foreground.
    // To enable direct data messages, you can set Messaging.messaging().shouldEstablishDirectChannel to true.
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        print("Received data message: \(remoteMessage.appData)")
    }

    func application(received remoteMessage: MessagingRemoteMessage) {
    }
}

