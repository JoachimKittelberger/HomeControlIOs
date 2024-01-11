//
//  SettingsView.swift
//  WatchHomeControl Watch App
//
//  Created by Joachim Kittelberger on 27.12.23.
//  Copyright © 2023 Joachim Kittelberger. All rights reserved.
//

import SwiftUI



struct SettingsView: View {
    @Binding var selectedTab: Int

    @State private var ipAddress = "0.0.0.0"
    @State private var sendPort = 0
    @State private var receivePort = 0
    @State private var timeout = 0
    @State private var showAlert = false
 
    
    // formatter for number input
    let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .none
        return formatter
    }()
        
    var body: some View {
        //NavigationStack {
            Form {
                Section(header: Text("Haus-Steuerung"), content: {
                    HStack {
                        Image(systemName: "xserve")
                        Text("IP-Addresse")
                        TextField("Type here", text: $ipAddress)
                            .multilineTextAlignment(.trailing)
                            .keyboardType(.decimalPad)

                    }
                    HStack {
                        Image(systemName: "menubar.arrow.up.rectangle")
                        Text("Sendeport")
                        TextField("Type here", value: $sendPort, formatter: formatter)
                            .multilineTextAlignment(.trailing)
                            .keyboardType(.numberPad)
                    }
                    HStack {
                        Image(systemName: "menubar.arrow.down.rectangle")
                        Text("Empfangsport")
                        TextField("Type here", value: $receivePort, formatter: formatter)
                            .multilineTextAlignment(.trailing)
                            .keyboardType(.numberPad)
                    }
                    HStack {
                        Image(systemName: "stopwatch")
                        Text("Timeout")
                        TextField("Type here", value: $timeout, formatter: formatter)
                            .multilineTextAlignment(.trailing)
                            .keyboardType(.numberPad)
                    }
                })
                Section {
                    Button("Speichere Einstellungen") {
                        // implementation will be don in .onTapGesture because we use this modifier in form an
                        // will react in Button also on this modifier
                    }
                    .onTapGesture {
                        //print("onTapGesture Button")
                        let homeControlConnection = Jet32.sharedInstance
                        homeControlConnection.host = ipAddress
                        homeControlConnection.udpPortSend = UInt16(sendPort)
                        homeControlConnection.udpPortReceive = UInt16(receivePort)
                        homeControlConnection.timeoutJet32 = UInt16(timeout)
                        saveUserDefaults()
                        // make changes available in current connection (disconnect/reconnect)
                        homeControlConnection.disconnect()
                        homeControlConnection.connect()
                        showAlert = true
                        print("Saved Settings")
                    }
                    .alert("Einstellungen gespeichert!", isPresented: $showAlert) {
                        Button("OK") {
                            showAlert = false
                        }
                    }
                }
            }

            .navigationTitle("Einstellungen")
//                .navigationBarTitleDisplayMode(.inline)
            .navigationBarTitleDisplayMode(.large)

            // Problem, dass Button in Section dann nicht mehr erkannt wird
            // Button hat ebenfalls ein onTapGesture, das aufgerufen werden muss
            // Allerdings wird dann Form ebenfalls vor Button aufgerufen
            .onTapGesture {
                //print("onTapGesture Form")
                hideKeyboard()
            }

        //}

        .onChange(of: selectedTab) { oldTab, newTab in
            print("SettingsView.onChange: Change to tab \(selectedTab) Old: \(oldTab) New: \(newTab)")
            if (newTab == TabViews.SettingsViewTab.rawValue) {
                print("SettingsView Visible")

                // load the current settings from the Jet32 instance into local state vars
                let homeControlConnection = Jet32.sharedInstance
                ipAddress = homeControlConnection.host
                sendPort = Int(homeControlConnection.udpPortSend)
                receivePort = Int(homeControlConnection.udpPortReceive)
                timeout = Int(homeControlConnection.timeoutJet32)

            }
            if (oldTab == TabViews.SettingsViewTab.rawValue) {
                print("SettingsView Invisible")
            }
        }

    }
}




#Preview {
    return SettingsView(selectedTab: .constant(4))
}
