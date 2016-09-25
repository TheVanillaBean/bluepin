//
//  AppDelegate.swift
//  Bizmi
//
//  Created by Alex on 7/19/16.
//  Copyright © 2016 Alex. All rights reserved.
//

import UIKit
import PubNub
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, PNObjectEventListener {

    let BACKENDLESS_APP_ID = "127AF0A5-6FB8-985E-FF8C-2EE5FFB8FF00"
    let BACKENDLESS_SECRET_KEY = "29070F55-9D89-30A2-FF34-0550B9057200"
    let BACKENDLESS_VERSION_NUM = "v1"
    
    
    var backendless = Backendless.sharedInstance()
        
    var window: UIWindow?
    
    lazy var client: PubNub = {
        let config = PNConfiguration(publishKey: "pub-c-62a2e0d2-c6d4-405a-9446-e2d18166e536", subscribeKey: "sub-c-6b67ad2e-64b9-11e6-8de8-02ee2ddab7fe")
        let pub = PubNub.client(with: config)
        return pub
    }()
    
    override init() {
        super.init()
        client.add(self)
    }
    
    func client(_ client: PubNub, didReceive status: PNStatus) {
        if status.isError {
            showAlert(status.isError.description)
        }
    }
    
    //Dialogue showing error
    func showAlert(_ error: String) {
        let alertController = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(OKAction)
        self.window?.rootViewController?.present(alertController, animated: true, completion:nil)
    }
    


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        FIRApp.configure()
        
        backendless.initApp(BACKENDLESS_APP_ID, secret:BACKENDLESS_SECRET_KEY, version:BACKENDLESS_VERSION_NUM)
        
        customizeNavigationBar()
                        
        return true
    }

    
    func customizeNavigationBar(){
        
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
        
        // Set navigation bar tint / background colour
        UINavigationBar.appearance().barTintColor = DARK_PRIMARY_COLOR
        
        // Set Navigation bar Title colour
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName:UIColor.white]
        
        // Set navigation bar ItemButton tint colour
        //UIBarButtonItem.appearance().tintColor = UIColor.yellowColor()
        
        //Set navigation bar Back button tint colour
        UINavigationBar.appearance().tintColor = UIColor.white
        
        
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

