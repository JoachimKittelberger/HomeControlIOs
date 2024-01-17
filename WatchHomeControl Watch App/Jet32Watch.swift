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
    let connectivity = Connectivity.shared


    // singleton Zugriff ueber Jet32.shared
    static let shared = Jet32Watch()
    
    // private initializer for singleton
    private override init() {
        super.init()
    }
    
    deinit {
        disconnect()
        print("Jet32Watch.deinit called")
    }
    
    
    private(set) var delegate:PLCDataAccessibleDelegate?
    func setDelegate(delegate: PLCDataAccessibleDelegate?) {
        // Wenn schon ein anderes delegate existiert, darf die queue gelöscht werden
        if (!(self.delegate == nil)) {
            //clearPlcDataAccessQueue()
        }
        // wenn sich niemand mehr dafür interessiert, darf die queue gelöscht werden
        if (delegate == nil) {
            //clearPlcDataAccessQueue()
        }
        self.delegate = delegate
        
 //       print("Jet32Watch.PLCDataAccessibleDelegate.setDelegate \(String(describing: delegate))")
    }

    
    // TODO: insert this in protocol
    func connect() {
        print(String(describing: type(of: self)) + ".\(#function)[\(#line)]: not implemented")
    }
    
    func disconnect() {
        print(String(describing: type(of: self)) + ".\(#function)[\(#line)]: not implemented")
    }
}





// Muss von dem Kommunikationskanal implementiert werden, der Daten aus einer Steuerung lesen und
// schreiben kann

extension Jet32Watch : PLCDataAccessibleProtocol {
    
    func readIntRegister(_ number: UInt, tag: UInt, delegate: PLCDataAccessibleDelegate? = nil) {
        print(String(describing: type(of: self)) + ".\(#function)[\(#line)]: called")

        // könnte auch in message: JSON verpackt werden
        let message : [String : Any] = [
            "type": MessageType.readRegister.rawValue,
            "number": String(number),
            "value": String(0),
            "tag": String(tag)
        ]
        connectivity.sendMessage(message,
            //replyHandler: nil,
            //errorHandler: nil
            replyHandler: { response in
                // handle response from Apple Watch
                //print("Response from Apple Watch:", response)
                
                // test, if we have an response from iPhone to Apple Watch
                if let val = response["type"] as? String {
                    let msgType = MessageType(rawValue: (val))!
                    if (msgType == MessageType.response) {
         
                        var number = UInt(0)
                        var value = Int(0)
                        var tag = UInt(0)
                       
                        if let retVal = response["value"] as? String {
                            value = (retVal as AnyObject).integerValue
                            
                            if let retVal = response["number"] as? String {
                                number = UInt((retVal as AnyObject).integerValue)

                                if let retVal = response["tag"] as? String {
                                    tag = UInt((retVal as AnyObject).integerValue)

                                    //print("ResponsefromiPhone: number: \(number) value: \(value) tag: \(tag)")
                                    self.delegate?.didReceiveReadIntRegister(number, with: value, tag: tag);
                                }
                            }
                        }
                        return
                    }
                }
            },
            errorHandler: { error in
                // handle error
                print("Error sending message:", error.localizedDescription)
            }
        )
    }
  
    
    
    func readIntRegisterSync(_ number: UInt, tag: UInt, delegate: PLCDataAccessibleDelegate? = nil) -> Int {
        print(String(describing: type(of: self)) + ".\(#function)[\(#line)]: not implemented")
        return -1
    }
    
    func writeIntRegister(_ number: UInt, to value: Int, tag: UInt) {
        print(String(describing: type(of: self)) + ".\(#function)[\(#line)]: called")

        let message : [String : Any] = [
            "type": MessageType.writeRegister.rawValue,
            "number": String(number),
            "value": String(value),
            "tag": String(tag)
        ]
        connectivity.sendMessage(message,
            replyHandler: nil,
            //errorHandler: nil
            errorHandler: { error in
            print("Error sending message:", error.localizedDescription)
            }
        )
    }
    
    func readFlag(_ number: UInt, tag: UInt, delegate: PLCDataAccessibleDelegate? = nil) {
        print(String(describing: type(of: self)) + ".\(#function)[\(#line)]: not implemented")
    }

    func setFlag(_ number: UInt, tag: UInt) {
        print(String(describing: type(of: self)) + ".\(#function)[\(#line)]: called")
 
        let message : [String : Any] = [
            "type": MessageType.setFlag.rawValue,
            "number": String(number),
            "value": String(1),
            "tag": String(tag)
        ]
        connectivity.sendMessage(message,
            replyHandler: nil,
            //errorHandler: nil
            errorHandler: { error in
            print("Error sending message:", error.localizedDescription)
            }
        )
    }

    func clearFlag(_ number: UInt, tag: UInt) {
        print(String(describing: type(of: self)) + ".\(#function)[\(#line)]: called")

        let message : [String : Any] = [
            "type": MessageType.setFlag.rawValue,
            "number": String(number),
            "value": String(0),
            "tag": String(tag)
        ]
        connectivity.sendMessage(message,
            replyHandler: nil,
            //errorHandler: nil
            errorHandler: { error in
            print("Error sending message:", error.localizedDescription)
            }
        )
    }
    
    func readOutput(_ number: UInt, tag: UInt, delegate: PLCDataAccessibleDelegate? = nil) {
        print(String(describing: type(of: self)) + ".\(#function)[\(#line)]: not implemented")
    }
    
    func setOutput(_ number: UInt, tag: UInt) {
        print(String(describing: type(of: self)) + ".\(#function)[\(#line)]: not implemented")
    }
    
    func clearOutput(_ number: UInt, tag: UInt) {
        print(String(describing: type(of: self)) + ".\(#function)[\(#line)]: not implemented")
    }
 }
