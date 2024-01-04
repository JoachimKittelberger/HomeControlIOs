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
 
    
    var body: some View {
        VStack {
            #if os(watchOS)
                Spacer()      // nur für WatchOS
            #endif
            Text(shutterItem.name)
                .font(.title2)
            #if os(watchOS)
                Spacer()      // nur für WatchOS
            #endif

            HStack {
                Button {
                    #if os(watchOS)
//                    WKInterfaceDevice.current().play(.click)          // just vibrate
                        WKInterfaceDevice.current().play(.start)            // play sound and vibrate, only for WatchOS
                    #endif
                    print(shutterItem.name + " Up pressed")
                } label: {
                    Text("Auf")
                    #if os(iOS)
                        //.padding(.horizontal, 20)
                        .padding(.vertical, 8)
                        .frame(width: 100)
                        .foregroundColor(.white)
                        .background(.green)
                        .cornerRadius(8)
                    #endif
                }
                #if os(iOS)
                    //.buttonStyle(.bordered)     // only for iOS
                #endif
                   
                
                Button {
                    #if os(watchOS)
//                    WKInterfaceDevice.current().play(.click)          // just vibrate
                        WKInterfaceDevice.current().play(.start)            // play sound and vibrate, only for WatchOS
                    #endif
                    print(shutterItem.name + " Down pressed")
                } label: {
                    Text("Ab")
                    #if os(iOS)
                        //.padding(.horizontal, 20)
                        .padding(.vertical, 8)
                        .frame(width: 100)
                        .foregroundColor(.white)
                        .background(.green)
                        .cornerRadius(8)
                    #endif
                }
                #if os(iOS)
                    //.buttonStyle(.bordered)     // only for iOS
                #endif
                //.buttonStyle(.borderedProminent)
                
            }
            #if os(watchOS)
                Spacer()      // nur für WatchOS
            #endif
        }
    }
}



#Preview {
    let item = ShutterItem(name: "Jalousie links", ID: Shutters.BlindLeft.rawValue, isEnabled: true, outputUp: 100000203, outputDown: 100000204)
    return ShutterDetailView(shutterItem: item)
}
