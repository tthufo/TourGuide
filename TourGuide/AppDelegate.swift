//
//  AppDelegate.swift
//  TourGuide
//
//  Created by Mac on 7/10/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        //FB_Plugin.shareInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        //GG_PlugIn.shareInstance().application(application, didFinishLaunchingWithOptions: launchOptions)

        
        Information.saveToken()
        
        Information.saveInfo()
        
        
        self.customTab()

        LTRequest.sharedInstance().initRequest()
        
        UITabBar.appearance().tintColor = UIColor(red: 232/255.0, green: 125/255.0, blue: 0/255.0, alpha: 1.0)

//        FirePush.shareInstance().didRegister()
        
        let nav = TG_Nav_ViewController.init(rootViewController: TG_Root_ViewController())
        
        nav.isNavigationBarHidden = true
        
        self.window?.rootViewController = nav
        
        self.window?.makeKeyAndVisible()

        return true
    }

//    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
//        return url.absoluteString.contains("fb499722440468827") ? FB_Plugin.shareInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation) : GG_PlugIn.shareInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
//    }
//    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
//        FB_Plugin.shareInstance().applicationDidBecomeActive(application)
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func application(_ application: UIApplication, shouldAllowExtensionPointIdentifier extensionPointIdentifier: UIApplicationExtensionPointIdentifier) -> Bool {
        if extensionPointIdentifier == .keyboard {
            return false
        }
        
        return true
    }
}

