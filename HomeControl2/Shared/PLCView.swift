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
    let homeControlConnection = PlcComMgr.sharedInstance

    // TODO: For Test. Starte Timer im Modus gestoppt und Zähle dann die Sekunden hoch
    @State private var currentSeconds = 0
    @State private var timer = Timer.publish(every: 1, on: .main, in: .common)
    
    var body: some View {
        //NavigationStack {
        VStack {
            Text("Steuerung-Seite")
            Text("Sekunden: \(currentSeconds)")
        }
        //}
        .navigationTitle("Steuerung")
//        .navigationBarTitleDisplayMode(.inline)
        .navigationBarTitleDisplayMode(.large)

        .onReceive(timer) { _ in
            print("PLCView.onReceive(timer)")
            let _ = homeControlConnection.readIntRegister(UInt(Jet32GlobalVariables.regSecond), tag: UInt(PLCViewControllerTag.readSecond.rawValue))
        }

        // wird statt viewDidLoad verwendet
        // TODO: Sollte lieber beim Start der App inmd beim Ändern der Settings einmalig gemacht werden
        .onAppear {
            print("PLCView.onAppear")
            homeControlConnection.setDelegate(delegate: self)
            homeControlConnection.connect()
            
            let _ = homeControlConnection.readIntRegister(UInt(Jet32GlobalVariables.regSecond), tag: UInt(PLCViewControllerTag.readSecond.rawValue))
            timer = Timer.publish(every: 1, on: .main, in: .common)
            _ = self.timer.connect()
        }
        .onDisappear() {
            print("PLCView.onDisappear")
            timer.connect().cancel()
            homeControlConnection.setDelegate(delegate: nil)
        }
        // used with own modifier
        .onViewDidLoad {
            // TODO: do something only one time in this closure
            // will be called after .onAppear
            print("PLCView.onViewDidLoad Modifier")
        }

    }
}




extension PLCView: Jet32Delegate {
   
    enum PLCViewControllerTag: UInt32 {
        case readSecond
        case readMinute
        case readHour
        case readHourShutterUp
        case readMinuteShutterUp
        case readHourShutterDown
        case readMinuteShutterDown
        case readHourShutterUpWeekend
        case readMinuteShutterUpWeekend
        
        case readIsAutomaticBlind
        case readIsAutomaticShutter
        case readIsAutomaticSummerMode

        case readIsSaunaOn
        
        case readCurrentStateNightDay
        case readCurrentStateWind
        case readCurrentStateLight
        
        case readUseSunsetSettings
        case readSunsetHourForToday
        case readSunsetMinuteForToday
        case readSunsetOffsetInMin
    }

    
    
    func didReceiveReadRegister(value: UInt, tag: UInt) {
        if let plcTag = PLCViewControllerTag(rawValue: UInt32(tag)) {
            switch (plcTag) {
            case .readSecond:
                currentSeconds = Int(value)
                //setTimeLabelText()
                
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
    
}






extension PLCView: PlcDataAccessibleDelegate {
    func didRedeiveReadIntRegister(_ number: UInt, with value: Int, tag: UInt) {
        print("didRedeiveReadIntRegister(tag: \(tag)): \(number): \(value)")
        
        didReceiveReadRegister(value: UInt(value), tag: tag)
        
        
    }
    func didRedeiveWriteIntRegister(_ number: UInt, tag: UInt) {
        
    }
    
    func didRedeiveReadFlag(_ number: UInt, with value: Bool, tag: UInt) {
        print("didReceiveReadFlag(tag: \(tag)): \(number): \(value)")
        didReceiveReadFlag(value: value, tag: tag)
        
    }
    func didRedeiveSetFlag(_ number: UInt, tag: UInt) {
        
    }
    func didRedeiveClearFlag(_ number: UInt, tag: UInt) {
        
    }
    
    func didRedeiveReadOutput(_ number: UInt, with value: Bool, tag: UInt) {
        
    }
    func didRedeiveSetOutput(_ number: UInt, tag: UInt) {
        
    }
    func didRedeiveClearOutput(_ number: UInt, tag: UInt) {
        
    }

}






#Preview {
    return PLCView()
}






