//
//  HomeControlApp.swift
//  HomeControl
//
//  Created by Joachim Kittelberger on 02.01.24.
//  Copyright © 2024 Joachim Kittelberger. All rights reserved.
//

import SwiftUI




final class AppDelegate: NSObject, UIApplicationDelegate {
    
    func applicationDidFinishLaunching() {
        print(#function)
    }
    
    func applicationWillEnterForeground() {
        print(#function)
    }
    
    func applicationDidBecomeActive() {
        print(#function)
    }
    
    func applicationWillResignActive() {
        print(#function)
    }
    
    func applicationDidEnterBackground() {
        print(#function)
    }

    
    func applicationWillTerminate() {
        print(#function)
    }
    
    func applicationDidReceiveMemoryWarning() {
        print(#function)
    }
}





@main
struct HomeControlApp: App {

    @StateObject var shutterList = ShutterList()
    
    // Connectivity to iPhone and iWatch
    let connectivity = Connectivity.shared
    
    
    //this function will be called at startup before WindowGroup will be initialized
    init() {
        print("HomeControlApp.init()");
        // read userdefaults and write ite tho Jet32.shared
        // @AppStorage("name") var name = "Anonymous"
        initUserDefaults()
        loadUserDefaults()

        // Kommunikation mit Steuerung geht nur über iPhone mit z.B. UDPManager oder WCSession, ...
        let homeConnection = PLCComMgr.shared
        homeConnection.connect()
    }

    
    // Alternative 2 zu scenePhase
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(shutterList)
        }
        .onChange(of: scenePhase) { oldValue, newValue in
            switch newValue {
            case .active:
                print("App switched from \(oldValue) to phase \(newValue)")
            case .background:
                print("App switched from \(oldValue) to phase \(newValue)")
            case .inactive:
                print("App switched from \(oldValue) to phase \(newValue)")
            @unknown default:
                print("App switched from \(oldValue) to phase \(newValue)")
            }
        }
    }
}


/*
 #Preview {
 let shutterList = ShutterList()
 return ContentView()
 .environmentObject(shutterList)
 }
 */
