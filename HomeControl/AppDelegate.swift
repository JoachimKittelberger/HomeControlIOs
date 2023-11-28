//
//  AppDelegate.swift
//  HomeControl
//
//  Created by Joachim Kittelberger on 07.06.17.
//  Copyright © 2017 Joachim Kittelberger. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    // const for UserDefaults
    let UDPPORTSEND = "udpPortSend"
    let UDPPORTRECEIVE = "udpPortReceive"
    let HOST = "host"
    let TIMEOUTJET32 = "timeout"

    
    
    override init() {
        super.init()
        
        // load Defaultvalues for UserSettings
        let userDefaults = UserDefaults.standard
        if let url = Bundle.main.url(forResource: "appdefaults", withExtension: "plist"), let appDefaults = NSDictionary(contentsOf: url)
        {
            userDefaults.register(defaults: appDefaults as! [String : AnyObject])
        }
    }

    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        
        // TODO Jet32
        let homeControlConnection = Jet32.sharedInstance
        let homeControlConnectionNW = Jet32NW.sharedInstance

        
        // Load from UserDefaults
        // TODO: Könnte auch in ViewController mit var userDefaults = UserDefaults.standard und dann Zugriff über userdefaults.integer(forKey: ...) gemacht werden
        let userDefaults = UserDefaults.standard
        homeControlConnection.udpPortSend = UInt16(userDefaults.integer(forKey: UDPPORTSEND))
        homeControlConnection.udpPortReceive = UInt16(userDefaults.integer(forKey: UDPPORTRECEIVE))
        homeControlConnection.host = userDefaults.string(forKey: HOST)!
        homeControlConnection.timeoutJet32 = UInt16(userDefaults.integer(forKey: TIMEOUTJET32))
        
        print("application.didFinishLaunchingWithOptions");
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        print("application.applicationWillResignActive");
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.

        // TODO Jet32
        let homeControlConnection = Jet32.sharedInstance
        let homeControlConnectionNW = Jet32NW.sharedInstance
        
        // store data to UserDefaults
        // TODO: Könnte auch in ViewController mit var userDefaults = UserDefaults.standard und dann Zugriff über set(...) gemacht werden
        // TODO: könnte auch bei jeder Änderung sofort abgespeichert werden
        let userDefaults = UserDefaults.standard
        userDefaults.set(Int(homeControlConnection.udpPortSend), forKey: UDPPORTSEND)
        userDefaults.set(Int(homeControlConnection.udpPortReceive), forKey: UDPPORTRECEIVE)
        userDefaults.set((homeControlConnection.host), forKey: HOST)
        userDefaults.set(Int(homeControlConnection.timeoutJet32), forKey: TIMEOUTJET32)
        
        print("application.applicationDidEnterBackground");
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        print("application.applicationWillEnterForeground");
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        print("application.applicationDidBecomeActive");
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        print("application.applicationWillTerminate");
    }


}

