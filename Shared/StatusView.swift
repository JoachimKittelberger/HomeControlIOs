//
//  StatusView.swift
//  HomeControl
//
//  Created by Joachim Kittelberger on 09.01.24.
//  Copyright © 2024 Joachim Kittelberger. All rights reserved.
//

import SwiftUI



enum LightState: Int {
    case hellerkannt = 0,
         hell,
         dunkelerkannt,
         dunkel,
         unknown

    var description: String {
        switch self {
        case .hellerkannt:
            return "hell erkannt"
        case .hell:
            return "hell"
        case .dunkelerkannt:
            return "dunkel erkannt"
        case .dunkel:
            return "dunkel"
        case .unknown:
            return "unbekannt"
        default:
            return "reserved"
        }
    }
}


enum WindState: Int {
    case winderkannt = 0,
         zuvielwind,
         keinwinderkannt,
         keinwind,
         unknown

    var description: String {
        switch self {
        case .winderkannt:
            return "Wind erkannt"
        case .zuvielwind:
            return "zu viel Wind"
        case .keinwinderkannt:
            return "kein Wind erkannt"
        case .keinwind:
            return "kein Wind"
        case .unknown:
            return "unbekannt"
        default:
            return "reserved"
        }
    }
}


/*
protocol DescriptableEnum  {
      var description: String { get }
}
*/

//enum NightDayState: Int, DescriptableEnum {
enum NightDayState: Int {
    case day = 0,
         night,
         unknown
    
    var description: String {
        switch self {
        case .day:
            return "Tag"
        case .night:
            return "Nacht"
        case .unknown:
            return "unbekannt"
        default:
            return "reserved"
        }
    }
}





// Alle Steuerelemente deaktivieren und auf nil abprüfen. Wenn Variable kommt, dann setzen und damit freigeben

struct StatusView: View {

    @Binding var selectedTab: Int

    // states for light, wind and night
    @State private var lightState: LightState?
    @State private var windState: WindState?
    @State private var nightDayState: NightDayState?
    
    @State private var sunsetOffset: Int?
    @State private var sunsetDownHour: Int?
    @State private var sunsetDownMinute: Int?
    @State private var sunsetDownTime: String?      // Timestring sunset to display

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
                Section(header: Text("Aktuelle Zustände"), content: {
                    HStack {
                        Image(systemName:"xserve")
                        Text("Status Sonne")
                        Spacer()
                        Text(lightState != nil ? lightState!.description: "unbekannt")
                    }
                    .foregroundStyle(lightState != nil ? .primary : .tertiary)

                    HStack {
                        Image(systemName:"xserve")
                        Text("Status Wind")
                        Spacer()
                        Text(windState != nil ? windState!.description: "unbekannt")
                    }
                    .foregroundStyle(windState != nil ? .primary : .tertiary)

                    HStack {
                        Image(systemName:"xserve")
                        Text("Status Licht")
                        Spacer()
                        Text(nightDayState != nil ? nightDayState!.description: "unbekannt")
                    }
                    .foregroundStyle(nightDayState != nil ? .primary : .tertiary)

                })

                Section(header: Text("Sonnenuntergang"), content: {
                    HStack {
                        Image(systemName:"xserve")
                        Text("Offset SU (min)")
                        Spacer()
                        Text(sunsetOffset != nil ? "\(sunsetOffset!)" : "unbekannt")
                    }
                    .foregroundStyle(sunsetOffset != nil ? .primary : .tertiary)
                    HStack {
                        Image(systemName:"xserve")
                        Text("Rolläden ab (SU)")
                        Spacer()
                        Text(sunsetDownTime != nil ? "\(sunsetDownTime!)" : "00:00")
                    }
                    .foregroundStyle(sunsetDownTime != nil ? .primary : .tertiary)
                })
                
                Section(header: Text("Uhrzeit Steuerung"), content: {
                    HStack {
                        Image(systemName:"xserve")
                        Text("Aktuelle Zeit")
                        Spacer()
                        Text(currentTime != nil ? "\(currentTime!)" : "00:00:00")
                    }
                    .foregroundStyle(currentTime != nil ? .primary : .tertiary)
                })
            }
        }
        .navigationTitle("Status")
