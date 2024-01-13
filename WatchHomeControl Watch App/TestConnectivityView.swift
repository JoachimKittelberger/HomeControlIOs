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
    
    
    let homeControlConnection = PlcComMgr.sharedInstance
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
            }
        }
        .navigationTitle("TestConnectivity")
//        .navigationBarTitleDisplayMode(.inline)
        .navigationBarTitleDisplayMode(.large)
        
        
        .onReceive(timer) { _ in
            //print("StatusView.onReceive(timer)")
            // read values for current time continuously
            let _ = homeControlConnection.readIntRegister(UInt(Jet32GlobalVariables.regHour), tag: UInt(HomeControlControllerTag.readHour.rawValue))
            let _ = homeControlConnection.readIntRegister(UInt(Jet32GlobalVariables.regMinute), tag: UInt(HomeControlControllerTag.readMinute.rawValue))
            let _ = homeControlConnection.readIntRegister(UInt(Jet32GlobalVariables.regSecond), tag: UInt(HomeControlControllerTag.readSecond.rawValue))
        }
        
        .onChange(of: selectedTab) { oldTab, newTab in
            print("TestConnectivityView.onChange: Change to tab \(selectedTab) Old: \(oldTab) New: \(newTab)")
            if (newTab == TabViews.TestConnectivityView.rawValue) {
                print("TestConnectivityView Visible")
                
                homeControlConnection.setDelegate(delegate: self)
                homeControlConnection.connect()
                
                // read values for current time
                let _ = homeControlConnection.readIntRegister(UInt(Jet32GlobalVariables.regHour), tag: UInt(HomeControlControllerTag.readHour.rawValue))
                let _ = homeControlConnection.readIntRegister(UInt(Jet32GlobalVariables.regMinute), tag: UInt(HomeControlControllerTag.readMinute.rawValue))
                let _ = homeControlConnection.readIntRegister(UInt(Jet32GlobalVariables.regSecond), tag: UInt(HomeControlControllerTag.readSecond.rawValue))
                
                // read current time every second
                timer = Timer.publish(every: 1, on: .main, in: .common)
                _ = self.timer.connect()
            }
            if (oldTab == TabViews.TestConnectivityView.rawValue) {
                print("TestConnectivityView Invisible")
                
                timer.connect().cancel()
                //homeControlConnection.setDelegate(delegate: nil)
            }
        }
    }
}
    





extension TestConnectivityView: Jet32Delegate {
    
    
    func didReceiveReadRegister(value: UInt, tag: UInt) {
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
                print("TestConnectivityView.didReceiveReadRegister: no implementation for \(plcTag)")
            case .readMinuteShutterUp:
                print("TestConnectivityView.didReceiveReadRegister: no implementation for \(plcTag)")
            case .readHourShutterDown:
                print("TestConnectivityView.didReceiveReadRegister: no implementation for \(plcTag)")
            case .readMinuteShutterDown:
                print("TestConnectivityView.didReceiveReadRegister: no implementation for \(plcTag)")
            case .readHourShutterUpWeekend:
                print("TestConnectivityView.didReceiveReadRegister: no implementation for \(plcTag)")
            case .readMinuteShutterUpWeekend:
                print("TestConnectivityView.didReceiveReadRegister: no implementation for \(plcTag)")
                
            case .readCurrentStateNightDay:
                print("TestConnectivityView.didReceiveReadRegister: no implementation for \(plcTag)")
            case .readCurrentStateWind:
                print("TestConnectivityView.didReceiveReadRegister: no implementation for \(plcTag)")
            case .readCurrentStateLight:
                print("TestConnectivityView.didReceiveReadRegister: no implementation for \(plcTag)")
                
            case .readSunsetHourForToday:
                print("TestConnectivityView.didReceiveReadRegister: no implementation for \(plcTag)")
            case .readSunsetMinuteForToday:
                print("TestConnectivityView.didReceiveReadRegister: no implementation for \(plcTag)")
            case .readSunsetOffsetInMin:
                print("TestConnectivityView.didReceiveReadRegister: no implementation for \(plcTag)")
                
            default:
                print("Error: TestConnectivityView.didReceiveReadRegister no case for tag \(tag)")
            }
            //print("didReceiveReadRegister \(value) \(tag)")
        }
    }
    
    
    func didReceiveReadFlag(value: Bool, tag: UInt) {
        
        if let plcTag = HomeControlControllerTag(rawValue: UInt32(tag)) {
            
            switch (plcTag) {
            case .readIsAutomaticBlind:
                print("TestConnectivityView.didReceiveReadFlag: no implementation for \(plcTag)")
            case .readIsAutomaticShutter:
                print("TestConnectivityView.didReceiveReadFlag: no implementation for \(plcTag)")
            case .readIsAutomaticSummerMode:
                print("TestConnectivityView.didReceiveReadFlag: no implementation for \(plcTag)")
                
            case .readIsSaunaOn:
                print("TestConnectivityView.didReceiveReadFlag: no implementation for \(plcTag)")
                
            case .readUseSunsetSettings:
                print("TestConnectivityView.didReceiveReadFlag: no implementation for \(plcTag)")
                
            default:
                print("Error: TestConnectivityView.didReceiveReadFlag no case for tag \(tag)")
            }
            //print("StatusView.didReceiveReadFlag \(value) \(tag)")
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






extension TestConnectivityView: PlcDataAccessibleDelegate {
    func didRedeiveReadIntRegister(_ number: UInt, with value: Int, tag: UInt) {
        print("didRedeiveReadIntRegister(tag: \(tag)): \(number): \(value)")
        
        didReceiveReadRegister(value: UInt(value), tag: tag)
    }
    
    func didRedeiveWriteIntRegister(_ number: UInt, tag: UInt) {
        print("\(#file) " + String(describing: type(of: self)) + ".\(#function)[\(#line)]: called")
    }
    
    func didRedeiveReadFlag(_ number: UInt, with value: Bool, tag: UInt) {
        print("didReceiveReadFlag(tag: \(tag)): \(number): \(value)")
        
        didReceiveReadFlag(value: value, tag: tag)
    }
    
    func didRedeiveSetFlag(_ number: UInt, tag: UInt) {
        print("\(#file) " + String(describing: type(of: self)) + ".\(#function)[\(#line)]: called")
    }
    func didRedeiveClearFlag(_ number: UInt, tag: UInt) {
        print("\(#file) " + String(describing: type(of: self)) + ".\(#function)[\(#line)]: called")
    }
    
    func didRedeiveReadOutput(_ number: UInt, with value: Bool, tag: UInt) {
        print("\(#file) " + String(describing: type(of: self)) + ".\(#function)[\(#line)]: called")
    }
    func didRedeiveSetOutput(_ number: UInt, tag: UInt) {
        print("\(#file) " + String(describing: type(of: self)) + ".\(#function)[\(#line)]: called")
    }
    func didRedeiveClearOutput(_ number: UInt, tag: UInt) {
        print("\(#file) " + String(describing: type(of: self)) + ".\(#function)[\(#line)]: called")
    }

}






#Preview {
    return TestConnectivityView(selectedTab: .constant(TabViews.TestConnectivityView.rawValue))
}


