//
//  WatchHomeControlApp.swift
//  WatchHomeControl Watch App
//
//  Created by Joachim Kittelberger on 27.12.23.
//  Copyright © 2023 Joachim Kittelberger. All rights reserved.
//

import SwiftUI


// should only be used in WatchKitExtensions
import WatchKit
final class ExtensionDelegate: NSObject, WKExtensionDelegate {
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
}
 





@main
struct WatchHomeControl_Watch_AppApp: App {
    
    @StateObject var shutterList = ShutterList()

    // Connectivity to iPhone
    let connectivity = Connectivity.shared
    
    // Communication instance. Geht bei Watch nur über iPhone und WCSession ...
    let plcComMgr = PLCComMgr.shared
    

    
    
    
    @Environment(\.scenePhase) private var scenePhase

    // Alternative 2 zu scenePhase. Sollte aber nur in WatchKit-Extensions genutzt werden
    //@WKExtensionDelegateAdaptor(ExtensionDelegate.self) var extensionDelegate
    
    
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