//        .navigationBarTitleDisplayMode(.inline)
        .navigationBarTitleDisplayMode(.large)

        
        .onReceive(timer) { _ in
            //print("StatusView.onReceive(timer)")
            // read values for current time continuously
            let _ = homeControlConnection.readIntRegister(UInt(Jet32GlobalVariables.regHour), tag: UInt(PLCViewControllerTag.readHour.rawValue))
            let _ = homeControlConnection.readIntRegister(UInt(Jet32GlobalVariables.regMinute), tag: UInt(PLCViewControllerTag.readMinute.rawValue))
            let _ = homeControlConnection.readIntRegister(UInt(Jet32GlobalVariables.regSecond), tag: UInt(PLCViewControllerTag.readSecond.rawValue))
        }

        .onChange(of: selectedTab) { oldTab, newTab in
            print("StatusView.onChange: Change to tab \(selectedTab) Old: \(oldTab) New: \(newTab)")
            if (newTab == TabViews.StatusViewTab.rawValue) {
                print("StatusView Visible")

                homeControlConnection.setDelegate(delegate: self)
                homeControlConnection.connect()
 
                // read values for Status states
                let _ = homeControlConnection.readIntRegister(UInt(Jet32GlobalVariables.regCurrentStateNightDay), tag: UInt(PLCViewControllerTag.readCurrentStateNightDay.rawValue))
                let _ = homeControlConnection.readIntRegister(UInt(Jet32GlobalVariables.regCurrentStateWind), tag: UInt(PLCViewControllerTag.readCurrentStateWind.rawValue))
                let _ = homeControlConnection.readIntRegister(UInt(Jet32GlobalVariables.regCurrentStateLight), tag: UInt(PLCViewControllerTag.readCurrentStateLight.rawValue))

                // read values for sunset
                let _ = homeControlConnection.readIntRegister(UInt(Jet32GlobalVariables.regSunsetHourForToday), tag: UInt(PLCViewControllerTag.readSunsetHourForToday.rawValue))
                let _ = homeControlConnection.readIntRegister(UInt(Jet32GlobalVariables.regSunsetMinuteForToday), tag: UInt(PLCViewControllerTag.readSunsetMinuteForToday.rawValue))
                let _ = homeControlConnection.readIntRegister(UInt(Jet32GlobalVariables.regSunsetOffsetInMin), tag: UInt(PLCViewControllerTag.readSunsetOffsetInMin.rawValue))

                // read values for current time
                let _ = homeControlConnection.readIntRegister(UInt(Jet32GlobalVariables.regHour), tag: UInt(PLCViewControllerTag.readHour.rawValue))
                let _ = homeControlConnection.readIntRegister(UInt(Jet32GlobalVariables.regMinute), tag: UInt(PLCViewControllerTag.readMinute.rawValue))
                let _ = homeControlConnection.readIntRegister(UInt(Jet32GlobalVariables.regSecond), tag: UInt(PLCViewControllerTag.readSecond.rawValue))
            
                // read current time every second
                timer = Timer.publish(every: 1, on: .main, in: .common)
                _ = self.timer.connect()
            }
            if (oldTab == TabViews.StatusViewTab.rawValue) {
                print("StatusView Invisible")

                timer.connect().cancel()
                //homeControlConnection.setDelegate(delegate: nil)
            }
        }
    }
}





extension StatusView: Jet32Delegate {
   

    func didReceiveReadRegister(value: UInt, tag: UInt) {
        if let plcTag = PLCViewControllerTag(rawValue: UInt32(tag)) {
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
                print("StatusView.didReceiveReadRegister: no implementation for \(plcTag)")
            case .readMinuteShutterUp:
                print("StatusView.didReceiveReadRegister: no implementation for \(plcTag)")
            case .readHourShutterDown:
                print("StatusView.didReceiveReadRegister: no implementation for \(plcTag)")
            case .readMinuteShutterDown:
                print("StatusView.didReceiveReadRegister: no implementation for \(plcTag)")
            case .readHourShutterUpWeekend:
                print("StatusView.didReceiveReadRegister: no implementation for \(plcTag)")
            case .readMinuteShutterUpWeekend:
                print("StatusView.didReceiveReadRegister: no implementation for \(plcTag)")

            case .readIsAutomaticBlind:
                print("StatusView.didReceiveReadRegister: no implementation for \(plcTag)")
            case .readIsAutomaticShutter:
                print("StatusView.didReceiveReadRegister: no implementation for \(plcTag)")
            case .readIsAutomaticSummerMode:
                print("StatusView.didReceiveReadRegister: no implementation for \(plcTag)")

            case .readIsSaunaOn:
                print("StatusView.didReceiveReadRegister: no implementation for \(plcTag)")

            case .readCurrentStateNightDay:
                nightDayState = NightDayState(rawValue: Int(value))
            case .readCurrentStateWind:
                windState = WindState(rawValue: Int(value))
            case .readCurrentStateLight:
                lightState = LightState(rawValue: Int(value))

            case .readUseSunsetSettings:
                print("StatusView.didReceiveReadRegister: no implementation for \(plcTag)")
            case .readSunsetHourForToday:
                sunsetDownHour = Int(value)
                setSunsetDownTimeString()
            case .readSunsetMinuteForToday:
                sunsetDownMinute = Int(value)
                setSunsetDownTimeString()
            case .readSunsetOffsetInMin:
                sunsetOffset = Int(value)
            default:
                print("Error: didReceiveReadRegister no case for tag \(tag)")
            }
            print("didReceiveReadRegister \(value) \(tag)")
        }
    }

    
    func didReceiveReadFlag(value: Bool, tag: UInt) {
        
        if let plcTag = PLCViewControllerTag(rawValue: UInt32(tag)) {
            
            switch (plcTag) {
                
            //case .readUseSunsetSettings:
                //useSunsetSettings.setOn(value, animated: false)

            default:
                print("Error: didReceiveReadFlag no case for tag \(tag)")
            }
            print("didReceiveReadFlag \(value) \(tag)")
        }
        
    }

    
    // helper functions
    // change currentTime var if all time vars are available
    func setCurrentTimeString() {
        if ((currentHour != nil) && (currentMinute != nil) && (currentSecond != nil)) {
            currentTime = String(format: "%02d:%02d:%02d", currentHour!, currentMinute!, currentSecond!)
        }
    }
    // change sunset down time var if all time vars are available
    func setSunsetDownTimeString() {
        if ((sunsetDownHour != nil) && (sunsetDownMinute != nil)) {
            sunsetDownTime = String(format: "%02d:%02d", sunsetDownHour!, sunsetDownMinute!)
        }
    }

    
    
}






extension StatusView: PlcDataAccessibleDelegate {
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
    return StatusView(selectedTab: .constant(3))
}
