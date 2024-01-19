//
//  PLCView.swift
//  WatchHomeControl Watch App
//
//  Created by Joachim Kittelberger on 27.12.23.
//  Copyright © 2023 Joachim Kittelberger. All rights reserved.
//

import Combine
import SwiftUI



struct PLCView: View {
    @Binding var selectedTab: Int

    // State vars for settings
    // Realtime clock
    @State private var currentHour: Int?
    @State private var currentMinute: Int?
    @State private var currentSecond: Int?
    @State private var currentTime: String?         // Timestring to display
 
    // Time up/down for shutters
    @State private var upTimeHourWeekday: Int?
    @State private var upTimeMinuteWeekday: Int?
    @State private var downTimeHourWeekday: Int?
    @State private var downTimeMinuteWeekday: Int?
    @State private var upTimeHourWeekend: Int?
    @State private var upTimeMinuteWeekend: Int?
    
    // hier mit Date/Time variablen arbeiten.
    // evtl. mit anderem Zeitpunkt initialisierren
    @State private var upTimeWeekDay = Date()
    @State private var downTimeWeekDay = Date()
    @State private var upTimeWeekend = Date()

    
    // Automatic settings
    @State private var isAutomaticShutter: Bool?
    @State private var isAutomaticSummerMode: Bool?
    @State private var useSunsetSettings: Bool?
    @State private var sunsetOffset: Int?
    @State private var isAutomaticBlind: Bool?
    @State private var isSaunaOn: Bool?
    
    
    let homeControlConnection = PLCComMgr.shared
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
                    
