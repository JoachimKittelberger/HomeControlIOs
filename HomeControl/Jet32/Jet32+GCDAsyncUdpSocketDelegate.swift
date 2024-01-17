//
//  Jet32+GCDAsyncUdpSocketDelegate.swift
//  HomeControl
//
//  Created by Joachim Kittelberger on 12.01.24.
//  Copyright © 2024 Joachim Kittelberger. All rights reserved.
//



import Foundation


extension Jet32 : GCDAsyncUdpSocketDelegate {
    
    func udpSocket(_ sock: GCDAsyncUdpSocket, didReceive data: Data, fromAddress address: Data, withFilterContext filterContext: Any?) {

        // Check Header
        if (data.count >= 20) {         // check minimum data length required
            if data[0] == 0x4A && data[1] == 0x57 && data[2] == 0x49 && data[3] == 0x50 {

                // read communication-Reference as telegramID
                let telegramID = (UInt(data[8]) * 256*256*256) + (UInt(data[9]) * 256*256) + (UInt(data[10]) * 256) + UInt(data[11])
                
                // anhand telegramID die eigentliche comRef Referenz herausfinden und den Wert zurückgeben
                if telegramID != 0 {
                    
                    // suche PLCDataAccessEntry in PLCDataAcessQueue
                    if let offset = PlcDataAccessQueue.firstIndex(where: { $0.telegramID == telegramID }) {

                        // get the PLCDataAccessEntry for this value
                        let plcData = PlcDataAccessQueue[offset]        // PLCDataAccessEntry
                        
                        let comRef = UInt(plcData.comRef)
                        let number = plcData.number
                        
                        switch plcData.type {
                        case .IntegerRegister:
                            
                            if data.count >= 26 {       // for readVariable
                                var inValue: UInt = 0

                                if data[20] == 0x20 {       // return PCOM-ReadRegister
                                    let datatype = data[21]     // read type of returnvalue
                                    
                                    inValue = (UInt(data[22]) * 256*256*256) + (UInt(data[23]) * 256*256) + (UInt(data[24]) * 256) + UInt(data[25])
                                }
                                
                                if (plcData.delegate != nil) {
                                    //print("Call individual delegate for Read.IntegerRegister")
                                    plcData.delegate?.didReceiveReadIntRegister(UInt(number), with: Int(inValue), tag: comRef)
                                } else {
                                    //print("Call standard delegate in Jet32 for Read.IntegerRegister")

                                    // TODO: call individual Handler defined in Protocol
                                    delegate?.didReceiveReadIntRegister(UInt(number), with: Int(inValue), tag: comRef)
                                }
                            } else {
                                print("wrong Datalength for Read.IntegerRegister")
                            }
                            
                        
                        case .Flag:
                            
                            if data.count >= 21 {
                                // status oder Merker, Ausgangsrückmeldung
                                if data[20] == 0x20 {       // Flag is 0
//                                    print("didReceive ReadFlag reset \(data[20]) with tag: \(comRef)")
                                        
                                    // call individual Handler defined in Protocol
                                    delegate?.didReceiveReadFlag(UInt(number), with: false, tag: comRef)
                                }
                                else if data[20] == 0x21 {  // Flag is 1
//                                    print("didReceive ReadFlag set \(data[20]) with tag: \(comRef)")
                                        
                                    // call individual Handler defined in Protocol
                                    delegate?.didReceiveReadFlag(UInt(number), with: true, tag: comRef)
                                }
                                else {
                                     print("Warning: didReceive ReadFlag Status \(data[20]) with tag: \(comRef)")
                                }
                            } else {
                                print("Error: wrong Datalength for Read.Flag")
                            }
                        
                            
                        default:
                            print("Warning: Datatype \(plcData.type) not supported!")
                        }
                        
                        /*
                        enum DataType {
                            case IntegerRegister, Flag, Input, Output, FloatRegister, String
                        }
                        enum Command {
                            case read, write, clear, set
                        }
                       */
                        
                        PlcDataAccessQueue.remove(at: offset)
                    } else {
                        print("Warning: can not find PLCDataAccessEntry in PLCDataAccessQueue with telegramID: \(telegramID)")
                    }
                }
                else {
                    print("Warning: didReceive Status \(data[20]) with telegramID: \(telegramID)")
                }
                return

            } else {
                print("Warning: didRecieve other protocol from Socket: \(data.hexEncodedString())")
            }
            
        } else {
            print("Warning: didRecieve other protocol from Socket: \(data.hexEncodedString())")
        }
        
        
//        print("Received Data from Socket: \(data.hexEncodedString()) from \(address.hexEncodedString())")
    }
    
    
    
    
    
    func udpSocket(_ sock: GCDAsyncUdpSocket, didConnectToAddress address: Data) {
        if let host = GCDAsyncUdpSocket.host(fromAddress: address) {
            print("Connected to host: \(host)")
        }
    }
 
    // this method isn't called. Why?
    func onSocket(sock: GCDAsyncUdpSocket!, didConnectToHost host: String!, port: UInt16) {
        print("successfully connected to \(host!) on Port \(port)")
    }

    func udpSocket(_ sock: GCDAsyncUdpSocket, didNotConnect error: Error?) {
        print("didNotConnect \(String(describing: error?.localizedDescription))")
    }
    
    func udpSocket(_ sock: GCDAsyncUdpSocket, didSendDataWithTag tag: Int) {
        //print("didSendDataWithTag \(tag)")
    }

    func udpSocket(_ sock: GCDAsyncUdpSocket, didNotSendDataWithTag tag: Int, dueToError error: Error?) {
        print("didNotSendDataWithTag \(tag) \(String(describing: error?.localizedDescription))")
    }
    
}
