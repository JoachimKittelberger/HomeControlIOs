//
//  ShutterDetailView.swift
//  WatchHomeControl Watch App
//
//  Created by Joachim Kittelberger on 27.12.23.
//  Copyright © 2023 Joachim Kittelberger. All rights reserved.
//

import SwiftUI

//import WatchConnectivity

struct ShutterDetailView: View {
    let shutterItem: ShutterItem


    // TODO: Test Connectivity
    //let connectivity = Connectivity.sharedInstance
    let homeControlConnection = PlcComMgr.sharedInstance

    
    var body: some View {
        VStack {
            #if os(watchOS)
                Spacer()      // nur für WatchOS
            #endif
            Text(shutterItem.name)
                .font(.title3)
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

                    homeControlConnection.setDelegate(delegate: nil)
                    homeControlConnection.connect()
                    let _ = homeControlConnection.setFlag(offsetFlagUp + UInt(shutterItem.ID), tag: 0)       // Offset for Flags up
                    //let _ = homeControlConnection.setFlag(offsetFlagDown + UInt(shutterItem.ID), tag: 0)       // Offset for Flags down
                    //homeControlConnection.setDelegate(delegate: nil)

                    
 /*
                    // TODO: Test sending Message
            #if os(iOS)
                    let message = ["Message": "Hello from iPhone"]
                    //connectivity.send(message: message, replyHandler: nil, errorHandler: nil)
                    connectivity.send(message: message,
                        replyHandler: nil,
                        errorHandler: { error in
                            print("Error sending message:", error)
                        }
                    )
        #endif
            #if os(watchOS)
                    let message = ["Message": "Hello from Watch"]
                    //connectivity.send(message: message, replyHandler: nil, errorHandler: nil)
                    connectivity.send(message: message, 
                        replyHandler: { response in
                            print("Received response", response)
                        },
                        errorHandler: { error in
                            print("Error sending message:", error)
                        }
                    )
            #endif
   */
                    
                } label: {
                    Text("Auf")
                    #if os(iOS)
                        //.padding(.horizontal, 20)
                        .padding(.vertical, 16)
                        .frame(width: 120)
                        .foregroundColor(.white)
                        .background(.gray)
                        .cornerRadius(16)
                        .font(.title2)
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
                    
                    homeControlConnection.setDelegate(delegate: nil)
                    homeControlConnection.connect()
                    //let _ = homeControlConnection.setFlag(offsetFlagUp + UInt(shutterItem.ID), tag: 0)       // Offset for Flags up
                    let _ = homeControlConnection.setFlag(offsetFlagDown + UInt(shutterItem.ID), tag: 0)       // Offset for Flags down
                    //homeControlConnection.setDelegate(delegate: nil)

                } label: {
                    Text("Ab")
                    #if os(iOS)
                        //.padding(.horizontal, 20)
                        .padding(.vertical, 16)
                        .frame(width: 120)
                        .foregroundColor(.white)
                        .background(.gray)
                        .cornerRadius(16)
                        .font(.title2)
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
