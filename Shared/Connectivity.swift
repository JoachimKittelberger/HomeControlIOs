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
    case unknown
    case readRegister       // request from iWatch to iPhone
    case getFlag            // request from iWatch to iPhone
    case writeRegister      // request from iWatch to iPhone
    case setFlag            // request from iWatch to iPhone
    
    case responseReadRegister           // response from iPhone to iWatch
    case responseReadFlag           // response from iPhone to iWatch
}




// TODO: this is just for example code below
enum Delivery {
  /// Deliver immediately. No retries on failure.
  case failable

  /// Deliver as soon as possible. Automatically retries on failure.
  /// All instances of the data will be transferred sequentially.
  case guaranteed

  /// High priority data like app settings. Only the most recent value is
  /// used. Any transfers of this type not yet delivered will be replaced
  /// with the new one.
  case highPriority
}



final class Connectivity: NSObject, ObservableObject {

    // use this class as singleton object
    static let shared = Connectivity()          // use static access to singleton
    
    // use private initializer, so class is only accessible via shared
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
    // send interactive message. iPhone-App will wake in background.
    // if iPhone sends to iWatch and watch-App isn't active, watchOS App will NOT wake up
    public func sendMessage(_ message: [String : Any], replyHandler: (([String: Any]) -> Void)? = nil, errorHandler: ((Error) -> Void)? = nil) {
        
        guard canSendToPeer() else { return }
        
        //print("sendMessage to peer")
        WCSession.default.sendMessage(message,
                                      replyHandler: optionalMainQueueDispatch(handler: replyHandler),
                                      errorHandler: optionalMainQueueDispatch(handler: errorHandler)
        )
    }

    
    
    
    // TODO: for Test of different Message tyoes
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
        
        // interactive messaging. Information is transferred immediately
        // no retries on failure
        case .failable:
            WCSession.default.sendMessage(message,
                replyHandler: optionalMainQueueDispatch(handler: replyHandler),
                errorHandler: optionalMainQueueDispatch(handler: errorHandler)
            )
        
            
        // Background transfer. Let iOS and watchOS choose a good time to transfer data between apps
        // based on characteristics such as battery use and how much other data iw waiting to tranfer
        // data is critical an must be delivered as soon as possible
        // automatically retries on failure
        // all instances of the data will be transfered sequentially
        // kommt dann in session(.didReceiveUserInfo) raus
        case .guaranteed:
            WCSession.default.transferUserInfo(message)
            // we will receive the data in session(_:didiReceiveUserInfo:)
        
            
        // Background transfer. Let iOS and watchOS choose a good time to transfer data between apps
        // based on characteristics such as battery use and how much other data iw waiting to tranfer
        // OS sends this data, when it feels it's appropriate to send it
        // It only sends the most recent message. Any transfer of this type not yet delivered will be
        // replaced with the new one
        // If data updates frequently and you only need the most recent data -> use updateApplicationContext
        // kommt dann in session(.didReceiveApplicationContext) raus
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
    