                    HStack {
                        Spacer()
                        Button(action: {
                            // implementation will be don in .onTapGesture because we use this modifier in form an
                            // will react in Button also on this modifier
                        }) {
                            HStack {
                                Image(systemName: "clock.badge.checkmark")
                                Text("Setze Uhrzeit in Steuerung")
                            }
                        }
                        .onTapGesture {
                            print("onTapGesture Button")
                            writeCurrentTimeToPLC()
                            
                        }
                        .disabled(currentTime != nil ? (false) : (true))
                        Spacer()
                    }
                })
 
                Section(header: Text("Wochentag"), content: {
                    HStack {
                        Image(systemName: "window.shade.open")
#if os(watchOS)
                        Text("auf")
#else
                        Text("Rolladen auf")
#endif
                        Spacer()
                        DatePicker("Rolladen auf", selection: $upTimeWeekDay, displayedComponents: .hourAndMinute)
                        //.datePickerStyle(GraphicalDatePickerStyle())      // available just in iOS
                        //.clipped()
                        //.transformEffect(.init(scaleX: 0.7, y: 0.7))
                        //.frame(width: 110, alignment: .trailing)
#if os(watchOS)
                            .padding(.leading)
#endif
                            .labelsHidden()
                            .onChange(of: upTimeWeekDay, {
                                //print("Changed Date to upTimeWeekDay: \(upTimeWeekDay)")
                                let calendar = Calendar.current
                                upTimeHourWeekday = calendar.component(.hour, from: upTimeWeekDay)
                                upTimeMinuteWeekday = calendar.component(.minute, from: upTimeWeekDay)
                                //print("new Time upTimeHourWeekday: \(upTimeHourWeekday!):\(upTimeMinuteWeekday!)")
                                
                                // write the new values to the plc if we have read just one time from plc
                                if ((upTimeHourWeekday != nil) && (upTimeMinuteWeekday != nil)) {
                                    let _ = homeControlConnection.writeIntRegister(UInt(Jet32GlobalVariables.regUpTimeHour), to: upTimeHourWeekday!, tag: 0)
                                    let _ = homeControlConnection.writeIntRegister(UInt(Jet32GlobalVariables.regUpTimeMinute), to: upTimeMinuteWeekday!, tag: 0)
                                }
                            })
                            .disabled(((upTimeHourWeekday != nil) && (upTimeMinuteWeekday != nil)) ? (false) : (true))
                        #if os(iOS)
                            .colorMultiply(((upTimeHourWeekday != nil) && (upTimeMinuteWeekday != nil)) ? Color(.label) : Color(.placeholderText))
                        #endif
                    }
                    .foregroundStyle(((upTimeHourWeekday != nil) && (upTimeMinuteWeekday != nil)) ? .primary : .tertiary)

                    HStack {
                        Image(systemName: "window.shade.closed")
#if os(watchOS)
                        Text("ab")
#else
                        Text("Rolladen ab")
#endif
                        Spacer()
                        DatePicker("Rolladen ab", selection: $downTimeWeekDay, displayedComponents: .hourAndMinute)
#if os(watchOS)
                            .padding(.leading)
#endif
                            .labelsHidden()
                            .onChange(of: downTimeWeekDay, {
                                //print("Changed Date to downTimeWeekDay: \(downTimeWeekDay)")
                                let calendar = Calendar.current
                                downTimeHourWeekday = calendar.component(.hour, from: downTimeWeekDay)
                                downTimeMinuteWeekday = calendar.component(.minute, from: downTimeWeekDay)
                                //print("new Time downTimeHourWeekday: \(downTimeHourWeekday!):\(downTimeMinuteWeekday!)")
                                
                                // write the new values to the plc if we have read just one time from plc
                                if ((downTimeHourWeekday != nil) && (downTimeMinuteWeekday != nil)) {
                                    let _ = homeControlConnection.writeIntRegister(UInt(Jet32GlobalVariables.regDownTimeHour), to: downTimeHourWeekday!, tag: 0)
                                    let _ = homeControlConnection.writeIntRegister(UInt(Jet32GlobalVariables.regDownTimeMinute), to: downTimeMinuteWeekday!, tag: 0)
                                }
                            })
                            .disabled(((downTimeHourWeekday != nil) && (downTimeMinuteWeekday != nil)) ? (false) : (true))
                        #if os(iOS)
                            .colorMultiply(((downTimeHourWeekday != nil) && (downTimeMinuteWeekday != nil)) ? Color(.label) : Color(.placeholderText))
                        #endif
                    }
                    .foregroundStyle(((downTimeHourWeekday != nil) && (downTimeMinuteWeekday != nil)) ? .primary : .tertiary)
                })
  
                Section(header: Text("Wochenende"), content: {
                    HStack {
                        Image(systemName: "window.shade.open")
#if os(watchOS)
                        Text("auf")
#else
                        Text("Rolladen auf")
#endif
                        Spacer()
                        DatePicker("Rolladen auf", selection: $upTimeWeekend, displayedComponents: .hourAndMinute)
#if os(watchOS)
                            .padding(.leading)
#endif
                            .labelsHidden()
                            .onChange(of: upTimeWeekend, {
                                //print("Changed Date to upTimeWeekend: \(upTimeWeekend)")
                                let calendar = Calendar.current
                                upTimeHourWeekend = calendar.component(.hour, from: upTimeWeekend)
                                upTimeMinuteWeekend = calendar.component(.minute, from: upTimeWeekend)
                                //print("new Time upTimeWeekend: \(upTimeHourWeekend!):\(upTimeMinuteWeekend!)")
                                
                                // write the new values to the plc if we have read just one time from plc
                                if ((upTimeHourWeekend != nil) && (upTimeMinuteWeekend != nil)) {
                                    let _ = homeControlConnection.writeIntRegister(UInt(Jet32GlobalVariables.regUpTimeHourWeekend), to: upTimeHourWeekend!, tag: 0)
                                    let _ = homeControlConnection.writeIntRegister(UInt(Jet32GlobalVariables.regUpTimeMinuteWeekend), to: upTimeMinuteWeekend!, tag: 0)
                                }
                            })
                            .disabled(((upTimeHourWeekend != nil) && (upTimeMinuteWeekend != nil)) ? (false) : (true))
                        #if os(iOS)
                            .colorMultiply(((upTimeHourWeekend != nil) && (upTimeMinuteWeekend != nil)) ? Color(.label) : Color(.placeholderText))
                        #endif
                    }
                    .foregroundStyle(((upTimeHourWeekend != nil) && (upTimeMinuteWeekend != nil)) ? .primary : .tertiary)
                })
 
                Section(header: Text("Automatik"), content: {
                    HStack {
                        Image(systemName: "window.shade.open")
                        Toggle("Rolladenautomatik", isOn: $isAutomaticShutter ?? false)     // Use Binding operator overload
                            .onChange(of: isAutomaticShutter) {
                                //print("Action: Rolladenautomatik \(isAutomaticShutter)")            // we get an optional here
                            }
                            .onChange(of: isAutomaticShutter) { oldValue, newValue in
                                //print("Rolladenautomatik old: \(oldValue) new: \(newValue)")            // we get an optional here
                                if let isOn = newValue {
                                    if (isOn == true){
                                        let _ = homeControlConnection.setFlag(UInt(Jet32GlobalVariables.flagIsAutomaticShutter), tag: 0)       // Offset for Flags up
                                    } else {
                                        let _ = homeControlConnection.clearFlag(UInt(Jet32GlobalVariables.flagIsAutomaticShutter), tag: 0)       // Offset for Flags up
                                    }
                                }
                            }
                            .disabled(isAutomaticShutter != nil ? (false) : (true))
                    }
                    .foregroundStyle(isAutomaticShutter != nil ? .primary : .tertiary)
 
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

                    HStack {
                        Image(systemName: "sunset")
                        Toggle("Sonnenuntergangsautomatik", isOn: $useSunsetSettings ?? false)      // Use Binding operator overload
                            .onChange(of: useSunsetSettings) {
                                //print("Action: useSunsetSettings \(useSunsetSettings)")            // we get an optional here
                            }
                            .onChange(of: useSunsetSettings) { oldValue, newValue in
                                //print("useSunsetSettings old: \(oldValue) new: \(newValue)")            // we get an optional here
                                if let isOn = newValue {
                                    if (isOn == true){
                                        let _ = homeControlConnection.setFlag(UInt(Jet32GlobalVariables.flagUseSunsetSettings), tag: 0)       // Offset for Flags up
                                    } else {
                                        let _ = homeControlConnection.clearFlag(UInt(Jet32GlobalVariables.flagUseSunsetSettings), tag: 0)       // Offset for Flags up
                                    }
                                }
                            }
                            .disabled(useSunsetSettings != nil ? (false) : (true))
                    }
                    .foregroundStyle(useSunsetSettings != nil ? .primary : .tertiary)

                    HStack {
                        Image(systemName: "timer")
                        Text(sunsetOffset != nil ? "\(sunsetOffset!) min bis Rolladen ab" : "XX min bis Rolladen ab")
                        Spacer()
                        Stepper("", onIncrement: {
                                sunsetOffset! += 1
                                let _ = homeControlConnection.writeIntRegister(UInt(Jet32GlobalVariables.regSunsetOffsetInMin), to: sunsetOffset!, tag: 0)
                            }, onDecrement: {
                                sunsetOffset! -= 1
                                let _ = homeControlConnection.writeIntRegister(UInt(Jet32GlobalVariables.regSunsetOffsetInMin), to: sunsetOffset!, tag: 0)
                            })
                            .disabled(sunsetOffset != nil ? (false) : (true))
                        //.transformEffect(.init(scaleX: 0.8, y: 0.8))
                        //Stepper("Offset SU: \(sunsetOffset) min", value: $offsetMinutesTest, in: -60...60, step: 1)
                        //Text("Offset SU (min)")
                        //Spacer()
                        //Text(sunsetOffset != nil ? "\(sunsetOffset!)" : "unbekannt")
                    }
                    .padding(.leading)
                    .foregroundStyle(sunsetOffset != nil ? .primary : .tertiary)
      
                    HStack {
                        Image(systemName: "blinds.horizontal.open")
                        //Text("Jalousienautomatik")
                        //Spacer()
                        Toggle("Jalousienautomatik", isOn: $isAutomaticBlind ?? false)      // Use Binding operator overload
                            //.labelsHidden()
                            .onChange(of: isAutomaticBlind) {
                                //print("Action: isAutomaticBlind \(isAutomaticBlind)")            // we get an optional here
                            }
                            .onChange(of: isAutomaticBlind) { oldValue, newValue in
                                //print("isAutomaticBlind old: \(oldValue) new: \(newValue)")            // we get an optional here
                                if let isOn = newValue {
                                    if (isOn == true){
                                        let _ = homeControlConnection.setFlag(UInt(Jet32GlobalVariables.flagIsAutomaticBlind), tag: 0)       // Offset for Flags up
                                    } else {
                                        let _ = homeControlConnection.clearFlag(UInt(Jet32GlobalVariables.flagIsAutomaticBlind), tag: 0)       // Offset for Flags up
                                    }
                                }
                            }
                            .disabled(isAutomaticBlind != nil ? (false) : (true))
                    }
                    .foregroundStyle(isAutomaticBlind != nil ? .primary : .tertiary)

                    HStack {
                        Image(systemName: "heater.vertical")
                        Toggle("Sauna einschalten", isOn: $isSaunaOn ?? false)              // Use Binding operator overload
                            .onChange(of: isSaunaOn) {
                                //print("Action: isSaunaOn \(isSaunaOn)")            // we get an optional here
                            }
                            .onChange(of: isSaunaOn) { oldValue, newValue in
                                //print("isSaunaOn old: \(oldValue) new: \(newValue)")            // we get an optional here
                                if let isOn = newValue {
                                    if (isOn == true){
                                        let _ = homeControlConnection.setFlag(UInt(Jet32GlobalVariables.flagIsSaunaOn), tag: 0)       // Offset for Flags up
                                    } else {
                                        let _ = homeControlConnection.clearFlag(UInt(Jet32GlobalVariables.flagIsSaunaOn), tag: 0)       // Offset for Flags up
                                    }
                                }
                            }
                            .disabled(isSaunaOn != nil ? (false) : (true))
                    }
                    .foregroundStyle(isSaunaOn != nil ? .primary : .tertiary)
                })
         

                
                Section(header: Text("Manuell"), content: {
                    HStack {
                        Spacer()
                        Button(action: {
                            // if used global .onTapGesture
                            // implementation will be don in .onTapGesture because we use this modifier in form an
                            // will react in Button also on this modifier
                            print("Button: Alle Rolläden auf wurde gedrückt")
                            let _ = homeControlConnection.setFlag(UInt(Jet32GlobalVariables.flagCmdAllAutomaticShuttersUp), tag: 0)       // Offset for Flags up
                       }) {
                            HStack {
                                Image(systemName: "window.shade.open")
                                Text("Alle Rolladen auf")
                            }
                        }
                        .disabled(currentTime != nil ? (false) : (true))        // enable only if connected
                        Spacer()
                    }
                    //.foregroundStyle(currentTime != nil ? .primary : .tertiary)
                    
                    HStack {
                        Spacer()
                        Button(action: {
                            // if used global .onTapGesture
                            // implementation will be don in .onTapGesture because we use this modifier in form an
                            // will react in Button also on this modifier
                            let _ = homeControlConnection.setFlag(UInt(Jet32GlobalVariables.flagCmdAllAutomaticShuttersDown), tag: 0)       // Offset for Flags up
                        }) {
                            HStack {
                                Image(systemName: "window.shade.closed")
                                Text("Alle Rolladen ab")
                            }
                        }
                        .disabled(currentTime != nil ? (false) : (true))        // enable only if connected
                        Spacer()
                    }
                    //.foregroundStyle(currentTime != nil ? .primary : .tertiary)
                    
                    HStack {
                        Spacer()
                        Button(action: {
                            // if used global .onTapGesture
                            // implementation will be don in .onTapGesture because we use this modifier in form an
                            // will react in Button also on this modifier
                            let _ = homeControlConnection.setFlag(UInt(Jet32GlobalVariables.flagCmdAllAutomaticShuttersUpSummerPos), tag: 0)       // Offset for Flags up
                        }) {
                            HStack {
                                Image(systemName: "sun.max")
                                Text("Alle Rolladen auf Sommerposition auf")
                            }
                        }
                        .disabled(currentTime != nil ? (false) : (true))        // enable only if connected
                        Spacer()
                    }
                    //.foregroundStyle(currentTime != nil ? .primary : .tertiary)
                    
                    HStack {
                        Spacer()
                        Button(action: {
                            // if used global .onTapGesture
                            // implementation will be don in .onTapGesture because we use this modifier in form an
                            // will react in Button also on this modifier
                            let _ = homeControlConnection.setFlag(UInt(Jet32GlobalVariables.flagCmdAllAutomaticShuttersDownSummerPos), tag: 0)       // Offset for Flags up
                        }) {
                            HStack {
                                Image(systemName: "sunset.fill")
                                Text("Alle Rolladen auf Sommerposition ab")
                            }
                        }
                        .disabled(currentTime != nil ? (false) : (true))        // enable only if connected
                        Spacer()
                    }
                    //.foregroundStyle(currentTime != nil ? .primary : .tertiary)
                })
 
            }
            
            
            
        }




        .navigationTitle("Steuerung")
