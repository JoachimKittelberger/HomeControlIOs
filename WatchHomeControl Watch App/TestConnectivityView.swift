//
//  TestConnectivityView.swift
//  WatchHomeControl Watch App
//
//  Created by Joachim Kittelberger on 13.01.24.
//  Copyright © 2024 Joachim Kittelberger. All rights reserved.
//

import SwiftUI

struct TestConnectivityView: View {
    
    @Binding var selectedTab: Int
    
    
    // states for light, wind and night
    @State private var currentHour: Int?
    @State private var currentMinute: Int?
    @State private var currentSecond: Int?
    
    @State private var currentTime: String?         // Timestring to display
    
    
    @State private var isAutomaticSummerMode: Bool?

    
    
    let homeControlConnection = PLCComMgr.shared
    // read current time continuously
    @State private var timer = Timer.publish(every: 1, on: .main, in: .common)
    
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Uhrzeit Steuerung"), content: {
                    HStack {
                        Image(systemName: "clock")
                        Text("Aktuelle Zeit")
                        Spacer()
                        Text(currentTime != nil ? "\(currentTime!)" : "00:00:00")
                    }
                    .foregroundStyle(currentTime != nil ? .primary : .tertiary)
                })
                HStack {
                    Spacer()
                    Button(action: {
                        // if used global .onTapGesture
                        // implementation will be don in .onTapGesture because we use this modifier in form an
                        // will react in Button also on this modifier
                        homeControlConnection.setDelegate(delegate: self)
                        homeControlConnection.connect()
                        
                        // read values for current time
                        let _ = homeControlConnection.readIntRegister(UInt(Jet32GlobalVariables.regSecond), tag: UInt(HomeControlControllerTag.readSecond.rawValue))
                        let _ = homeControlConnection.readIntRegister(UInt(Jet32GlobalVariables.regMinute), tag: UInt(HomeControlControllerTag.readMinute.rawValue))
                        let _ = homeControlConnection.readIntRegister(UInt(Jet32GlobalVariables.regHour), tag: UInt(HomeControlControllerTag.readHour.rawValue))
                    }) {
                        HStack {
                            //Image(systemName: "sunset.fill")
                            Text("Teste ReadIntRegiser \(currentSecond ?? 0)")
                        }
                    }
//                    .disabled(currentTime != nil ? (false) : (true))        // enable only if connected
                    Spacer()
                }
                HStack {
                    Spacer()
                    Button(action: {
                        // if used global .onTapGesture
                        // implementation will be don in .onTapGesture because we use this modifier in form an
                        // will react in Button also on this modifier
                        homeControlConnection.setDelegate(delegate: self)
                        homeControlConnection.connect()
                        
                        let sunsetOffset = 31
                        // write values for sunset offset
                        let _ = homeControlConnection.writeIntRegister(UInt(Jet32GlobalVariables.regSunsetOffsetInMin), to: sunsetOffset, tag: 0)
                    }) {
                        HStack {
                            //Image(systemName: "sunset.fill")
                            Text("Write Register ")
                        }
                    }
//                    .disabled(currentTime != nil ? (false) : (true))        // enable only if connected
                    Spacer()
                }
                HStack {
                    Spacer()
                    Button(action: {
                        // if used global .onTapGesture
                        // implementation will be don in .onTapGesture because we use this modifier in form an
                        // will react in Button also on this modifier
                        homeControlConnection.setDelegate(delegate: self)
                        homeControlConnection.connect()
                        
                        // read values for automatic summer mode
                        let _ = homeControlConnection.readFlag(UInt(Jet32GlobalVariables.flagIsAutomaticSummerMode), tag: UInt(HomeControlControllerTag.readIsAutomaticSummerMode.rawValue))
                    }) {
                        HStack {
                            //Image(systemName: "sunset.fill")
                            Text("Teste ReadFlag \(isAutomaticSummerMode.map { String($0) } ?? "nil")")
                        }
                    }
//                    .disabled(currentTime != nil ? (false) : (true))        // enable only if connected
                    Spacer()
                }
                HStack {
                    Image(systemName: "sun.max")
                    Toggle("Rolladen auf Sommerposition", isOn: $isAutomaticSummerMode ?? false)      // Use Binding operator overload
                        .onChange(of: isAutomaticSummerMode) {
                            //print("Action: isAutomaticSummerMode \(isAutomaticSummerMode)")            // we get an optional here
                        }
                        .onChange(of: isAutomaticSummerMode) { oldValue, newValue in
                            //print("isAutomaticSummerMode old: \(oldValue) new: \(newValue)")            // we get an optional here
                            if let isOn = newValue {
                                if (isOn == true){
                                    let _ = homeControlConnection.setFlag(UInt(Jet32GlobalVariables.flagIsAutomaticSummerMode), tag: 0)       // Offset for Flags up
                                } else {
                                    let _ = homeControlConnection.clearFlag(UInt(Jet32GlobalVariables.flagIsAutomaticSummerMode), tag: 0)       // Offset for Flags up
                                }
                            }
                        }
                        .disabled(isAutomaticSummerMode != nil ? (false) : (true))
                }
                .foregroundStyle(isAutomaticSummerMode != nil ? .primary : .tertiary)

            }
        }
        .navigationTitle("TestConnectivity")
