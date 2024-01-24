//
//  Jet32.swift
//  HomeControl
//
//  Created by Joachim Kittelberger on 08.06.17.
//  Copyright © 2017 Joachim Kittelberger. All rights reserved.
//

import Foundation



class Jet32 : NSObject {

    // singleton Zugriff ueber Jet32.shared
    static let shared = Jet32()
    
    // private initializer for singleton
    private override init() {
        super.init()
    }
    
    deinit {
        print(String(describing: type(of: self)) + ".\(#function)[\(#line)]: called")
        disconnect()
    }

    
    
    private(set) var delegate:PLCDataAccessibleDelegate?
    func setDelegate(delegate: PLCDataAccessibleDelegate?) {
        // Wenn schon ein anderes delegate existiert, darf die queue gelöscht werden
        if (!(self.delegate == nil)) {
            clearPlcDataAccessQueue()
        }
        // wenn sich niemand mehr dafür interessiert, darf die queue gelöscht werden
        if (delegate == nil) {
            clearPlcDataAccessQueue()
        }
        
        self.delegate = delegate
//        print("PLCDataAccessibleDelegate.setDelegate \(String(describing: delegate))")
    }

    
    // socket settings
    var udpPortSend: UInt16 = 0
    var udpPortReceive: UInt16 = 0
    var host = "127.0.0.1"
    var timeoutJet32 : UInt16 = 2000     // Default Jet32 Timeout 2 s
    
    var inSocket: GCDAsyncUdpSocket?
    var outSocket: GCDAsyncUdpSocket?

    
    var timeout: TimeInterval = 2   // Default Timeout GCDAsyncUdpSocket: 2s
    var isConnected : Bool = false     // TODO: mit Timeout-Überprüfung bei SyncCalls
    
    // communication with Queue
    var PlcDataAccessQueue = [PLCDataAccessEntry]()
    
    
 
    
    
    // for Test. Print communication settings of socket
    func printSocketBindingInfo() {
        print("Connect to \(host) Send: \(udpPortSend) Receive: \(udpPortReceive) TimeOut: \(timeoutJet32)")
    }
  
    
    func connect() {
        // printSocketBindingInfo()
        
 /*
        // TODO test Errorhandling
        if !(inSocket?.isConnected() ?? false) {
            disconnect()
        }
        if !(outSocket?.isConnected() ?? false) {
            disconnect()
        }
*/
        
        // outgoing socket
        if outSocket == nil {
            print("Connect outSocket")
            outSocket = GCDAsyncUdpSocket(delegate: self, delegateQueue: DispatchQueue.main)
            
            do {
                try outSocket?.connect(toHost: host, onPort: udpPortSend)
            } catch let error {
                print(error.localizedDescription)
                outSocket?.close()
                outSocket = nil
                return
            }
        }

        
        // incoming socket
        if inSocket == nil {
            print("Connect inSocket")
            // try up to 10 Ports to connect ReceivePort
            for _ in 0...9 {
                let isConnected = bindAndBeginReceiving(toPort: udpPortReceive)
                if isConnected == true {
                    print("Connected to ReceivePort: \(udpPortReceive)")
                    break;
                }
                udpPortReceive += 1
            }
        }
    }

    
    func bindAndBeginReceiving(toPort receivePort: UInt16) -> Bool {
        inSocket = GCDAsyncUdpSocket(delegate: self, delegateQueue: DispatchQueue.main)
        do {
            try inSocket?.bind(toPort: receivePort)
            try inSocket?.beginReceiving()
        } catch let error {
            print(error.localizedDescription)
            inSocket?.close()
            inSocket = nil
            return false
        }
        return true
    }

    
    func disconnect() {
        print("Jet32.disconnect()")
        // incoming socket
        if inSocket != nil {
            inSocket?.close()
        }
        inSocket = nil
        
        // outgoing socket
        if outSocket != nil {
            outSocket?.close()
        }
        outSocket = nil
        
        // finalize the queues
        clearPlcDataAccessQueue()
        isConnected = false
    }

  
    
    func clearPlcDataAccessQueue() {
        if (PlcDataAccessQueue.count != 0) {
            print("PlcDataAccessQueue.count ≠ \(PlcDataAccessQueue.count)")
        }
        PlcDataAccessQueue.removeAll()
    }
     
}