    // Background transfer. Let iOS and watchOS choose a good time to transfer data between apps
    // based on characteristics such as battery use and how much other data iw waiting to tranfer
    // transferFile to paired device
//    public func transferFile(_ file: URL, metadata: [String : Any]?) {
    public func send(_ file: URL, metadata: [String : Any]? = nil) {
        guard canSendToPeer() else { return }

        //let metadata: [String: Int] = [
        //    "key": 4711
        //]
        //WCSession.default.transferFile(file, metadata: nil)
        WCSession.default.transferFile(file, metadata: metadata)
    }
    
 
    
  
    // value from sync read of Jet32 Read call
    var receivedReadIntValue: Int?
    var responseReadIntSemaphore: DispatchSemaphore?
    var receivedReadBoolValue: Int?
    var responseReadBoolSemaphore: DispatchSemaphore?

    
    // this fuction will be called from the WCSessionDelegate.session callbacks
    // serialize and synchronize the Jet32-Calls
    private func update(from message: [String: Any]) {
        //print("update data \(message)")

#if os(iOS)
        var msgType = MessageType.unknown
        var number = UInt(0)
        var value = Int(0)
        var tag = UInt(0)
 
 /*
        // read values from message dictionary
        // alternative Möglichkeit, um den Message type zu ermitteln
        if let val = message["type"] as? String {
            msgType = MessageType(rawValue: (val))!
            
            if let retVal = message["value"] as? String {
                value = (retVal as AnyObject).integerValue
            }
            if let retVal = message["number"] as? String {
                number = UInt((retVal as AnyObject).integerValue)
            }
            if let retVal = message["tag"] as? String {
                tag = UInt((retVal as AnyObject).integerValue)
            }
        }
   */
        
        // read values from message dictionary
        // TODO: could also be done with JSON instead of dictionary
        for (key, val) in message {
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
            print("Error: msgType \(msgType.rawValue) found!")

        case .readRegister:
            let homeControlConnection = PLCComMgr.shared
            homeControlConnection.connect()

            // sync call and get return value
            responseReadIntSemaphore = DispatchSemaphore(value: 0)
            receivedReadIntValue = nil
            let _ = homeControlConnection.readIntRegister(number, tag: tag, delegate: self)
            
            // hier auf Ergebnis des Lesens warten
            // Wait for the response with a timeout
            let timeoutResult = responseReadIntSemaphore?.wait(timeout: DispatchTime.now() + DispatchTimeInterval.seconds(4))

            if timeoutResult == .success, let response = receivedReadIntValue {
                // Rückgabewert wird in der Callback didReceiveReadIntRegister gesetzt.
                // hier wird nur gewartet und dann in der aufrufenden Funktion das Ergebnis weiter verarbeitet
                // TODO: könnte auch alles in der aufrufenden Funktion gemacht werden, oder der Funktion update das Session-Objekt noch mit übergeben
                //print(String(describing: type(of: self)) + ".\(#function)[\(#line)]: Response: \(response)")
            } else {
                print("Error Reading SyncReg for Response");
            }
            //homeControlConnection.setDelegate(delegate: nil)

        case .getFlag:
            let homeControlConnection = PLCComMgr.shared
            homeControlConnection.connect()
            
            // sync call and get return value
            responseReadBoolSemaphore = DispatchSemaphore(value: 0)
            receivedReadBoolValue = nil
            let _ = homeControlConnection.readFlag(number, tag: tag, delegate: self)
            
            // hier auf Ergebnis des Lesens warten
            // Wait for the response with a timeout
            let timeoutResult = responseReadBoolSemaphore?.wait(timeout: DispatchTime.now() + DispatchTimeInterval.seconds(4))

            if timeoutResult == .success, let response = receivedReadBoolValue {
                // Rückgabewert wird in der Callback didReceiveReadIntRegister gesetzt.
                // hier wird nur gewartet und dann in der aufrufenden Funktion das Ergebnis weiter verarbeitet
                // TODO: könnte auch alles in der aufrufenden Funktion gemacht werden, oder der Funktion update das Session-Objekt noch mit übergeben
                //print(String(describing: type(of: self)) + ".\(#function)[\(#line)]: Response: \(response)")
            } else {
                print("Error Reading SyncFlag for Response");
            }
            //homeControlConnection.setDelegate(delegate: nil)

        case .writeRegister:
            let homeControlConnection = PLCComMgr.shared
            homeControlConnection.connect()
            let _ = homeControlConnection.writeIntRegister(number, to: value, tag: tag)
            //homeControlConnection.setDelegate(delegate: nil)

        case .setFlag:
            let homeControlConnection = PLCComMgr.shared
            homeControlConnection.connect()
            if (value > 0) {
                let _ = homeControlConnection.setFlag(number, tag: tag)
            } else {
                let _ = homeControlConnection.clearFlag(number, tag: tag)
            }

        case .responseReadRegister:
            print("Error: msgType \(msgType.rawValue) not implemented")
        case .responseReadFlag:
            print("Error: msgType \(msgType.rawValue) not implemented")
        }

#endif

    }
    
    
    
    
    // sorgt dafür, dass Ergebnis in der Main queue ausgeführt wird
    // ohne optionalMainQueueDispatch muss folgendes dann in der empfangsroutine verwendet werden, damit auf Main-Thread ausgeführt wird
    // DispatchQueue.main.async { [self] in
    //  self.selectedItemModel.changeSelected(weather: userInfo["weather"] as? String ?? "❓")
    // }
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
    
}