//        .navigationBarTitleDisplayMode(.inline)
        .navigationBarTitleDisplayMode(.large)
        
        
        .onReceive(timer) { _ in
            //print("StatusView.onReceive(timer)")
            // read values for current time continuously
/*
            let _ = homeControlConnection.readIntRegister(UInt(Jet32GlobalVariables.regHour), tag: UInt(HomeControlControllerTag.readHour.rawValue))
            let _ = homeControlConnection.readIntRegister(UInt(Jet32GlobalVariables.regMinute), tag: UInt(HomeControlControllerTag.readMinute.rawValue))
            let _ = homeControlConnection.readIntRegister(UInt(Jet32GlobalVariables.regSecond), tag: UInt(HomeControlControllerTag.readSecond.rawValue))
*/
        }
        
        .onChange(of: selectedTab) { oldTab, newTab in
            print(String(describing: type(of: self)) + ".\(#function): Change to tab \(selectedTab) Old: \(oldTab) New: \(newTab)")
            if (newTab == TabViews.TestConnectivityView.rawValue) {
                print("TestConnectivityView Visible")
/*
                homeControlConnection.setDelegate(delegate: self)
                homeControlConnection.connect()
                
                // read values for current time
                let _ = homeControlConnection.readIntRegister(UInt(Jet32GlobalVariables.regHour), tag: UInt(HomeControlControllerTag.readHour.rawValue))
                let _ = homeControlConnection.readIntRegister(UInt(Jet32GlobalVariables.regMinute), tag: UInt(HomeControlControllerTag.readMinute.rawValue))
                let _ = homeControlConnection.readIntRegister(UInt(Jet32GlobalVariables.regSecond), tag: UInt(HomeControlControllerTag.readSecond.rawValue))
                
                // read current time every second
                timer = Timer.publish(every: 1, on: .main, in: .common)
                _ = self.timer.connect()
*/
            }
            if (oldTab == TabViews.TestConnectivityView.rawValue) {
                print("TestConnectivityView Invisible")
                
                timer.connect().cancel()
                //homeControlConnection.setDelegate(delegate: nil)
            }
        }
    }
    
    
    // helper functions
    // change currentTime var if all time vars are available
    func setCurrentTimeString() {
        if ((currentHour != nil) && (currentMinute != nil) && (currentSecond != nil)) {
            currentTime = String(format: "%02d:%02d:%02d", currentHour!, currentMinute!, currentSecond!)
        }
    }

    
    
}
    