//        .navigationBarTitleDisplayMode(.inline)
        .navigationBarTitleDisplayMode(.large)

        .onReceive(timer) { _ in
            //print("PLCView.onReceive(timer)")
            let _ = homeControlConnection.readIntRegister(UInt(Jet32GlobalVariables.regSecond), tag: UInt(HomeControlControllerTag.readSecond.rawValue))
            let _ = homeControlConnection.readIntRegister(UInt(Jet32GlobalVariables.regMinute), tag: UInt(HomeControlControllerTag.readMinute.rawValue))
            let _ = homeControlConnection.readIntRegister(UInt(Jet32GlobalVariables.regHour), tag: UInt(HomeControlControllerTag.readHour.rawValue))
        }

        // Problem, dass Button in Section dann nicht mehr erkannt wird
        // Button hat ebenfalls ein onTapGesture, das aufgerufen werden muss
        // Allerdings wird dann Form ebenfalls vor Button aufgerufen
/*        .onTapGesture {
            //print("onTapGesture Form")
            hideKeyboard()
        }
*/
        .onChange(of: selectedTab) { oldTab, newTab in
            print("PLCView.onChange: Change to tab \(selectedTab) Old: \(oldTab) New: \(newTab)")
            if (newTab == TabViews.PLCViewTab.rawValue) {
                print("PLCView Visible")
                
                homeControlConnection.setDelegate(delegate: self)
                homeControlConnection.connect()
                
                // read all needed values from PLC once
                let _ = homeControlConnection.readIntRegister(UInt(Jet32GlobalVariables.regSecond), tag: UInt(HomeControlControllerTag.readSecond.rawValue))
                let _ = homeControlConnection.readIntRegister(UInt(Jet32GlobalVariables.regMinute), tag: UInt(HomeControlControllerTag.readMinute.rawValue))
                let _ = homeControlConnection.readIntRegister(UInt(Jet32GlobalVariables.regHour), tag: UInt(HomeControlControllerTag.readHour.rawValue))

                let _ = homeControlConnection.readIntRegister(UInt(Jet32GlobalVariables.regUpTimeHour), tag: UInt(HomeControlControllerTag.readHourShutterUp.rawValue))
                let _ = homeControlConnection.readIntRegister(UInt(Jet32GlobalVariables.regUpTimeMinute), tag: UInt(HomeControlControllerTag.readMinuteShutterUp.rawValue))
                let _ = homeControlConnection.readIntRegister(UInt(Jet32GlobalVariables.regDownTimeHour), tag: UInt(HomeControlControllerTag.readHourShutterDown.rawValue))
                let _ = homeControlConnection.readIntRegister(UInt(Jet32GlobalVariables.regDownTimeMinute), tag: UInt(HomeControlControllerTag.readMinuteShutterDown.rawValue))
                let _ = homeControlConnection.readIntRegister(UInt(Jet32GlobalVariables.regUpTimeHourWeekend), tag: UInt(HomeControlControllerTag.readHourShutterUpWeekend.rawValue))
                let _ = homeControlConnection.readIntRegister(UInt(Jet32GlobalVariables.regUpTimeMinuteWeekend), tag: UInt(HomeControlControllerTag.readMinuteShutterUpWeekend.rawValue))

                let _ = homeControlConnection.readFlag(UInt(Jet32GlobalVariables.flagIsAutomaticShutter), tag: UInt(HomeControlControllerTag.readIsAutomaticShutter.rawValue))
                let _ = homeControlConnection.readFlag(UInt(Jet32GlobalVariables.flagIsAutomaticSummerMode), tag: UInt(HomeControlControllerTag.readIsAutomaticSummerMode.rawValue))
                let _ = homeControlConnection.readFlag(UInt(Jet32GlobalVariables.flagUseSunsetSettings), tag: UInt(HomeControlControllerTag.readUseSunsetSettings.rawValue))
                let _ = homeControlConnection.readIntRegister(UInt(Jet32GlobalVariables.regSunsetOffsetInMin), tag: UInt(HomeControlControllerTag.readSunsetOffsetInMin.rawValue))
                let _ = homeControlConnection.readFlag(UInt(Jet32GlobalVariables.flagIsAutomaticBlind), tag: UInt(HomeControlControllerTag.readIsAutomaticBlind.rawValue))
                let _ = homeControlConnection.readFlag(UInt(Jet32GlobalVariables.flagIsSaunaOn), tag: UInt(HomeControlControllerTag.readIsSaunaOn.rawValue))


                timer = Timer.publish(every: 1, on: .main, in: .common)
                _ = self.timer.connect()
                
            }
            if (oldTab == TabViews.PLCViewTab.rawValue) {
                print("PLCView Invisible")
                timer.connect().cancel()
                //homeControlConnection.setDelegate(delegate: nil)
            }
        }

    }
    
    
    // writes the current time from iPhone/iWatch to PLC
    func writeCurrentTimeToPLC() {
        let date = Date()
        let calendar = Calendar.current

        let hour = calendar.component(.hour, from: date)
        let minutes = calendar.component(.minute, from: date)
        let seconds = calendar.component(.second, from: date)
    
        let day = calendar.component(.day, from: date)
        let month = calendar.component(.month, from: date)
        let year = calendar.component(.year, from: date) - 2000

        let _ = homeControlConnection.writeIntRegister(UInt(Jet32GlobalVariables.regYear), to: year, tag: 0)
        let _ = homeControlConnection.writeIntRegister(UInt(Jet32GlobalVariables.regMonth), to: month, tag: 0)
        let _ = homeControlConnection.writeIntRegister(UInt(Jet32GlobalVariables.regDay), to: day, tag: 0)
        
        let _ = homeControlConnection.writeIntRegister(UInt(Jet32GlobalVariables.regHour), to: hour, tag: 0)
        let _ = homeControlConnection.writeIntRegister(UInt(Jet32GlobalVariables.regMinute), to: minutes, tag: 0)
        let _ = homeControlConnection.writeIntRegister(UInt(Jet32GlobalVariables.regSecond), to: seconds, tag: 0)
    }

    
    

    
    
}



