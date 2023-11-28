//
//  Jet32.swift
//  HomeControl
//
//  Created by Joachim Kittelberger on 08.06.17.
//  Copyright © 2017 Joachim Kittelberger. All rights reserved.
//

import Foundation



class Jet32 : NSObject, GCDAsyncUdpSocketDelegate {

    // singleton Zugriff ueber Jet32.sharedInstance
    static let sharedInstance = Jet32()
    
    // private initializer for singleton
    private override init() {
        super.init()
    }
    
    deinit {
        disconnect()
        print("Jet32.deinit called")
    }
    
    
    private var delegate:PlcDataAccessibleDelegate?
    func setDelegate(delegate: PlcDataAccessibleDelegate?) {
        self.delegate = delegate
        
        // wenn sich niemand mehr dafür interessiert, darf die queue gelöscht werden
        if (delegate == nil) {
            clearPlcDataAccessQueue()
        }
        
        print("PlcDataAccessibleDelegate.setDelegate \(String(describing: delegate))")
    }
    
    
    
    var udpPortSend: UInt16 = 0
    var udpPortReceive: UInt16 = 0
    var host = "127.0.0.1"
    var timeoutJet32 : UInt16 = 2000     // TODO: Default Jet32 Timeout 2 s

    var inSocket: GCDAsyncUdpSocket?
    var outSocket: GCDAsyncUdpSocket?

    var timeout: TimeInterval = 2   // Default Timeout: 2s
    var isConnected : Bool = false     // TODO: mit Timeout-Überprüfung
    
    // TODO communication with Queue
    var PlcDataAccessQueue = [PlcDataAccessEntry]()
    
    
    
    func onSocket(sock: GCDAsyncUdpSocket!, didConnectToHost host: String!, port: UInt16) {
        print("successfully connected to \(host!) on Port \(port)")
    }
    
    
    
