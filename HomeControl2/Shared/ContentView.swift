//
//  ContentView.swift
//  HomeControl2
//
//  Created by Joachim Kittelberger on 02.01.24.
//  Copyright © 2024 Joachim Kittelberger. All rights reserved.
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

//            #if os(watchOS)
//                .containerBackground(.gray.gradient, for: .navigation)
//            #endif
        }
 
    #if os(iOS)
        .padding(.top)          // evtl. nur auf iOS
        //.background(.red)
    #endif


    }
}




#Preview {
    @StateObject var shutterList = ShutterList()
    return ContentView()
        .environmentObject(shutterList)
}