extension PLCView: Jet32Delegate {

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
                upTimeHourWeekday = Int(value)
                upTimeWeekDay = calcNewTime(upTimeWeekDay, newHour: upTimeHourWeekday)
            case .readMinuteShutterUp:
                upTimeMinuteWeekday = Int(value)
                upTimeWeekDay = calcNewTime(upTimeWeekDay, newMinute: upTimeMinuteWeekday)
            case .readHourShutterDown:
                downTimeHourWeekday = Int(value)
                downTimeWeekDay = calcNewTime(downTimeWeekDay, newHour: downTimeHourWeekday)
            case .readMinuteShutterDown:
                downTimeMinuteWeekday = Int(value)
                downTimeWeekDay = calcNewTime(downTimeWeekDay, newMinute: downTimeMinuteWeekday)
            case .readHourShutterUpWeekend:
                upTimeHourWeekend = Int(value)
                upTimeWeekend = calcNewTime(upTimeWeekend, newHour: upTimeHourWeekend)
            case .readMinuteShutterUpWeekend:
                upTimeMinuteWeekend = Int(value)
                upTimeWeekend = calcNewTime(upTimeWeekend, newMinute: upTimeMinuteWeekend)

            case .readCurrentStateNightDay:
                print("PLCView.didReceiveReadRegister: no implementation for \(plcTag)")
            case .readCurrentStateWind:
                print("PLCView.didReceiveReadRegister: no implementation for \(plcTag)")
            case .readCurrentStateLight:
                print("PLCView.didReceiveReadRegister: no implementation for \(plcTag)")

