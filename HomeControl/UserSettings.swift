//
//  UserSettings.swift
//  HomeControl
//
//  Created by Joachim Kittelberger on 09.01.24.
//  Copyright © 2024 Joachim Kittelberger. All rights reserved.
//

import Foundation



// string constants for UserSettings
let udpPortSend = "udpPortSend"
let udpPortReceive = "udpPortReceive"
let host = "host"
let timeoutJet32 = "timeout"



// initialize the UserDefaults with appDefaults.plist. Should be done in AppDelegate(init)
func initUserDefaults() {
    let userDefaults = UserDefaults.standard
    if let url = Bundle.main.url(forResource: "appDefaults", withExtension: "plist"), let appDefaults = NSDictionary(contentsOf: url) {
        userDefaults.register(defaults: appDefaults as! [String: AnyObject])
    }
}



// should bei donn in application(didFinishLaunchingWithOptions just one time
func loadUserDefaults() {
    // Load from UserDefaults
    // TODO: Könnte auch in ViewController mit var userDefaults = UserDefaults.standard und dann Zugriff über userdefaults.integer(forKey: ...) gemacht werden
    let userDefaults = UserDefaults.standard
    let homeControlConnection = Jet32.shared

    homeControlConnection.udpPortSend = UInt16(userDefaults.integer(forKey: udpPortSend))
    homeControlConnection.udpPortReceive = UInt16(userDefaults.integer(forKey: udpPortReceive))
    homeControlConnection.host = userDefaults.string(forKey: host)!
    homeControlConnection.timeoutJet32 = UInt16(userDefaults.integer(forKey: timeoutJet32))
}



// will be done after changing them in SettingsView
func saveUserDefaults() {
    let homeControlConnection = Jet32.shared
    
    // store data to UserDefaults
    let userDefaults = UserDefaults.standard
    userDefaults.set(Int(homeControlConnection.udpPortSend), forKey: udpPortSend)
    userDefaults.set(Int(homeControlConnection.udpPortReceive), forKey: udpPortReceive)
    userDefaults.set((homeControlConnection.host), forKey: host)
    userDefaults.set(Int(homeControlConnection.timeoutJet32), forKey: timeoutJet32)
}
