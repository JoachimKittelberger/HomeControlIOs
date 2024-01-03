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
    
    // Geht nur über iPhone mit z.B. UDPManager oder WCSession, ...
//    let homeControlConnection = Jet32.sharedInstance

    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(shutterList)
        }
    }
}