            case .readSunsetHourForToday:
                print("PLCView.didReceiveReadRegister: no implementation for \(plcTag)")
            case .readSunsetMinuteForToday:
                print("PLCView.didReceiveReadRegister: no implementation for \(plcTag)")
            case .readSunsetOffsetInMin:
                sunsetOffset = Int(value)

            default:
                print("Error: PLCView.didReceiveReadRegister no case for tag \(tag)")
            }
            //print("didReceiveReadRegister \(value) \(tag)")
        }
    }

    
    
    
    func didReceiveReadFlag(value: Bool, tag: UInt) {
        
        if let plcTag = HomeControlControllerTag(rawValue: UInt32(tag)) {
            
            switch (plcTag) {
            case .readIsAutomaticBlind:
                isAutomaticBlind = Bool(value)
            case .readIsAutomaticShutter:
                isAutomaticShutter = Bool(value)
            case .readIsAutomaticSummerMode:
                isAutomaticSummerMode = Bool(value)

            case .readIsSaunaOn:
                isSaunaOn = Bool(value)

            case .readUseSunsetSettings:
                useSunsetSettings = Bool(value)

            default:
                print("Error: PLCView.didReceiveReadFlag no case for tag \(tag)")
            }
            //print("PLCView.didReceiveReadFlag \(value) \(tag)")
        }
        
    }
    
    
    // helper functions
    // change currentTime var if all time vars are available
    func setCurrentTimeString() {
        if ((currentHour != nil) && (currentMinute != nil) && (currentSecond != nil)) {
            currentTime = String(format: "%02d:%02d:%02d", currentHour!, currentMinute!, currentSecond!)
        }
    }

    // create a new Date-Object with the given hour and minute
    func calcNewTime(_ currentDate: Date, newHour: Int? = nil, newMinute: Int? = nil) -> Date {
        // Create a Calendar instance
        let calendar = Calendar.current

        // Extract components from the existing date
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: currentDate)

        // Create new components with the desired hours and minutes
        var newComponents = DateComponents()
        newComponents.year = components.year
        newComponents.month = components.month
        newComponents.day = components.day

        if (newHour != nil) {
            newComponents.hour = newHour! // Set the desired hour
        } else {
            newComponents.hour = components.hour
        }
        if (newMinute != nil) {
            newComponents.minute = newMinute! // Set the desired minute
        } else {
            newComponents.minute = components.minute
        }
        
        newComponents.second = components.second

        // Create a new date using the modified components
        if let newDate = calendar.date(from: newComponents) {
            //print("Existing Date: \(currentDate)")
            //print("Modified Date: \(newDate)")
            return newDate
        } else {
            print("Error creating modified date.")
            return currentDate
        }
    }
    
    
    
    
    
    
}