extension TestConnectivityView: PLCDataAccessibleDelegate {
    func didReceiveReadIntRegister(_ number: UInt, with value: Int, tag: UInt) {
        print(String(describing: type(of: self)) + ".\(#function)(tag: \(tag)): \(number): \(value)")
        //print("TestConnectivityView.didReceiveReadIntRegister(tag: \(tag)): \(number): \(value)")
        DispatchQueue.global().async {
            
            if let plcTag = HomeControlControllerTag(rawValue: UInt32(tag)) {
                switch (plcTag) {
                    
                case .readSecond:
                    currentSecond = Int(value)
                    setCurrentTimeString()
                case .readMinute:
                    currentMinute = Int(value)
                    setCurrentTimeString()
                case .readHour:
                    currentHour = Int(value)
                    setCurrentTimeString()
                    
                case .readHourShutterUp:
                    fallthrough
                case .readMinuteShutterUp:
                    fallthrough
                case .readHourShutterDown:
                    fallthrough
                case .readMinuteShutterDown:
                    fallthrough
                case .readHourShutterUpWeekend:
                    fallthrough
                case .readMinuteShutterUpWeekend:
                    fallthrough

                case .readCurrentStateNightDay:
                    fallthrough
                case .readCurrentStateWind:
                    fallthrough
                case .readCurrentStateLight:
                    fallthrough

                case .readSunsetHourForToday:
                    fallthrough
                case .readSunsetMinuteForToday:
                    fallthrough
                case .readSunsetOffsetInMin:
                    print("TestConnectivityView.didReceiveReadIntRegister: no implementation for \(plcTag)")
                    
                default:
                    print("Error: TestConnectivityView.didReceiveReadIntRegister no case for tag \(tag)")
                }
                //print("didReceiveReadRegister \(value) \(tag)")
            }
        }
    }
/*
    func didReceiveWriteIntRegister(_ number: UInt, tag: UInt) {
        print(String(describing: type(of: self)) + ".\(#function)[\(#line)]: called")
    }
  */
    func didReceiveReadFlag(_ number: UInt, with value: Bool, tag: UInt) {
        print(String(describing: type(of: self)) + ".\(#function)(tag: \(tag)): \(number): \(value)")
        
        DispatchQueue.global().async {
            if let plcTag = HomeControlControllerTag(rawValue: UInt32(tag)) {
                
                switch (plcTag) {
                case .readIsAutomaticBlind:
                    fallthrough
                case .readIsAutomaticShutter:
                    print("TestConnectivityView.didReceiveReadFlag: no implementation for \(plcTag)")

                case .readIsAutomaticSummerMode:
                    isAutomaticSummerMode = value

                case .readIsSaunaOn:
                    fallthrough

                case .readUseSunsetSettings:
                    print("TestConnectivityView.didReceiveReadFlag: no implementation for \(plcTag)")
                    
                default:
                    print("Error: TestConnectivityView.didReceiveReadFlag no case for tag \(tag)")
                }
                //print("StatusView.didReceiveReadFlag \(value) \(tag)")
            }
        }
    }
    /*
    func didReceiveSetFlag(_ number: UInt, tag: UInt) {
        print(String(describing: type(of: self)) + ".\(#function)[\(#line)]: called")
    }
    func didReceiveClearFlag(_ number: UInt, tag: UInt) {
        print(String(describing: type(of: self)) + ".\(#function)[\(#line)]: called")
    }
    
    func didReceiveReadOutput(_ number: UInt, with value: Bool, tag: UInt) {
        print(String(describing: type(of: self)) + ".\(#function)[\(#line)]: called")
    }
    func didReceiveSetOutput(_ number: UInt, tag: UInt) {
        print(String(describing: type(of: self)) + ".\(#function)[\(#line)]: called")
    }
    func didReceiveClearOutput(_ number: UInt, tag: UInt) {
        print(String(describing: type(of: self)) + ".\(#function)[\(#line)]: called")
    }
*/
}






#Preview {
    return TestConnectivityView(selectedTab: .constant(TabViews.TestConnectivityView.rawValue))
}


