//
//  AppDelegate.swift
//  PoolDrive
//
//  Created by Jonah Schueller on 02.11.18.
//  Copyright © 2018 Jonah Schueller. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    static var `default`: AppDelegate!
    
    var window: UIWindow?
    var viewController: ViewController!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        applicationSetup()
        
        window = UIWindow(frame: UIScreen.main.bounds)
        
        window?.rootViewController = viewController
        
        window?.makeKeyAndVisible()
        
        return true
    }
    
    private func applicationSetup(){
        FirebaseApp.configure()
        
        if Auth.auth().currentUser != nil {
            print("logged in")
        }
        
        AppDelegate.default = self
        
        DataManager.initDataManager()
        
        viewController = ViewController(navigationBarClass: nil, toolbarClass: nil)
        
        DataManager.default.delegate = viewController
        
        DataManager.default.getRootPoolsFromFirestore { (error) in
            guard let error = error else {
                return
            }
            DataManager.default.processError(error)
        }
        
        printCacheDirectory()
    }
    
    
    func printCacheDirectory() {
        let fileManager = FileManager.default
        guard let cache = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            return
        }
        print("Local cache:")
        if let files = try? fileManager.contentsOfDirectory(atPath: cache.path) {
            if files.isEmpty {
                print("\t - Cache directory is empty.")
                return
            }
            for file in files {
                print("\t-\(file)")
            }
        }else {
            print("\t - There is no cache dir")
        }
    }
    
    var supportedInterfaceOrientations: UIInterfaceOrientationMask = .all
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return supportedInterfaceOrientations
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
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