// MARK: - WCSessionDelegate
extension Connectivity: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print(String(describing: type(of: self)) + ".\(#function)[\(#line)]: activationState: \(activationState) error: \(String(describing: error?.localizedDescription)) called")
    }
    
#if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {
        print(String(describing: type(of: self)) + ".\(#function)[\(#line)]: called")
    }
  
    func sessionDidDeactivate(_ session: WCSession) {
        print(String(describing: type(of: self)) + ".\(#function)[\(#line)]: called")
        // If the person has more than one watch, and they switch,
        // reactivate their session on the new device.
        WCSession.default.activate()
    }
#endif

    
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        print(String(describing: type(of: self)) + ".\(#function)[\(#line)]: not implemented")
        update(from: applicationContext)
    }
    
    
    // when transfering vie transferUserInfo(_:), you receive it via this function
    func session(_ session: WCSession, didReceiveUserInfo message: [String: Any] = [:]) {
        print(String(describing: type(of: self)) + ".\(#function)[\(#line)]: not implemented")
        update(from: message)
    }
  

    // This method is called when a message is sent with failable priority *and* a reply was requested.
    // wird aufgerufen, wenn mit einem Reply-Handler versehen ist
    func session(_ session: WCSession, didReceiveMessage message: [String: Any], replyHandler: @escaping ([String: Any]) -> Void) {
        //print(String(describing: type(of: self)) + ".\(#function)[\(#line)]: called")
        
    #if os(iOS)
        // we have an message from Apple Watch to iPhone with replyhandler
        update(from: message)       // read and wait for result of Jet32.readXXX


        // Send a response back to the Apple Watch
        var msgType = MessageType.unknown
        if let val = message["type"] as? String {
            msgType = MessageType(rawValue: (val))!
        }
        var number = UInt(0)
        var tag = UInt(0)
        if let retVal = message["number"] as? String {
            number = UInt((retVal as AnyObject).integerValue)
        }
        if let retVal = message["tag"] as? String {
            tag = UInt((retVal as AnyObject).integerValue)
        }

        
        switch msgType {
        case .unknown:
            print("Error: msgType \(msgType.rawValue) not implemented!")

        case .readRegister:
            //print("Info: msgType \(msgType.rawValue) called!")
            let responseMessage = [
                "type": String(MessageType.responseReadRegister.rawValue),
                "value": String(receivedReadIntValue ?? 0),
                "number": String(number),
                "tag": String(tag)
            ]
  /*
             // ends in Connectivity.session(_:didReceiveMessage:)
             session.sendMessage(responseMessage,
                    replyHandler: nil,
                    //errorHandler: nil)
                    errorHandler: { error in
                        print("Error sending response to Apple Watch: \(error.localizedDescription)")
                    })
    */
            // Send response back via ReplyHanlder
            replyHandler(responseMessage)


        case .getFlag:
            //print("Info: msgType \(msgType.rawValue) called!")
            let responseMessage = [
                "type": String(MessageType.responseReadFlag.rawValue),
                "value": String(receivedReadBoolValue ?? 0),
                "number": String(number),
                "tag": String(tag)
            ]
            /*
             // ends in Connectivity.session(_:didReceiveMessage:)
             session.sendMessage(responseMessage,
                    replyHandler: nil,
                    //errorHandler: nil)
                    errorHandler: { error in
                        print("Error sending response to Apple Watch: \(error.localizedDescription)")
                    })
              */
            // Send response back via ReplyHanlder
            replyHandler(responseMessage)

        case .writeRegister:
            print("Error: msgType \(msgType.rawValue) not implemented!")

        case .setFlag:
            print("Error: msgType \(msgType.rawValue) not implemented!")

        case .responseReadRegister:
            print("Error: msgType \(msgType.rawValue) not implemented!")
        case .responseReadFlag:
            print("Error: msgType \(msgType.rawValue) not implemented!")
        }
        
    #endif

    }
 
    
    
    // This method is called when a message is sent with failable priority and a reply was *not* requested.
    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        print(String(describing: type(of: self)) + ".\(#function)[\(#line)]: called")
        
        
        // test, if we have a message from iPhone to Apple Watch. Wird nicht bei Verwendung des Reply-Handlers aufgerufen
    #if os(watchOS)
        if let val = message["type"] as? String {

            var number = UInt(0)
            var value = Int(0)
            var tag = UInt(0)

            if let retVal = message["value"] as? String {
                value = (retVal as AnyObject).integerValue
            }
            if let retVal = message["number"] as? String {
                number = UInt((retVal as AnyObject).integerValue)
            }
            if let retVal = message["tag"] as? String {
                tag = UInt((retVal as AnyObject).integerValue)
            }

            let msgType = MessageType(rawValue: (val))!
            switch msgType {
            case .unknown:
                print("Error: msgType \(msgType.rawValue) not implemented!")

            case .readRegister:
                print("Error: msgType \(msgType.rawValue) not implemented!")

            case .getFlag:
                print("Error: msgType \(msgType.rawValue) not implemented!")

            case .writeRegister:
                print("Error: msgType \(msgType.rawValue) not implemented!")

            case .setFlag:
                print("Error: msgType \(msgType.rawValue) not implemented!")

            case .responseReadRegister:
                //print("ResponsefromiPhone: msgType \(msgType.rawValue) number: \(number) value: \(value) tag: \(tag)")

                // sende das Ergebnis über dsa Delegate der homeControlConnection
                let homeControlConnection = PLCComMgr.shared
                homeControlConnection.getDelegate()?.didReceiveReadIntRegister(number, with: value, tag: tag);

            case .responseReadFlag:
                //print("ResponsefromiPhone: msgType \(msgType.rawValue) number: \(number) value: \(value) tag: \(tag)")

                // sende das Ergebnis über dsa Delegate der homeControlConnection
                let homeControlConnection = PLCComMgr.shared
                homeControlConnection.getDelegate()?.didReceiveReadFlag(number, with: value != 0 ? true : false, tag: tag);
            }
        }
    #endif
 
    #if os(iOS)
        // test, if we have a message from Watch to iPhone. Wird ohne Reply-Handler aufgerufen
        // we have an message from Apple Watch to iPhone
        update(from: message)       // wait and sychronize Jet32.ReadXXX Calls


        // Send a response back to the Apple Watch
        var msgType = MessageType.unknown
        if let val = message["type"] as? String {
            msgType = MessageType(rawValue: (val))!
        }
        var number = UInt(0)
        var tag = UInt(0)
        if let retVal = message["number"] as? String {
            number = UInt((retVal as AnyObject).integerValue)
        }
        if let retVal = message["tag"] as? String {
            tag = UInt((retVal as AnyObject).integerValue)
        }

        
        switch msgType {
        case .unknown:
            print("Error: msgType \(msgType.rawValue) not implemented!")

        case .readRegister:
            //print("Info: msgType \(msgType.rawValue) called!")
            let responseMessage = [
                "type": String(MessageType.responseReadRegister.rawValue),
                "value": String(receivedReadIntValue ?? 0),
                "number": String(number),
                "tag": String(tag)
            ]
            
             // ends in Connectivity.session(_:didReceiveMessage:)
             session.sendMessage(responseMessage,
                    replyHandler: nil,
                    //errorHandler: nil)
                    errorHandler: { error in
                        print("Error sending response to Apple Watch: \(error.localizedDescription)")
                    })
                
            // Send response back via ReplyHanlder
            //replyHandler(responseMessage)


        case .getFlag:
            //print("Info: msgType \(msgType.rawValue) called!")
            let responseMessage = [
                "type": String(MessageType.responseReadFlag.rawValue),
                "value": String(receivedReadBoolValue ?? 0),
                "number": String(number),
                "tag": String(tag)
            ]
            
             // ends in Connectivity.session(_:didReceiveMessage:)
             session.sendMessage(responseMessage,
                    replyHandler: nil,
                    //errorHandler: nil)
                    errorHandler: { error in
                        print("Error sending response to Apple Watch: \(error.localizedDescription)")
                    })
                
            // Send response back via ReplyHanlder
            //replyHandler(responseMessage)

        case .writeRegister:
            print("Error: msgType \(msgType.rawValue) not implemented!")

        case .setFlag:
            print("Error: msgType \(msgType.rawValue) not implemented!")

        case .responseReadRegister:
            print("Error: msgType \(msgType.rawValue) not implemented!")
        case .responseReadFlag:
            print("Error: msgType \(msgType.rawValue) not implemented!")
        }
