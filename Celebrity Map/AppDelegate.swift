//
//  AppDelegate.swift
//  Celebrity Map
//
//  Created by Yinpeng Chen on 2018-06-12.
//  Copyright © 2018 Yinpeng Chen. All rights reserved.
//

import UIKit
import CoreData
import Firebase
import FirebaseCore
import UserNotifications
import FirebaseMessaging
import FirebaseInstanceID
import AppsFlyerLib


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate, UNUserNotificationCenterDelegate, AppsFlyerTrackerDelegate {
    
    @objc func sendLaunch(app:Any) {
        AppsFlyerTracker.shared().trackAppLaunch()
    }
    
    
    
    func onConversionDataSuccess(_ data: [AnyHashable: Any]) {
        print("\(data)")
        if let status = data["af_status"] as? String{
            if(status == "Non-organic"){
                if let sourceID = data["media_source"] , let campaign = data["campaign"]{
                    print("This is a Non-Organic install. Media source: \(sourceID)  Campaign: \(campaign)")
                }
            } else {
                print("This is an organic install.")
            }
            if let is_first_launch = data["is_first_launch"] , let launch_code = is_first_launch as? Int {
                if(launch_code == 1){
                    print("First Launch")
                } else {
                    print("Not First Launch")
                }
            }
        }
    }
    
    func onConversionDataFail(_ error: Error) {
        print("\(error)")
    }
    
    //Handle Direct Deep Link
    func onAppOpenAttribution(_ attributionData: [AnyHashable: Any]) {
        //Handle Deep Link Data
        print("onAppOpenAttribution data:")
        for (key, value) in attributionData {
            print(key, ":",value)
        }
    }
    func onAppOpenAttributionFailure(_ error: Error) {
        print("\(error)")
    }
    
    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
//        UIApplication.shared.statusBarStyle = .lightContent
        
        //change the bar title color
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key(rawValue: NSAttributedString.Key.foregroundColor.rawValue): UIColor.white]
        
        //Remote Push Notification Configuration
        
        FirebaseApp.configure()

        
        UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .alert, .sound]) { (success, error) in
            if error != nil{
                print("Authorization Failed")
            }else{
                print("Authorization Good")
                UNUserNotificationCenter.current().delegate = self
                Messaging.messaging().delegate = self
                application.registerForRemoteNotifications()
            }
        }
        

        
        UIApplication.shared.applicationIconBadgeNumber = 0

        
        // weChat
        WXApi.registerApp("wxb2569af0eeceb0cb")
        
        AppsFlyerTracker.shared().appsFlyerDevKey = "BZYCxNnRbkPvSPUYxnKoHR"
        AppsFlyerTracker.shared().appleAppID = "1401680756"
        AppsFlyerTracker.shared().delegate = self
        /* Set isDebug to true to see AppsFlyer debug logs */
        AppsFlyerTracker.shared().isDebug = true
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(sendLaunch),
                                               // For Swift version < 4.2 replace name argument with the commented out code
            name: UIApplication.didBecomeActiveNotification, //.UIApplicationDidBecomeActive for Swift < 4.2
            object: nil)

        
        return true
    }
    
    func ConnectToFCM(){
        Messaging.messaging().shouldEstablishDirectChannel = true
    }
    
//    didrefres
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        Messaging.messaging().shouldEstablishDirectChannel = false
        
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.

    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        ConnectToFCM()


    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "Celebrity_Map")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    
    //微信分享完毕后的回调（只有使用真实的AppID才能收到响应）
    func onResp(_ resp: BaseResp!) {
        if resp.isKind(of: SendMessageToWXResp.self) {//确保是对我们分享操作的回调
            if resp.errCode == WXSuccess.rawValue{//分享成功
                print("分享成功")
            }else if resp.errCode == WXErrCodeCommon.rawValue {//普通错误类型
                print("分享失败：普通错误类型")
            }else if resp.errCode == WXErrCodeUserCancel.rawValue {//用户点击取消并返回
                print("分享失败：用户点击取消并返回")
            }else if resp.errCode == WXErrCodeSentFail.rawValue {//发送失败
                print("分享失败：发送失败")
            }else if resp.errCode == WXErrCodeAuthDeny.rawValue {//授权失败
                print("分享失败：授权失败")
            }else if resp.errCode == WXErrCodeUnsupport.rawValue {//微信不支持
                print("分享失败：微信不支持")
            }
        }
    }
    
    // Open URI-scheme for iOS 9 and above
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        AppsFlyerTracker.shared().handleOpen(url, options: options)
        return true
    }
    
    // Report Push Notification attribution data for re-engagements
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        AppsFlyerTracker.shared().handlePushNotification(userInfo)
    }
    
    
    
    
    //MARK - Push remote notification
    
}


// User logic
fileprivate func walkToSceneWithParams(params: [AnyHashable:Any]) {
    let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
    UIApplication.shared.windows.first?.rootViewController?.dismiss(animated: true, completion: nil)

    var fruitNameStr = ""

    if let thisFruitName = params["fruit_name"] as? String {
        fruitNameStr = thisFruitName
    } else if let linkParam = params["link"] as? String {
        guard let url = URLComponents(string: linkParam) else {
            print("Could not extract query params from link")
            return
        }
        if let thisFruitName = url.queryItems?.first(where: { $0.name == "fruit_name" })?.value {
            fruitNameStr = thisFruitName
        }
    }

    let destVC = fruitNameStr + "_vc"
//    if let newVC = storyBoard.instantiateVC(withIdentifier: destVC) {
//
//        print("AppsFlyer routing to section: \(destVC)")
//        newVC.attributionData = params
//
//        UIApplication.shared.windows.first?.rootViewController?.present(newVC, animated: true, completion: nil)
//    } else {
//        print("AppsFlyer: could not find section: \(destVC)")
//    }
}
