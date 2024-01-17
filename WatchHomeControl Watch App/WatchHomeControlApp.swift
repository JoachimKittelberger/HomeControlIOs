//
//  WatchHomeControlApp.swift
//  WatchHomeControl Watch App
//
//  Created by Joachim Kittelberger on 27.12.23.
//  Copyright © 2023 Joachim Kittelberger. All rights reserved.
//

import SwiftUI

@main
struct WatchHomeControl_Watch_AppApp: App {
    
    @StateObject var shutterList = ShutterList()

    // Connectivity to iPhone
    let connectivity = Connectivity.shared
    
    // Communication instance. Geht bei Watch nur über iPhone und WCSession ...
    let plcComMgr = PLCComMgr.shared
    
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(shutterList)
        }
    }
}
