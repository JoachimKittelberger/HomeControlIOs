//
//  ContentView.swift
//  WatchHomeControl Watch App
//
//  Created by Joachim Kittelberger on 27.12.23.
//  Copyright © 2023 Joachim Kittelberger. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    
    var body: some View {
        NavigationStack {       // wird hier benötigt, damit in den ShutterDetailView nicht navigiert werden kann.
            TabView {
                ShutterListView()
                PLCView()
                SettingsView()
            }
            .tabViewStyle(.page)
//        .tabViewStyle(.verticalPage)
//        .containerBackground(.gray.gradient, for: .navigation)
            
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        // Perform an action here.
//                        WKInterfaceDevice.current().play(.click)          // just vibrate
                        WKInterfaceDevice.current().play(.start)            // play sound and vibrate
                        print("Open all Windows pressed")
                    } label: {
                        Image(systemName:"window.shade.open")
                        
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        // Perform an action here.
//                        WKInterfaceDevice.current().play(.click)          // just vibrate
                        WKInterfaceDevice.current().play(.start)            // play sound and vibrate
                        print("Close alle Windows pressed")
                    } label: {
                        Image(systemName:"window.shade.closed")
                    }
                }
 /*               ToolbarItemGroup(placement: .bottomBar) {
                    Button {
                        // Perform an action here.
                    } label: {
                        Image(systemName:"suit.diamond")
                    }
                    
                    Button {
                        // Perform an action here.
                    } label: {
                        Image(systemName:"star")
                    }
                    .controlSize(.large)
                    .background(.red, in: Capsule())
                    
                    Button {
                        // Perform an action here.
                    } label: {
                        Image(systemName:"suit.spade")
                    }
                }
*/
            }
            
        }
    }
}





#Preview {
    @StateObject var shutterList = ShutterList()
    return ContentView()
        .environmentObject(shutterList)
}

