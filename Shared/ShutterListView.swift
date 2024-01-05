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
    
    var body: some View {
        NavigationStack {
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
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        // Perform an action here.
//                        WKInterfaceDevice.current().play(.click)          // just vibrate
                        #if os(watchOS)
                            WKInterfaceDevice.current().play(.start)            // play sound and vibrate
                        #endif
                        print("Open all Windows pressed")
                    } label: {
                        Image(systemName:"window.shade.open")
                        
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        // Perform an action here.
//                        WKInterfaceDevice.current().play(.click)          // just vibrate
                        #if os(watchOS)
                            WKInterfaceDevice.current().play(.start)            // play sound and vibrate
                        #endif
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
    let shutterList = ShutterList()
    return ShutterListView()
        .environmentObject(shutterList)
}