    func udpSocket(_ sock: GCDAsyncUdpSocket, didReceive data: Data, fromAddress address: Data, withFilterContext filterContext: Any?) {

        // Check Header
        if (data.count >= 20) {         // check minimum data length required
            if data[0] == 0x4A && data[1] == 0x57 && data[2] == 0x49 && data[3] == 0x50 {

                // read communication-Reference
                var comRef = (UInt(data[8]) * 256*256*256) + (UInt(data[9]) * 256*256) + (UInt(data[10]) * 256) + UInt(data[11])
                var inValue: UInt = 0
                
                
                // TODO: anhand ComRef die eigentliche Referenz herausfinden und den WErt zurückgeben
                if comRef != 0 {

                    let telegramID = UInt32(comRef)
                    
                    if let offset = PlcDataAccessQueue.firstIndex(where: { $0.telegramID == telegramID }) {
                        
                        let originalComRef = UInt(PlcDataAccessQueue[offset].comRef)
                        
                        comRef = originalComRef
                        
                        let type = PlcDataAccessQueue[offset].type
                        let cmd = PlcDataAccessQueue[offset].cmd
                        let number = PlcDataAccessQueue[offset].number
                        
                        switch type {
                        case .IntegerRegister:
                            
                            if data.count >= 26 {       // for readVariable
                                if data[20] == 0x20 {       // return PCOM-ReadRegister
                                    let datatype = data[21]     // read type of returnvalue
                                    
                                    inValue = (UInt(data[22]) * 256*256*256) + (UInt(data[23]) * 256*256) + (UInt(data[24]) * 256) + UInt(data[25])
                                }
                                
                                // call individual Handler defined in Protocol
                                delegate?.didRedeiveReadIntRegister(UInt(number), with: Int(inValue), tag: comRef)
                            } else {
                                print("wrong Datalength for Read.IntegerRegister")
                            }
                            
                        
                        case .Flag:
                            
                            if data.count >= 21 {
                                // status oder Merker, Ausgangsrückmeldung
                                if data[20] == 0x20 {       // Flag is 0
//                                    print("didReceive ReadFlag reset \(data[20]) with tag: \(comRef)")
                                        
                                    // call individual Handler defined in Protocol
                                    delegate?.didRedeiveReadFlag(UInt(number), with: false, tag: comRef)
                                }
                                else if data[20] == 0x21 {  // Flag is 1
//                                    print("didReceive ReadFlag set \(data[20]) with tag: \(comRef)")
                                        
                                    // call individual Handler defined in Protocol
                                    delegate?.didRedeiveReadFlag(UInt(number), with: true, tag: comRef)
                                }
                                else {
                                     print("didReceive ReadFlag Status \(data[20]) with tag: \(comRef)")
                                }
                            } else {
                                print("wrong Datalength for Read.Flag")
                            }
                        
                            
                        default:
                            print("Datatype not supported!")
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
                    }
                }
                else {
                    print("didReceive Status \(data[20]) with tag: \(comRef)")
                }
                return

            } else {
                print("didRecieve other protocol from Socket: \(data.hexEncodedString())")
            }
            
        } else {
            print("didRecieve other protocol from Socket: \(data.hexEncodedString())")
        }
        
        
//        print("Received Data from Socket: \(data.hexEncodedString()) from \(address.hexEncodedString())")
    }
    
    
    
    
    
    func udpSocket(_ sock: GCDAsyncUdpSocket, didConnectToAddress address: Data) {
/*        guard let stringData = String(data: address, encoding: String.Encoding.ascii) else {
            print(">>> Data received, but cannot be converted to String")
            return
        }
        
        print("didConnectToAddress \(stringData)");
*/
        print("didConnectToAddress \(address.hexEncodedString())");
    }
 

    
    
    
    
    
    func udpSocket(_ sock: GCDAsyncUdpSocket, didNotConnect error: Error?) {
        print("didNotConnect \(String(describing: error?.localizedDescription))")
    }
    
    func udpSocket(_ sock: GCDAsyncUdpSocket, didSendDataWithTag tag: Int) {
//        print("didSendDataWithTag \(tag)")
    }

    func udpSocket(_ sock: GCDAsyncUdpSocket, didNotSendDataWithTag tag: Int, dueToError error: Error?) {
        print("didNotSendDataWithTag \(tag) \(String(describing: error?.localizedDescription))")
    }
    
    
    
    
    // TODO: implement
    func connect() {
        
        // incoming socket
        if inSocket == nil {
            inSocket = GCDAsyncUdpSocket(delegate: self, delegateQueue: DispatchQueue.main)

            do {
                try inSocket?.bind(toPort: udpPortReceive)
                try inSocket?.beginReceiving()
            } catch let error {
                print(error.localizedDescription)
                inSocket?.close()
                return
            }
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
    
    
    
    func send(message: String){
        let data = message.data(using: String.Encoding.utf8)
        outSocket?.send(data!, withTimeout: timeout, tag: 0)
    }
    
    
    func setOutput(_ number: Int) {
        let Jet32Data = Jet32DataTelegram(receivePort: UInt32(udpPortReceive), command: Jet32Command.setOutput, number: UInt32(number))
        outSocket?.send(Jet32Data.getData() as Data, withTimeout: timeout, tag:0)
        print("setOutput \(number)")
        // TODO: udpsocket ReceiveWithTimeOut?????
    }
    
    
    func clearOutput(_ number: Int) {
        let Jet32Data = Jet32DataTelegram(receivePort: UInt32(udpPortReceive), command: Jet32Command.clearOutput, number: UInt32(number))
        outSocket?.send(Jet32Data.getData() as Data, withTimeout: timeout, tag:0)
        print("clearOutput \(number)")
    }

    
    func readFlagOld(_ number: Int, tag: UInt32 = 0) {
//        let Jet32Data = Jet32DataTelegram(receivePort: UInt32(udpPortReceive), command: Jet32Command.readFlag, number: UInt32(number), tag: tag)
//        outSocket?.send(Jet32Data.getData() as Data, withTimeout: timeout, tag:0)

        //        print("readFlag \(number)")
        // TODO: udpsocket ReceiveWithTimeOut?????
        
        
        readFlag(UInt(number), tag: UInt(tag))
        
    }
  
    func setFlag(_ number: Int) {
        let Jet32Data = Jet32DataTelegram(receivePort: UInt32(udpPortReceive), command: Jet32Command.setFlag, number: UInt32(number))
        outSocket?.send(Jet32Data.getData() as Data, withTimeout: timeout, tag:0)
        print("setFlag \(number)")
        // TODO: udpsocket ReceiveWithTimeOut?????
    }

    func resetFlag(_ number: Int) {
        let Jet32Data = Jet32DataTelegram(receivePort: UInt32(udpPortReceive), command: Jet32Command.resetFlag, number: UInt32(number))
        outSocket?.send(Jet32Data.getData() as Data, withTimeout: timeout, tag:0)
        print("resetFlag \(number)")
        // TODO: udpsocket ReceiveWithTimeOut?????
    }
    
    
    
    func readIntReg(_ number: Int, tag: UInt32 = 0) -> Int {
//        let Jet32Data = Jet32DataTelegram(receivePort: UInt32(udpPortReceive), command: Jet32Command.readVariable, number: UInt32(number), tag: tag)
//        outSocket?.send(Jet32Data.getData() as Data, withTimeout: timeout, tag:0)

        // TODO: return the wright value
        
        
        
        // read with queue
        readIntRegister(UInt(number), tag: UInt(tag))
        
        
        return 0;
    }

    
    
    
    
    func readIntRegSync(_ number: Int, tag: UInt32 = 0) -> Int {
        
        // read with queue
        return readIntRegisterSync(UInt(number), tag: UInt(tag))
    }
    
    
    
    
    
    func writeIntRegister(_ number: Int, to value: Int) -> Bool {
//        let Jet32Data = Jet32DataTelegram(receivePort: UInt32(udpPortReceive), command: Jet32Command.writeIntRegister, number: UInt32(number), value: UInt32(value))
        let Jet32Data = Jet32DataTelegram(receivePort: UInt32(udpPortReceive), command: Jet32Command.writeVariable, number: UInt32(number), value: UInt32(value))
        outSocket?.send(Jet32Data.getData() as Data, withTimeout: timeout, tag:0)
//        print("writeIntRegister \(number) with \(value)")
        
        return true;
    }
    
}


