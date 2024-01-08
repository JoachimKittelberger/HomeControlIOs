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
    
    
    // TODO: Test Connectivity
    let connectivity = Connectivity.sharedInstance
    
    
    //this function will be called at startup before WindowGroup will be initialized
    init() {
        print("HomeControl2App.init()");

        // Geht nur über iPhone mit z.B. UDPManager oder WCSession, ...
        let plcComMgr = PlcComMgr.sharedInstance
        // TODO read userdefaults and write ite tho Jet32.sharedInstance
        // @AppStorage("name") var name = "Anonymous"

        // sollte nur einmal aufgerufen werden
        //homeControlConnection.udpPortSend = UInt16(50000)
        //homeControlConnection.udpPortReceive = UInt16(50001)
        //homeControlConnection.host = "192.168.30.51"
        //homeControlConnection.timeoutJet32 = UInt16(2000)

        //homeControlConnection.printSocketBindingInfo()
        //print("set Jet32 Settings to Instance")
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