#endif
        
        
    }
    
    func session(_ session: WCSession, didReceiveMessageData messageData: Data) {
        print(String(describing: type(of: self)) + ".\(#function)[\(#line)]: not implemented")
    }
    
    func session(_ session: WCSession, didReceiveMessageData messageData: Data, replyHandler: @escaping (Data) -> Void) {
        print(String(describing: type(of: self)) + ".\(#function)[\(#line)]: not implemented")
    }

    func session(_ session: WCSession, didReceive file: WCSessionFile) {
        print(String(describing: type(of: self)) + ".\(#function)[\(#line)]: notimplemented")
    }
    
}










// for response from iPhone
extension Connectivity: PLCDataAccessibleDelegate {

    func didReceiveReadIntRegister(_ number: UInt, with value: Int, tag: UInt) {
        print(String(describing: type(of: self)) + ".\(#function)(tag: \(tag)): \(number): \(value)")

        receivedReadIntValue = value
        responseReadIntSemaphore?.signal()
    }
    func didReceiveReadFlag(_ number: UInt, with value: Bool, tag: UInt) {
        print(String(describing: type(of: self)) + ".\(#function)(tag: \(tag)): \(number): \(value)")

        receivedReadBoolValue = value ? 1 : 0
        responseReadBoolSemaphore?.signal()
    }

/*
    func didReceiveSetFlag(_ number: UInt, tag: UInt) {
        print(String(describing: type(of: self)) + ".\(#function)[\(#line)]: called")
    }
    func didReceiveClearFlag(_ number: UInt, tag: UInt) {
        print(String(describing: type(of: self)) + ".\(#function)[\(#line)]: called")
    }
    func didReceiveReadOutput(_ number: UInt, with value: Bool, tag: UInt) {
        print(String(describing: type(of: self)) + ".\(#function)[\(#line)]: called")
    }
    func didReceiveSetOutput(_ number: UInt, tag: UInt) {
        print(String(describing: type(of: self)) + ".\(#function)[\(#line)]: called")
    }
    func didReceiveClearOutput(_ number: UInt, tag: UInt) {
        print(String(describing: type(of: self)) + ".\(#function)[\(#line)]: called")
    }
    func didReceiveWriteIntRegister(_ number: UInt, tag: UInt) {
        print(String(describing: type(of: self)) + ".\(#function)[\(#line)]: called")
    }
*/
}



