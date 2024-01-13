//
//  Connectivity.swift
//  HomeControl
//
//  Created by Joachim Kittelberger on 05.01.24.
//  Copyright © 2024 Joachim Kittelberger. All rights reserved.
//

import Foundation
import WatchConnectivity



// TODO: Später wieder in separate Datei auslagern
enum MessageType: String {
    //case purchased
    //case qrCodes
    //case verified
    case unknown
    case readRegister
    case getFlag
    case writeRegister
    case setFlag
}








final class Connectivity: NSObject, ObservableObject {

    // Platzhalter für received Data from peer
    @Published var receivedNumbers: [Int] = []



    static let sharedInstance = Connectivity()          // use static access to singleton
    
    // use private initializer, so class is only accessible via sharedInstance
    override private init() {
        super.init()
#if !os(watchOS)
        // Apple Watch will always support WCSession. iPhone only if there is an paired Apple Watch
        guard WCSession.isSupported() else {
            return
        }
#endif
        WCSession.default.delegate = self
        WCSession.default.activate()        // let us talk to paired device
    }
    
    
    
    private func canSendToPeer() -> Bool {
        guard WCSession.default.activationState == .activated else {
            return false
        }
      
        // check, if peer Device is there
#if os(watchOS)
        guard WCSession.default.isCompanionAppInstalled else {
            return false
        }
#else
        guard WCSession.default.isWatchAppInstalled else {
            return false
        }
#endif
        return true
    }
    

    
    
    
    
    
    // send Message with dictionary Data
    public func sendMessage(_ message: [String : Any], replyHandler: (([String: Any]) -> Void)? = nil, errorHandler: ((Error) -> Void)? = nil) {

        guard canSendToPeer() else { return }
       
        print("sendMessage to peer")
        //WCSession.default.sendMessage(message, replyHandler: nil)

        WCSession.default.sendMessage(message,
            replyHandler: optionalMainQueueDispatch(handler: replyHandler),
            errorHandler: optionalMainQueueDispatch(handler: errorHandler)
            )
    }

    
    
    
    
    //public func send(movieIds: [Int], delivery: Delivery, wantedQrCodes: [Int]? = nil, replyHandler: (([String: Any]) -> Void)? = nil, errorHandler: ((Error) -> Void)? = nil) {
    public func send(regNumber: Int, delivery: Delivery, replyHandler: (([String: Any]) -> Void)? = nil, errorHandler: ((Error) -> Void)? = nil) {
        
        guard canSendToPeer() else { return }
        
        let message: [String: Int] = [
            //MessageType.purchased.rawValue: movieIds
            MessageType.readRegister.rawValue: regNumber
        ]
        
        //if let wantedQrCodes {
        //    let key = MessageType.qrCodes.rawValue
        //    message[key] = wantedQrCodes
        //}
        
        switch delivery {
        case .failable:
            WCSession.default.sendMessage(message,
                replyHandler: optionalMainQueueDispatch(handler: replyHandler),
                errorHandler: optionalMainQueueDispatch(handler: errorHandler)
            )
            
        case .guaranteed:
            WCSession.default.transferUserInfo(message)
            // we will receive the data in session(_:didiReceiveUserInfo:)
            
        case .highPriority:
            do {
                try WCSession.default.updateApplicationContext(message)
            } catch {
                errorHandler?(error)
            }
        }
    }
    
    
    // send Data-object
    public func send(data: Data, replyHandler: ((Data) -> Void)? = nil, errorHandler: ((Error) -> Void)? = nil) {
        guard canSendToPeer() else { return }
        
        WCSession.default.sendMessageData(data,
            replyHandler: optionalMainQueueDispatch(handler: replyHandler),
            errorHandler: optionalMainQueueDispatch(handler: errorHandler)
        )
    }
    
  
    
