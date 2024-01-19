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
    
    // TODO communication with Queue
    var PlcDataAccessQueue = [PLCDataAccessEntry]()
    
    
 
    
    
    // TODO for Test. Print communication settings of socket
    func printSocketBindingInfo() {
        print("Connect to \(host) Send: \(udpPortSend) Receive: \(udpPortReceive) TimeOut: \(timeoutJet32)")
    }
  
    
    // TODO: implement
    func connect() {
        // printSocketBindingInfo()
        
        // incoming socket
        if inSocket == nil {
            inSocket = GCDAsyncUdpSocket(delegate: self, delegateQueue: DispatchQueue.main)

            // try up to 10 Ports to connect ReceivePort
            for _ in 0...9 {
                let isConnected = bindAndBeginReceiving(toPort: udpPortReceive)
                if isConnected == true {
                    //print("Connected to ReceivePort: \(udpPortReceive)")
                    break;
                }
                udpPortReceive += 1
            }
            
            /*
            do {
                try inSocket?.bind(toPort: udpPortReceive)
                try inSocket?.beginReceiving()
            } catch let error {
                print(error.localizedDescription)
                inSocket?.close()
                return
            }
             */
        }

            
        // outgoing socket
        if outSocket == nil {
            outSocket = GCDAsyncUdpSocket(delegate: self, delegateQueue: DispatchQueue.main)
            
            do {
                try outSocket?.connect(toHost: host, onPort: udpPortSend)
            } catch let error {
                print(error.localizedDescription)
                outSocket?.close()
                return
            }
        }
    }

    
    func bindAndBeginReceiving(toPort receivePort: UInt16) -> Bool {
        do {
            try inSocket?.bind(toPort: receivePort)
            try inSocket?.beginReceiving()
        } catch let error {
            print(error.localizedDescription)
            inSocket?.close()
            return false
        }
        return true
    }

    
    func disconnect() {
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
        
        // TODO finalize the queues
        clearPlcDataAccessQueue()
    }

  
    
    func clearPlcDataAccessQueue() {
        print("PlcDataAccessQueue.count ≠\(PlcDataAccessQueue.count)")
        PlcDataAccessQueue.removeAll()         // TODO hier sollte sicher sein, dass nicht noch ein Element verwendet wird.
    }
     
}


