//
//  ContentView.swift
//  HomeControl2
//
//  Created by Joachim Kittelberger on 02.01.24.
//  Copyright © 2024 Joachim Kittelberger. All rights reserved.
//

import SwiftUI


// Wird für Handling der Anzeige der Tabs bebötigt
// das Enum als Tag() der View mitgeben. In $selectedTab wird dann immer der aktuell
// angezeigte Tab geschrieben
// mit     .onChange(of: selectedTab) { oldTab, newTab in
//         }
// kann dann auf die Änderung der Tab-Anzeige in der jeweiligen View reagiert werden
enum TabViews : Int {
    case NoTab = 0
    case ShutterListTab
    case StatusViewTab
    case PLCViewTab
    case SettingsViewTab

#if os(watchOS)
    case TestConnectivityView = 15
#endif
}





struct ContentView: View {

    @State private var selectedTab = TabViews.NoTab.rawValue

    
    var body: some View {
        NavigationStack {       // wird hier benötigt, damit in den ShutterDetailView nicht navigiert werden kann.
            TabView(selection: $selectedTab) {


                // TODO: TEST: Um Connectivity auf Watch zu testen
                // TODO: Remove also the setting of the first page below in code
/*
#if os(watchOS)
            TestConnectivityView(selectedTab: $selectedTab)
                .tabItem {
                    Image(systemName: "wrench.and.screwdriver")
                    Text("TestConnectivity")
                }
                .tag(TabViews.TestConnectivityView.rawValue)
#endif
*/
                ShutterListView(selectedTab: $selectedTab)
                    .tabItem {
                        Image(systemName: "window.shade.open")
                        Text("Rolläden")
                    }
                    .tag(TabViews.ShutterListTab.rawValue)
                StatusView(selectedTab: $selectedTab)
                    .tabItem {
                        Image(systemName: "bell")
                        Text("Status")
                    }
                    .tag(TabViews.StatusViewTab.rawValue)
                PLCView(selectedTab: $selectedTab)
                    .tabItem {
                        Image(systemName: "switch.2")
                        Text("Steuerung")
                    }
                    .tag(TabViews.PLCViewTab.rawValue)
    #if os(iOS)
                SettingsView(selectedTab: $selectedTab)
                    .tabItem {
                        Image(systemName: "gear")
                        Text("Einstellungen")
                    }
                    .tag(TabViews.SettingsViewTab.rawValue)
    #endif
            }
//#if os(watchOS)
            .tabViewStyle(.page)
//#endif
#if os(iOS)
            //.tabViewStyle(PageTabViewStyle())
            //.tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
#endif

            
//            #if os(watchOS)
//                .containerBackground(.gray.gradient, for: .navigation)
//            #endif
        
        
        }
 
    #if os(iOS)
        .padding(.top)          // evtl. nur auf iOS
        //.background(.red)
    #endif

        .onChange(of: selectedTab) { oldTab, newTab in
            print("ContentView.onChange: Change to tab \(selectedTab) Old: \(oldTab) New: \(newTab)")


            // TODO: just for Tests with connectivity
/*
#if os(watchOS)
            // if its the first initialisation, navigate to shutterListTab
            if (oldTab == TabViews.NoTab.rawValue) {
                selectedTab = TabViews.TestConnectivityView.rawValue
            }
#endif
*/
        }
        /*
        // wird statt viewDidLoad verwendet
        .onAppear {
            print("ContentView.onAppear tab \(selectedTab)")
        }
        .onDisappear() {
            print("ContentView.onDisappear")
        }
         */
        // used with own modifier
        .onViewDidLoad {
            // TODO: do something only one time in this closure
            // will be called after .onAppear
            print("ContentView.onViewDidLoad Modifier")
            
            // call .onChange for the first time the app starts
            selectedTab = TabViews.ShutterListTab.rawValue          // because we need the first onChange also in ShutterListTab
        }
   

    }
}




#Preview {
    @StateObject var shutterList = ShutterList()
    return ContentView()
        .environmentObject(shutterList)
}