extension PLCView: PLCDataAccessibleDelegate {
    func didReceiveReadIntRegister(_ number: UInt, with value: Int, tag: UInt) {
        //print(String(describing: type(of: self)) + ".\(#function)(tag: \(tag)): \(number): \(value)")
        didReceiveReadRegister(value: UInt(value), tag: tag)            // call function from Jet32Delegate
    }
 /*
    func didReceiveWriteIntRegister(_ number: UInt, tag: UInt) {
        print(String(describing: type(of: self)) + ".\(#function)[\(#line)]: called")
    }
   */
    func didReceiveReadFlag(_ number: UInt, with value: Bool, tag: UInt) {
        //print(String(describing: type(of: self)) + ".\(#function)(tag: \(tag)): \(number): \(value)")
        didReceiveReadFlag(value: value, tag: tag)            // call function from Jet32Delegate
    }
/*
    func didReceiveSetFlag(_ number: UInt, tag: UInt) {
        print(String(describing: type(of: self)) + ".\(#function)[\(#line)]: called")
    }
    func didReceiveClearFlag(_ number: UInt, tag: UInt) {
        print(String(describing: type(of: self)) + ".\(#function)[\(#line)]: called")
    }
 */
    /*
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
    return PLCView(selectedTab: .constant(TabViews.PLCViewTab.rawValue))
}






