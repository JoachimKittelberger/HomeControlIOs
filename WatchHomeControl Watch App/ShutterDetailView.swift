//
//  ShutterDetailView.swift
//  WatchHomeControl Watch App
//
//  Created by Joachim Kittelberger on 27.12.23.
//  Copyright © 2023 Joachim Kittelberger. All rights reserved.
//

import SwiftUI


struct ShutterDetailView: View {
    let shutterItem: ShutterItem
 
    // geht nicht, da Watch-OS keine UDP-Sockets unterstützt
//    let homeControlConnection = Jet32.sharedInstance

    
    var body: some View {
        VStack {
            Spacer()
            Text(shutterItem.name)
                .font(.title3)
            Spacer()
            
            HStack {
                Button("Auf") {
//                    WKInterfaceDevice.current().play(.click)          // just vibrate
                    WKInterfaceDevice.current().play(.start)            // play sound and vibrate
                    print(shutterItem.name + " Up pressed")
                }
                //.buttonStyle(.bordered)
                Button("Ab") {
//                    WKInterfaceDevice.current().play(.click)          // just vibrate
                    WKInterfaceDevice.current().play(.start)            // play sound and vibrate
                    print(shutterItem.name + " Down pressed")
                }
                //.buttonStyle(.borderedProminent)
            }
        }
    }
}



#Preview {
    let item = ShutterItem(name: "Jalousie links", ID: Shutters.BlindLeft.rawValue, isEnabled: true, outputUp: 100000203, outputDown: 100000204)
    return ShutterDetailView(shutterItem: item)
}
