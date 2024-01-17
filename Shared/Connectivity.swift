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
    
    case response           // response from iPhone to iWatch
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
    var receivedReadValue: Int?
    var responseReadSemaphore: DispatchSemaphore?

    
    // this fuction will be called from the WCSessionDelegate.session callbacks
    private func update(from message: [String: Any]) {
        //print("update data \(message)")

#if os(iOS)
        var msgType = MessageType.unknown
        var number = UInt(0)
        var value = Int(0)
        var tag = UInt(0)
        /*
            // Initialisation in Jet32Watch
            "type": String(MessageType.readRegister.rawValue),
            "number": String(number),
            "value": String(0),
            "tag": String(tag)
        */
 
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
            //print("Error: msgType \(msgType.rawValue) not implemented")
            let homeControlConnection = PLCComMgr.shared
            homeControlConnection.connect()

            // sync call and get return value
            responseReadSemaphore = DispatchSemaphore(value: 0)
            receivedReadValue = nil     // TODO: evtl. wird das hier nicht benötigt
            let _ = homeControlConnection.readIntRegister(number, tag: tag, delegate: self)
            
            // TODO: hier auf Ergebnis des Lesens warten
            // Wait for the response with a timeout
            let timeoutResult = responseReadSemaphore?.wait(timeout: DispatchTime.now() + DispatchTimeInterval.seconds(4))

            if timeoutResult == .success, let response = receivedReadValue {

   
            } else {
                print("Error Reading SyncReg for Response");
            }
       
            
            
            //homeControlConnection.setDelegate(delegate: nil)

        case .getFlag:
            print("Error: msgType \(msgType.rawValue) not implemented")
            let homeControlConnection = PLCComMgr.shared
            homeControlConnection.connect()
            let _ = homeControlConnection.readFlag(number, tag: tag)
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
        case .response:
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
        print(String(describing: type(of: self)) + ".\(#function)[\(#line)]: activationState: \(activationState) error: \(error?.localizedDescription) called")
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
    func session(_ session: WCSession, didReceiveMessage message: [String: Any], replyHandler: @escaping ([String: Any]) -> Void) {
        print(String(describing: type(of: self)) + ".\(#function)[\(#line)]: called")
        
        // we have an message from Apple Watch to iPhone
        update(from: message)



        /*
            // Initialisation response
            "type": String(MessageType.response.rawValue),
            "number": String(number),
            "value": String(0),
            "tag": String(tag)
        */
      
        
        // Send a response back to the Apple Watch
        var number = UInt(0)
        var tag = UInt(0)
        if let retVal = message["number"] as? String {
            number = UInt((retVal as AnyObject).integerValue)
        }
        if let retVal = message["tag"] as? String {
            tag = UInt((retVal as AnyObject).integerValue)
        }
        let responseMessage = [
            "type": String(MessageType.response.rawValue),
            "value": String(receivedReadValue ?? 0),
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
 
        
        
        
/*        session.sendMessage(responseMessage, replyHandler: { response in
            // Handle the response from the Apple Watch
            print("Received response from Apple Watch: \(response)")
        }, errorHandler: { error in
            // Handle error
            print("Error sending response to Apple Watch: \(error.localizedDescription)")
        })
*/
        
/*
#if os(iOS)
        //let key = MessageType.verified.rawValue
        //replyHandler([key: true])
        let homeControlConnection = PLCComMgr.shared
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
        print(String(describing: type(of: self)) + ".\(#function)[\(#line)]: called")
        
        
        // test, if we have an response from iPhone to Apple Watch
    #if os(watchOS)
        if let val = message["type"] as? String {
            let msgType = MessageType(rawValue: (val))!
            if (msgType == MessageType.response) {
 
                var number = UInt(0)
                var value = Int(0)
                var tag = UInt(0)
               
                if let retVal = message["value"] as? String {
                    value = (retVal as AnyObject).integerValue
                    
                    if let retVal = message["number"] as? String {
                        number = UInt((retVal as AnyObject).integerValue)

                        if let retVal = message["tag"] as? String {
                            tag = UInt((retVal as AnyObject).integerValue)

                            //print("ResponsefromiPhone: number: \(number) value: \(value) tag: \(tag)")

                            // TODO: sende das Ergebnis über dsa Delegate der homeControlConnection
                            let homeControlConnection = PLCComMgr.shared
                            homeControlConnection.getDelegate()?.didReceiveReadIntRegister(number, with: value, tag: tag);
                        }
                    }
                }
                return
            }
        }
    #endif

        
        
        update(from: message)
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

        receivedReadValue = value
        responseReadSemaphore?.signal()

        //didReceiveReadRegister(value: UInt(value), tag: tag)            // call function from Jet32Delegate
    }
    
    func didReceiveWriteIntRegister(_ number: UInt, tag: UInt) {
        print(String(describing: type(of: self)) + ".\(#function)[\(#line)]: called")
    }
    
    func didReceiveReadFlag(_ number: UInt, with value: Bool, tag: UInt) {
        print(String(describing: type(of: self)) + ".\(#function)(tag: \(tag)): \(number): \(value)")

//        receivedReadValue = value
//        responseReadSemaphore?.signal()

        //didReceiveReadFlag(value: value, tag: tag)            // call function from Jet32Delegate
    }
    
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

}



