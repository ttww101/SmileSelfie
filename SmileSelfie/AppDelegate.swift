//
//  AppDelegate.swift
//  SmileSelfie
//
//  Created by Wu on 2019/5/29.
//  Copyright © 2019 amG. All rights reserved.
//

import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, JPUSHRegisterDelegate {
    
    var window: UIWindow?
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        //JPush
        let entity = JPUSHRegisterEntity()
        if #available(iOS 12.0, *) {
            entity.types = Int(JPAuthorizationOptions.alert.rawValue|JPAuthorizationOptions.badge.rawValue|JPAuthorizationOptions.sound.rawValue|JPAuthorizationOptions.providesAppNotificationSettings.rawValue)
        } else {
            entity.types = Int(JPAuthorizationOptions.alert.rawValue|JPAuthorizationOptions.badge.rawValue|JPAuthorizationOptions.sound.rawValue)
        }
        JPUSHService.register(forRemoteNotificationConfig: entity, delegate: self)
        JPUSHService.setup(withOption: launchOptions, appKey: "b168c8d8f52899d4d82f6779", channel: "smile channel", apsForProduction: false)
        JPUSHService.registrationIDCompletionHandler { (resCode, id) in
            if resCode == 0 {
                print("registrationID获取成功：\(String(describing: id))")
            } else {
                print("registrationID获取失敗：\(id ?? "no id")")
            }
        }
        
        return true
    }
    
    //MARK: JPush Service
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("did register the deviceToken  \(deviceToken)")
        NotificationCenter.default.post(name: Notification.Name(rawValue: "DidRegisterRemoteNotification"), object: deviceToken)
        JPUSHService.registerDeviceToken(deviceToken)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("did fail to register for remote notification with error ", error)
    }
    
    func jpushNotificationCenter(_ center: UNUserNotificationCenter!, openSettingsFor notification: UNNotification?) {
        if let trigger = notification?.request.trigger {
            if (trigger is UNPushNotificationTrigger) {
                //从通知界面直接进入应用
            } else {
                //从通知设置界面进入应用
            }
        } else {
            //从通知设置界面进入应用
        }
    }
    
    @available(iOS 10.0, *)
    func jpushNotificationCenter(_ center: UNUserNotificationCenter!, willPresent notification: UNNotification!,
                                 withCompletionHandler completionHandler: ((Int) -> Void)!) {
        let userInfo = notification.request.content.userInfo
        if let trigger = notification?.request.trigger {
            if (trigger is UNPushNotificationTrigger) {
                JPUSHService.handleRemoteNotification(userInfo)
            } else {
            }
        } else {
        }
        completionHandler(Int(JPAuthorizationOptions.alert.rawValue|JPAuthorizationOptions.badge.rawValue|JPAuthorizationOptions.sound.rawValue))
    }
    
    func jpushNotificationCenter(_ center: UNUserNotificationCenter!, didReceive response: UNNotificationResponse!, withCompletionHandler completionHandler: (() -> Void)!) {
        
        let userInfo = response.notification.request.content.userInfo
        
        if response.notification.request.trigger is UNPushNotificationTrigger {
            JPUSHService.handleRemoteNotification(userInfo);
        }
        completionHandler()
    }
}