    // this fuction will be called from the WCSessionDelegate.session callbacks
    private func update(from dictionary: [String: Any]) {
        //print("update data \(dictionary)")

#if os(iOS)
        // prüfen auf key setFlag
        // auslesen der Nummer
        // das Flag dann setzen
        
        var msgType = MessageType.unknown
        var number = UInt(0)
        var value = Int(0)
        var tag = UInt(0)
        
        
        /*
                "type": String(MessageType.readRegister.rawValue),
                "number": String(number),
                "value": String(0),
                "tag": String(tag)
     */

        for (key, val) in dictionary {
            //print("\(key) -> \(val)")
            
            if (key == "type") {
                msgType = MessageType(rawValue: (val as? String ?? MessageType.unknown.rawValue))!
            }
            if (key == "number") {
                //number = Int(val) ?? 0
                number = UInt((val as AnyObject).integerValue)
            }
            if (key == "value") {
                value = (val as AnyObject).integerValue
            }
            if (key == "tag") {
                tag = UInt((val as AnyObject).integerValue)
            }
        }

        print("\(msgType.rawValue): (number: \(number), value: \(value), tag: \(tag))")
        switch msgType {
        case .unknown:
            print("Error: msgType \(msgType.rawValue) foundd")

        case .readRegister:
            print("Error: msgType \(msgType.rawValue) not implemented")
            let homeControlConnection = PlcComMgr.sharedInstance
            homeControlConnection.connect()
            let _ = homeControlConnection.readIntRegister(number, tag: tag)
            //homeControlConnection.setDelegate(delegate: nil)

        case .getFlag:
            print("Error: msgType \(msgType.rawValue) not implemented")
            let homeControlConnection = PlcComMgr.sharedInstance
            homeControlConnection.connect()
            let _ = homeControlConnection.readFlag(number, tag: tag)
            //homeControlConnection.setDelegate(delegate: nil)

        case .writeRegister:
            let homeControlConnection = PlcComMgr.sharedInstance
            homeControlConnection.connect()
            let _ = homeControlConnection.writeIntRegister(number, to: value, tag: tag)
            //homeControlConnection.setDelegate(delegate: nil)

        case .setFlag:
            let homeControlConnection = PlcComMgr.sharedInstance
            homeControlConnection.connect()
            if (value > 0) {
                let _ = homeControlConnection.setFlag(number, tag: tag)
                //print("setFlag \(number)")
            } else {
                let _ = homeControlConnection.clearFlag(number, tag: tag)
                //print("resetFlag \(number)")
            }
            //homeControlConnection.setDelegate(delegate: nil)
        }
    
 
#endif




/*
#if os(iOS)
        //sendQrCodes(dictionary)
#endif
        let key = MessageType.readRegister.rawValue
        guard let ids = dictionary[key] as? [Int] else {
            return
        }
        
        self.receivedNumbers = ids
 */
    }
    
    
    
    
    // sorgt dafür, dass Ergebnis in der Main queue ausgeführt wird
    typealias OptionalHandler<T> = ((T) -> Void)?
    private func optionalMainQueueDispatch<T>(handler: OptionalHandler<T>) -> OptionalHandler<T> {
        guard let handler = handler else {
            return nil
        }
        
        return { item in
            Task { @MainActor in
                handler(item)
            }
        }
    }
    
    
    
    
/*
#if os(iOS)
  public func sendQrCodes(_ data: [String: Any]) {
    // 1
    let key = MessageType.qrCodes.rawValue
    guard let ids = data[key] as? [Int], !ids.isEmpty else { return }
    
    let tempDir = FileManager.default.temporaryDirectory
    
    // 2
    TicketOffice.shared
      .movies
      .filter { ids.contains($0.id) }
      .forEach { movie in
        // 3
        let image = QRCode.generate(
          movie: movie,
          size: .init(width: 100, height: 100)
        )
        
        // 4
        guard let data = image?.pngData() else { return }
        
        // 5
        let url = tempDir.appendingPathComponent(UUID().uuidString)
        guard let _ = try? data.write(to: url) else {
          return
        }
        
        // 6
        WCSession.default.transferFile(url, metadata: [key: movie.id])
      }
  }
#endif
*/
    
    
    
    
    
    
}






// MARK: - WCSessionDelegate
extension Connectivity: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
    }
    
#if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("\(#file) " + String(describing: type(of: self)) + ".\(#function)[\(#line)]: called")
    }
  
    func sessionDidDeactivate(_ session: WCSession) {
        print("\(#file) " + String(describing: type(of: self)) + ".\(#function)[\(#line)]: called")
        // If the person has more than one watch, and they switch,
        // reactivate their session on the new device.
        WCSession.default.activate()
    }
#endif

    
    
    
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        print("\(#file) " + String(describing: type(of: self)) + ".\(#function)[\(#line)]: called")
        update(from: applicationContext)
    }
    
    
    // when transfering vie transferUserInfo(_:), you receive it via this function
    func session(_ session: WCSession, didReceiveUserInfo message: [String: Any] = [:]) {
        print("\(#file) " + String(describing: type(of: self)) + ".\(#function)[\(#line)]: called")
        update(from: message)
    }
  

    // This method is called when a message is sent with failable priority *and* a reply was requested.
    func session(_ session: WCSession, didReceiveMessage message: [String: Any], replyHandler: @escaping ([String: Any]) -> Void) {
        print("\(#file) " + String(describing: type(of: self)) + ".\(#function)[\(#line)]: called")
        update(from: message)

// TODO: hier Einsprungpunkt bei Funktionen, die einen Replyhandler angefordert haben
        
        
/*
#if os(iOS)
        //let key = MessageType.verified.rawValue
        //replyHandler([key: true])
        let homeControlConnection = PlcComMgr.sharedInstance
        homeControlConnection.connect()

        
        // TODO: hier selber setzten und mit await warten???????
        //homeControlConnection.setDelegate(delegate: self)
        let seconds = homeControlConnection.readIntRegisterSync(UInt(Jet32GlobalVariables.regSecond), tag: UInt(HomeControlControllerTag.readSecond.rawValue))

        let replyMsg = ["Seconds": seconds]
        replyHandler(replyMsg)
#endif
  */
        
    }
    
    // This method is called when a message is sent with failable priority and a reply was *not* requested.
    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        //print("\(#file) " + String(describing: type(of: self)) + ".\(#function)[\(#line)]: called")
        update(from: message)
    }
    
    func session(_ session: WCSession, didReceiveMessageData messageData: Data) {
        print("\(#file) " + String(describing: type(of: self)) + ".\(#function)[\(#line)]: called")
    }
    
    func session(_ session: WCSession, didReceiveMessageData messageData: Data, replyHandler: @escaping (Data) -> Void) {
        print("\(#file) " + String(describing: type(of: self)) + ".\(#function)[\(#line)]: called")
    }
   
#if os(watchOS)
    func session(_ session: WCSession, didReceive file: WCSessionFile) {
        print("\(#file) " + String(describing: type(of: self)) + ".\(#function)[\(#line)]: called")
/*
        let key = MessageType.qrCodes.rawValue
        guard let id = file.metadata?[key] as? Int else {
            return
        }
        
        let destination = QRCode.url(for: id)
        
        try? FileManager.default.removeItem(at: destination)
        try? FileManager.default.moveItem(at: file.fileURL, to: destination)
 */
    }
#endif
    
    
    
    
    
}
