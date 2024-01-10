//
//  PlcComMgr.swift
//  HomeControl
//
//  Created by Joachim Kittelberger on 04.01.24.
//  Copyright © 2024 Joachim Kittelberger. All rights reserved.
//

import Foundation

class PlcComMgr : NSObject {
    
    // singleton Zugriff ueber Jet32.sharedInstance
    static let sharedInstance = PlcComMgr()
    
    // private initializer for singleton
    private override init() {
        super.init()
    }
    
    deinit {
        //disconnect()
        print("PlcComMgr.deinit called")
    }
    
    // TODO: Evtl. noch mit in Protocol aufnehmen. Ebenso Connect und disconnect
    private var delegate:PlcDataAccessibleDelegate?
    func setDelegate(delegate: PlcDataAccessibleDelegate?) {
        homeControlConnection.setDelegate(delegate: delegate)
    }


    // Geht nur über iPhone mit z.B. UDPManager oder WCSession, ...
#if os(iOS)
    let homeControlConnection = Jet32.sharedInstance   
#endif

#if os(watchOS)
    let homeControlConnection = Jet32Watch.sharedInstance
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

extension PlcComMgr : PlcDataAccessibleProtocol {
    
    func readIntRegister(_ number: UInt, tag: UInt) {
        homeControlConnection.readIntRegister(number, tag: tag)
    }
    
    func readIntRegisterSync(_ number: UInt, tag: UInt) -> Int {
        return homeControlConnection.readIntRegisterSync(number, tag: tag)
    }
    
    func writeIntRegister(_ number: UInt, to value: Int, tag: UInt) {
        homeControlConnection.writeIntRegister(number, to: value, tag: tag)
    }
    
    func readFlag(_ number: UInt, tag: UInt) {
        homeControlConnection.readFlag(number, tag: tag)
    }

    func setFlag(_ number: UInt, tag: UInt) {
        homeControlConnection.setFlag(number, tag: tag)
    }

    func clearFlag(_ number: UInt, tag: UInt) {
        homeControlConnection.clearFlag(number, tag: tag)
    }
    
    func readOutput(_ number: UInt, tag: UInt) {
        homeControlConnection.readOutput(number, tag: tag)
    }
    
    func setOutput(_ number: UInt, tag: UInt) {
        homeControlConnection.setOutput(number, tag: tag)
    }
    
    func clearOutput(_ number: UInt, tag: UInt) {
        homeControlConnection.clearOutput(number, tag: tag)
    }
 }
