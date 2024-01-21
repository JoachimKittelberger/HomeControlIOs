//
//  Jet32Watch+PLCDataAccessibleProtocol.swift
//  WatchHomeControl Watch App
//
//  Created by Joachim Kittelberger on 17.01.24.
//  Copyright © 2024 Joachim Kittelberger. All rights reserved.
//

import Foundation


// Muss von dem Kommunikationskanal implementiert werden, der Daten aus einer Steuerung lesen und
// schreiben kann

extension Jet32Watch : PLCDataAccessibleProtocol {
    
    func readIntRegister(_ number: UInt, tag: UInt, delegate: PLCDataAccessibleDelegate? = nil) {
        //print(String(describing: type(of: self)) + ".\(#function)[\(#line)]: called")

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
                    if (msgType == MessageType.responseReadRegister) {
         
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
  
    
    func writeIntRegister(_ number: UInt, to value: Int, tag: UInt, delegate: PLCDataAccessibleDelegate? = nil) {
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
        //print(String(describing: type(of: self)) + ".\(#function)[\(#line)]: called")

        // könnte auch in message: JSON verpackt werden
        let message : [String : Any] = [
            "type": MessageType.getFlag.rawValue,
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
                    if (msgType == MessageType.responseReadFlag) {
         
                        var number = UInt(0)
                        var value = Bool(false)
                        var tag = UInt(0)
                       
                        if let retVal = response["value"] as? String {
                            value = (retVal as AnyObject).boolValue
                            
                            if let retVal = response["number"] as? String {
                                number = UInt((retVal as AnyObject).integerValue)

                                if let retVal = response["tag"] as? String {
                                    tag = UInt((retVal as AnyObject).integerValue)

                                    //print("ResponsefromiPhone: number: \(number) value: \(value) tag: \(tag)")
                                    self.delegate?.didReceiveReadFlag(number, with: value, tag: tag);
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

    
    
    func setFlag(_ number: UInt, tag: UInt, delegate: PLCDataAccessibleDelegate? = nil) {
        print(String(describing: type(of: self)) + ".\(#function)[\(#line)]: \(number) called")
 
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

    
    
    func clearFlag(_ number: UInt, tag: UInt, delegate: PLCDataAccessibleDelegate? = nil) {
        print(String(describing: type(of: self)) + ".\(#function)[\(#line)]: \(number) called")

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

    
    
    
  /*
    
    func readOutput(_ number: UInt, tag: UInt, delegate: PLCDataAccessibleDelegate? = nil) {
        print(String(describing: type(of: self)) + ".\(#function)[\(#line)]: not implemented")
    }
    
    func setOutput(_ number: UInt, tag: UInt, delegate: PLCDataAccessibleDelegate? = nil) {
        print(String(describing: type(of: self)) + ".\(#function)[\(#line)]: not implemented")
    }
    
    func clearOutput(_ number: UInt, tag: UInt, delegate: PLCDataAccessibleDelegate? = nil) {
        print(String(describing: type(of: self)) + ".\(#function)[\(#line)]: not implemented")
    }
    func readIntRegisterSync(_ number: UInt, tag: UInt, delegate: PLCDataAccessibleDelegate? = nil) -> Int {
        print(String(describing: type(of: self)) + ".\(#function)[\(#line)]: not implemented")
        return -1
    }

   */
 }
