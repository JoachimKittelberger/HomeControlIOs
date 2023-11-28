//
//  Jet32NW.swift
//  HomeControl
//
//  Created by Joachim Kittelberger on 10.04.19.
//  Copyright © 2019 Joachim Kittelberger. All rights reserved.
//

import Foundation
import Network


//class Jet32 : NSObject, GCDAsyncUdpSocketDelegate {
class Jet32NW : NSObject {

    // singleton Zugriff ueber Jet32.sharedInstance
    static let sharedInstance = Jet32NW()
    
    // private initializer for singleton
    private override init() {
        super.init()
    }
    
    deinit {
        disconnect()
        print("Jet32NW.deinit called")
    }
    
    
    private var delegate: PlcDataAccessibleDelegate?
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
    
    var inConnection: NWConnection?
    var outConnection: NWConnection?
    var inConnection1: NWListener?
    
//    var inSocket: GCDAsyncUdpSocket?
//    var outSocket: GCDAsyncUdpSocket?
    
    var timeout: TimeInterval = 2   // Default Timeout: 2s
    var isConnected : Bool = false     // TODO: mit Timeout-Überprüfung
    
    // TODO communication with Queue
    var PlcDataAccessQueue = [PlcDataAccessEntry]()
    
    
    
/*
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
    
 */
    
    // TODO Jet32 Dies ist eine neue Funktion
    func setupReceive(on connection: NWConnection) {
        connection.receive(minimumIncompleteLength: 1, maximumLength: 65536) { (data, contentContext, isComplete, error) in
            if let data = data, !data.isEmpty {
                // … process the data …
//                self.status = "did receive \(data.count) bytes"
            }
            if isComplete {
                // … handle end of stream …
//                self.stop(status: "EOF")
            } else if let error = error {
                // … handle error …
//                self.connectionDidFail(error: error)
            } else {
                self.setupReceive(on: connection)
            }
        }
    }
    
    
    
    
    // TODO: implement
    func connect() {

/*
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
 */
        // incoming socket
        if inConnection == nil {
            
            inConnection = NWConnection(host: NWEndpoint.Host.name(host, nil), port: NWEndpoint.Port(rawValue: udpPortReceive)!, using: .udp)
            inConnection?.stateUpdateHandler = self.stateDidChange(to:)
            inConnection?.start(queue: .global())
        }
    }
    
        func stateDidChange(to state: NWConnection.State) {
            switch state {
            case .setup:
                break
            case .waiting(let error):
//                self.connectionDidFail(error: error)
                break
            case .preparing:
                break
            case .ready:
//                self.status = "Connected"
                break
            case .failed(let error):
//                self.connectionDidFail(error: error)
                break
            case .cancelled:
                break
             default:
                print("ERROR! State not defined!\n")
                
            }
        }
    
    func disconnect() {
/*
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
*/
        
        // incoming connection
        if inConnection != nil {
            inConnection?.forceCancel()
        }
        inConnection = nil;
        
        
        // TODO finalize the queues
        clearPlcDataAccessQueue()
        
        
        
    }
    
    
    func clearPlcDataAccessQueue() {
        print("PlcDataAccessQueue.count ≠\(PlcDataAccessQueue.count)")
        PlcDataAccessQueue.removeAll()         // TODO hier sollte sicher sein, dass nicht noch ein Element verwendet wird.
        
    }
    
    
    
    func send(message: String){
        let data = message.data(using: String.Encoding.utf8)
        outConnection?.send(content: data, completion: NWConnection.SendCompletion.contentProcessed(({ (NWError) in
            print(NWError)
        })))
        /*        outSocket?.send(data!, withTimeout: timeout, tag: 0)
 */
    }
    
    
    func setOutput(_ number: Int) {
        let Jet32Data = Jet32DataTelegram(receivePort: UInt32(udpPortReceive), command: Jet32Command.setOutput, number: UInt32(number))
/*        outSocket?.send(Jet32Data.getData() as Data, withTimeout: timeout, tag:0)
*/
        print("setOutput \(number)")
        // TODO: udpsocket ReceiveWithTimeOut?????
    }
    
    
    func clearOutput(_ number: Int) {
        let Jet32Data = Jet32DataTelegram(receivePort: UInt32(udpPortReceive), command: Jet32Command.clearOutput, number: UInt32(number))

/*        outSocket?.send(Jet32Data.getData() as Data, withTimeout: timeout, tag:0)
*/
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
/*        outSocket?.send(Jet32Data.getData() as Data, withTimeout: timeout, tag:0)
*/
        print("setFlag \(number)")
        // TODO: udpsocket ReceiveWithTimeOut?????
    }
    
    func resetFlag(_ number: Int) {
        let Jet32Data = Jet32DataTelegram(receivePort: UInt32(udpPortReceive), command: Jet32Command.resetFlag, number: UInt32(number))
/*        outSocket?.send(Jet32Data.getData() as Data, withTimeout: timeout, tag:0)
*/
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
/*        outSocket?.send(Jet32Data.getData() as Data, withTimeout: timeout, tag:0)
*/
        //        print("writeIntRegister \(number) with \(value)")
        
        return true;
    }
    
}






/*
 // Code-Copy from forum
 
 
 import Network
 import Foundation
 import PlaygroundSupport
 
 class Main {
 
 init() {
 let connection = NWConnection(host: "sully.local.", port: 12345, using: .udp)
 self.connection = connection
 }
 
 let connection: NWConnection
 
 func start() {
 // Start the connection.
 connection.stateUpdateHandler = self.stateDidChange(to:)
 connection.start(queue: .main)
 self.setupReceive(connection)
 // Start the send timer.
 let sendTimer = DispatchSource.makeTimerSource(queue: .main)
 sendTimer.setEventHandler(handler: self.send)
 sendTimer.schedule(deadline: .now(), repeating: 1.0)
 sendTimer.resume()
 self.sendTimer = sendTimer
 }
 
 var sendTimer: DispatchSourceTimer?
 
 func stateDidChange(to state: NWConnection.State) {
 switch state {
 case .setup:
 break
 case .waiting(let error):
 self.connectionDidFail(error: error)
 case .preparing:
 print("Preparing")
 case .ready:
 print("Connected")
 case .failed(let error):
 self.connectionDidFail(error: error)
 case .cancelled:
 break
 }
 }
 
 func send() {
 let messageID = UUID()
 self.connection.send(content: "\(messageID)\r\n".data(using: .utf8)!, completion: .contentProcessed({ sendError in
 if let error = sendError {
 self.connectionDidFail(error: error)
 } else {
 print("Did send, messageID: \(messageID)")
 }
 }))
 }
 
 func setupReceive(_ connection: NWConnection) {
 connection.receiveMessage { (data, _, isComplete, error) in
 if let data = data, !data.isEmpty {
 print("Did receive, size: \(data.count)")
 }
 if let error = error {
 self.connectionDidFail(error: error)
 return
 }
 self.setupReceive(connection)
 }
 }
 
 func connectionDidFail(error: Error) {
 print("Failed, error: \(error)")
 if connection.stateUpdateHandler != nil {
 self.connection.stateUpdateHandler = nil
 connection.cancel()
 }
 exit(0)
 }
 }
 
 PlaygroundPage.current.needsIndefiniteExecution = true
 let m = Main()
 m.start()
 
 */
