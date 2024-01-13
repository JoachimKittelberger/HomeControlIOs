//
//  ShutterListView.swift
//  WatchHomeControl Watch App
//
//  Created by Joachim Kittelberger on 27.12.23.
//  Copyright © 2023 Joachim Kittelberger. All rights reserved.
//

import SwiftUI



struct ShutterListView: View {
    @EnvironmentObject private var shutterListModel: ShutterList
    @Binding var selectedTab: Int
    
    var body: some View {
        //NavigationStack {
            List {
                ForEach($shutterListModel.items) { $item in
                    NavigationLink(destination: ShutterDetailView(shutterItem: item)) {
                        Text(item.name)
                        #if os(iOS)
                            .font(.title2)
                            //.padding(.vertical)
                            .frame(height: 40.0)
                        #endif
                    }
                }
                
                if (shutterListModel.items.isEmpty) {
                    Text("No items found")
                        .foregroundStyle(.gray)
                }
            }
            .navigationTitle("Rolläden")
//            .navigationBarTitleDisplayMode(.inline)
            .navigationBarTitleDisplayMode(.large)
        #if os(watchOS)
            //.listStyle(.plain)               // nur für watchOS
            .listStyle(.elliptical)               // nur für watchOS
        #endif

        // damit werden ... für den Tab-Switcher angezeigt, ohne Überlappung durch die Liste
        #if os(iOS)
            .padding(.bottom, 50)
        #endif
        #if os(watchOS)
            .padding(.bottom, 1)
        #endif


            .toolbar {
                // Toolbarbutton for all blinds up
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                    #if os(watchOS)
                        // Perform an action here.
//                        WKInterfaceDevice.current().play(.click)          // just vibrate
                        WKInterfaceDevice.current().play(.start)            // play sound and vibrate
                    #endif
                        print("Open all blinds pressed")

                        let homeControlConnection = PlcComMgr.sharedInstance

                        homeControlConnection.setDelegate(delegate: nil)
                        homeControlConnection.connect()
                        let _ = homeControlConnection.setFlag(offsetFlagUp + UInt(Shutters.BlindLeft.rawValue), tag: 0)       // Offset for Flags up
                        let _ = homeControlConnection.setFlag(offsetFlagUp + UInt(Shutters.BlindMiddle.rawValue), tag: 0)       // Offset for Flags up
                        let _ = homeControlConnection.setFlag(offsetFlagUp + UInt(Shutters.BlindRight.rawValue), tag: 0)       // Offset for Flags up
                        //homeControlConnection.setDelegate(delegate: nil)
                    } label: {
                        Image(systemName:"blinds.horizontal.open")
                    }
                }
                // Toolbarbutton for all blinds down
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                    #if os(watchOS)
                        // Perform an action here.
//                        WKInterfaceDevice.current().play(.click)          // just vibrate
                        WKInterfaceDevice.current().play(.start)            // play sound and vibrate
                    #endif
                        print("Close alle blinds pressed")
                        let homeControlConnection = PlcComMgr.sharedInstance

                        homeControlConnection.setDelegate(delegate: nil)
                        homeControlConnection.connect()
                        let _ = homeControlConnection.setFlag(offsetFlagDown + UInt(Shutters.BlindLeft.rawValue), tag: 0)       // Offset for Flags down
                        let _ = homeControlConnection.setFlag(offsetFlagDown + UInt(Shutters.BlindMiddle.rawValue), tag: 0)       // Offset for Flags down
                        let _ = homeControlConnection.setFlag(offsetFlagDown + UInt(Shutters.BlindRight.rawValue), tag: 0)       // Offset for Flags down
                        //homeControlConnection.setDelegate(delegate: nil)
                    } label: {
                        Image(systemName:"blinds.horizontal.closed")
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

            .onChange(of: selectedTab) { oldTab, newTab in
                print("ShutterListView.onChange: Change to tab \(selectedTab) Old: \(oldTab) New: \(newTab)")
                if (newTab == TabViews.ShutterListTab.rawValue) {
                    print("ShutterListView Visible")
                }
                if (oldTab == TabViews.ShutterListTab.rawValue) {
                    print("ShutterListView Invisible")
                }
            }
        //}

    }
}





#Preview {
    let shutterList = ShutterList()
    return ShutterListView(selectedTab: .constant(TabViews.ShutterListTab.rawValue))
        .environmentObject(shutterList)
}

