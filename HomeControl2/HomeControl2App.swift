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
    // Geht nur über iPhone mit z.B. UDPManager oder WCSession, ...
    //    let homeControlConnection = Jet32.sharedInstance


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
