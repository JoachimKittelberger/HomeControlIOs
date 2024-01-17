//
//  HomeControl2App.swift
//  HomeControl2
//
//  Created by Joachim Kittelberger on 02.01.24.
//  Copyright © 2024 Joachim Kittelberger. All rights reserved.
//

import SwiftUI

@main
struct HomeControl2App: App {

    @StateObject var shutterList = ShutterList()
    
    
    // TODO: Test Connectivity to iPhone and iWatch
    let connectivity = Connectivity.shared
    
    
    //this function will be called at startup before WindowGroup will be initialized
    init() {
        print("HomeControl2App.init()");

        // Kommunikation mit Steuerung geht nur über iPhone mit z.B. UDPManager oder WCSession, ...
        let _ = PLCComMgr.shared
        
        // read userdefaults and write ite tho Jet32.shared
        // @AppStorage("name") var name = "Anonymous"
        initUserDefaults()
        loadUserDefaults()
    }

    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(shutterList)
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
