//
//  Jet32SyncExample.swift
//  HomeControl
//
//  Created by Joachim Kittelberger on 12.01.24.
//  Copyright © 2024 Joachim Kittelberger. All rights reserved.
//

import Foundation


//import CocoaAsyncSocket

class UDPClient: NSObject, GCDAsyncUdpSocketDelegate {

    var udpSocket: GCDAsyncUdpSocket!
    var responseSemaphore: DispatchSemaphore?

    override init() {
        super.init()

        udpSocket = GCDAsyncUdpSocket(delegate: self, delegateQueue: DispatchQueue.main)

        do {
            try udpSocket.bind(toPort: 12345)
            try udpSocket.enableBroadcast(true)
            try udpSocket.beginReceiving()
        } catch {
            print("Error setting up UDP socket: \(error)")
        }
    }

    func sendAndWaitForResponse(message: String, toHost host: String, onPort port: UInt16) -> String? {
        guard let data = message.data(using: .utf8) else {
            return nil
        }

        responseSemaphore = DispatchSemaphore(value: 0)

        udpSocket.send(data, toHost: host, port: port, withTimeout: -1, tag: 0)

        // Wait for the response with a timeout
        let timeoutResult = responseSemaphore?.wait(timeout: DispatchTime.now() + DispatchTimeInterval.seconds(10))

        if timeoutResult == .success, let response = receivedResponse {
            return response
        } else {
            return nil
        }
    }

    var receivedResponse: String?

    func udpSocket(_ sock: GCDAsyncUdpSocket, didReceive data: Data, fromAddress address: Data, withFilterContext filterContext: Any?) {
        if let message = String(data: data, encoding: .utf8) {
            print("Received message: \(message)")

            // Store the received response and signal the semaphore
            receivedResponse = message
            responseSemaphore?.signal()
        }
    }
}


/*
 let udpClient = UDPClient()
 
 if let response = udpClient.sendAndWaitForResponse(message: "Hello, UDP!", toHost: "192.168.0.100", onPort: 12345) {
 print("Received response: \(response)")
 } else {
 print("No response received or timeout occurred.")
 }
 */
