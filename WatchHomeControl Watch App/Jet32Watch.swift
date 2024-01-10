//
//  Jet32Watch.swift
//  WatchHomeControl Watch App
//
//  Created by Joachim Kittelberger on 04.01.24.
//  Copyright © 2024 Joachim Kittelberger. All rights reserved.
//

import Foundation



class Jet32Watch : NSObject {

    // Connectivity tp iPhone
    let connectivity = Connectivity.sharedInstance


    // singleton Zugriff ueber Jet32.sharedInstance
    static let sharedInstance = Jet32Watch()
    
    // private initializer for singleton
    private override init() {
        super.init()
    }
    
    deinit {
        disconnect()
        print("Jet32Watch.deinit called")
    }
    
    
    private var delegate:PlcDataAccessibleDelegate?
    func setDelegate(delegate: PlcDataAccessibleDelegate?) {
        // Wenn schon ein anderes delegate existiert, darf die queue gelöscht werden
        if (!(self.delegate == nil)) {
            //clearPlcDataAccessQueue()
        }
        // wenn sich niemand mehr dafür interessiert, darf die queue gelöscht werden
        if (delegate == nil) {
            //clearPlcDataAccessQueue()
        }
        self.delegate = delegate
        
 //       print("Jet32Watch.PlcDataAccessibleDelegate.setDelegate \(String(describing: delegate))")
    }

    // TODO: insert this in protocol
    func connect() {
        print("\(#file) " + String(describing: type(of: self)) + ".\(#function)[\(#line)]: not implemented")
    }
    
    func disconnect() {
        print("\(#file) " + String(describing: type(of: self)) + ".\(#function)[\(#line)]: not implemented")
    }
}





// Muss von dem Kommunikationskanal implementiert werden, der Daten aus einer Steuerung lesen und
// schreiben kann

extension Jet32Watch : PlcDataAccessibleProtocol {
    
    func readIntRegister(_ number: UInt, tag: UInt) {
        print("\(#file) " + String(describing: type(of: self)) + ".\(#function)[\(#line)]: not implemented")
    }
    
    func readIntRegisterSync(_ number: UInt, tag: UInt) -> Int {
        print("\(#file) " + String(describing: type(of: self)) + ".\(#function)[\(#line)]: not implemented")
        return -1
    }
    
    func writeIntRegister(_ number: UInt, to value: Int, tag: UInt) {
        print("\(#file) " + String(describing: type(of: self)) + ".\(#function)[\(#line)]: not implemented")
    }
    
    func readFlag(_ number: UInt, tag: UInt) {
        print("\(#file) " + String(describing: type(of: self)) + ".\(#function)[\(#line)]: not implemented")
    }

    func setFlag(_ number: UInt, tag: UInt) {
        print("\(#file) " + String(describing: type(of: self)) + ".\(#function)[\(#line)]: called")
        
        // TODO: Test sending Message
        let key = ConnectivityUserInfoKey.setFlag.rawValue
        let message = [key: number]
        connectivity.send(message: message,
            replyHandler: nil,
            errorHandler: nil
            //errorHandler: { error in
            //    print("Error sending message:", error)
            //}
        )

        
    }

    func clearFlag(_ number: UInt, tag: UInt) {
        print("\(#file) " + String(describing: type(of: self)) + ".\(#function)[\(#line)]: not implemented")
    }
    
    func readOutput(_ number: UInt, tag: UInt) {
        print("\(#file) " + String(describing: type(of: self)) + ".\(#function)[\(#line)]: not implemented")
    }
    
    func setOutput(_ number: UInt, tag: UInt) {
        print("\(#file) " + String(describing: type(of: self)) + ".\(#function)[\(#line)]: not implemented")
    }
    
    func clearOutput(_ number: UInt, tag: UInt) {
        print("\(#file) " + String(describing: type(of: self)) + ".\(#function)[\(#line)]: not implemented")
    }
 }
