//
//  PLCComMgr.swift
//  HomeControl
//
//  Created by Joachim Kittelberger on 04.01.24.
//  Copyright © 2024 Joachim Kittelberger. All rights reserved.
//

import Foundation

class PLCComMgr : NSObject {
    
    // singleton Zugriff ueber Jet32.shared
    static let shared = PLCComMgr()
    
    // private initializer for singleton
    private override init() {
        super.init()
#if os(iOS)
        // get Jet32 timeout and use it for synctimeout
        timeoutSyncCall = Int(homeControlConnection.timeoutJet32) / 1000
#endif
    }
    
    deinit {
        //disconnect()
        print("PLCComMgr.deinit called")
    }
    
    // TODO: Evtl. noch mit in Protocol aufnehmen. Ebenso Connect und disconnect
    
    // use delegate of underlaying homeControlConnection
    //private var delegate: PLCDataAccessibleDelegate?
    func setDelegate(delegate: PLCDataAccessibleDelegate?) {
        //self.delegate = delegate
        homeControlConnection.setDelegate(delegate: delegate)
    }
    func getDelegate() -> PLCDataAccessibleDelegate? {
        return homeControlConnection.delegate
    }



    // Geht nur über iPhone mit z.B. UDPManager oder WCSession, ...
    var timeoutSyncCall : Int = 5     // Default Timeout 5s für iOS
#if os(iOS)
    let homeControlConnection = Jet32.shared   
#endif

#if os(watchOS)
    let homeControlConnection = Jet32Watch.shared
#endif

    func connect() {
        homeControlConnection.connect()
    }
    
    func disconnect() {
        homeControlConnection.disconnect()
    }
    
}





// Muss von dem Kommunikationskanal implementiert werden, der Daten aus einer Steuerung lesen und
// schreiben kann
// wird von Jet32 und Jet32Watch implementiert
// Jet32 geht dabei direkt auf das UDP-Socket
// Jet32Watch geht über Connectivity und WCSession auf das iPhone und dort erst auf UDP-Socket

extension PLCComMgr : PLCDataAccessibleProtocol {
    
    func readIntRegister(_ number: UInt, tag: UInt, delegate: PLCDataAccessibleDelegate? = nil) {
        homeControlConnection.readIntRegister(number, tag: tag, delegate: delegate)
    }
    func writeIntRegister(_ number: UInt, to value: Int, tag: UInt, delegate: PLCDataAccessibleDelegate? = nil) {
        homeControlConnection.writeIntRegister(number, to: value, tag: tag, delegate: delegate)
    }
    func readFlag(_ number: UInt, tag: UInt, delegate: PLCDataAccessibleDelegate? = nil) {
        homeControlConnection.readFlag(number, tag: tag, delegate: delegate)
    }
    func setFlag(_ number: UInt, tag: UInt, delegate: PLCDataAccessibleDelegate? = nil) {
        homeControlConnection.setFlag(number, tag: tag, delegate: delegate)
    }
    func clearFlag(_ number: UInt, tag: UInt, delegate: PLCDataAccessibleDelegate? = nil) {
        homeControlConnection.clearFlag(number, tag: tag, delegate: delegate)
    }
/*
    func readOutput(_ number: UInt, tag: UInt, delegate: PLCDataAccessibleDelegate? = nil) {
        homeControlConnection.readOutput(number, tag: tag, delegate: delegate)
    }
    
    func setOutput(_ number: UInt, tag: UInt, delegate: PLCDataAccessibleDelegate? = nil) {
        homeControlConnection.setOutput(number, tag: tag, delegate: delegate)
    }
    
    func clearOutput(_ number: UInt, tag: UInt, delegate: PLCDataAccessibleDelegate? = nil) {
        homeControlConnection.clearOutput(number, tag: tag, delegate: delegate)
    }
    func readIntRegisterSync(_ number: UInt, tag: UInt, delegate: PLCDataAccessibleDelegate? = nil) -> Int {
        return homeControlConnection.readIntRegisterSync(number, tag: tag, delegate: delegate)
    }
*/
 }
