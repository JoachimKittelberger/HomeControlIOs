//
//  NWConnectionDemoClientServer.swift
//  HomeControl
//
//  Created by Joachim Kittelberger on 05.11.19.
//  Copyright © 2019 Joachim Kittelberger. All rights reserved.
//


import Foundation
import Network

class Connection {

    init(nwConnection: NWConnection) {
        self.nwConnection = nwConnection
        self.id = Connection.nextID
        Connection.nextID += 1
    }

    private static var nextID: Int = 0

    let nwConnection: NWConnection
    let id: Int

    var didStopCallback: ((Error?) -> Void)? = nil

    func start() {
        print("connection \(self.id) will start")
        self.nwConnection.stateUpdateHandler = self.stateDidChange(to:)
        self.setupReceive()
        self.nwConnection.start(queue: .main)
    }

    func send(data: Data) {
        self.nwConnection.send(content: data, completion: .contentProcessed( { error in
            if let error = error {
                self.connectionDidFail(error: error)
                return
            }
            print("connection \(self.id) did send, data: \(data as NSData)")
        }))
    }

    func stop() {
        print("connection \(self.id) will stop")
    }

    private func stateDidChange(to state: NWConnection.State) {
        switch state {
        case .setup:
            break
        case .waiting(let error):
            self.connectionDidFail(error: error)
        case .preparing:
            break
        case .ready:
            print("connection \(self.id) ready")
        case .failed(let error):
            self.connectionDidFail(error: error)
        case .cancelled:
            break
        default:
            break
        }
    }

    private func connectionDidFail(error: Error) {
        print("connection \(self.id) did fail, error: \(error)")
        self.stop(error: error)
    }

    private func connectionDidEnd() {
        print("connection \(self.id) did end")
        self.stop(error: nil)
    }

    private func stop(error: Error?) {
        self.nwConnection.stateUpdateHandler = nil
        self.nwConnection.cancel()
        if let didStopCallback = self.didStopCallback {
            self.didStopCallback = nil
            didStopCallback(error)
        }
    }

    private func setupReceive() {
        self.nwConnection.receive(minimumIncompleteLength: 1, maximumLength: 65536) { (data, _, isComplete, error) in
            if let data = data, !data.isEmpty {
                print("connection \(self.id) did receive, data: \(data as NSData)")
            }
            if isComplete {
                self.connectionDidEnd()
            } else if let error = error {
                self.connectionDidFail(error: error)
            } else {
                self.setupReceive()
            }
        }
    }
}

class Client {

    init() {
        let nwConnection = NWConnection(host: "127.0.0.1", port: 12345, using: .tcp)
        self.connection = Connection(nwConnection: nwConnection)
    }

    let connection: Connection

    func start() {
        self.connection.didStopCallback = self.didStopCallback(error:)
        self.connection.start()
    }

    func didStopCallback(error: Error?) {
        if error == nil {
            exit(EXIT_SUCCESS)
        } else {
            exit(EXIT_FAILURE)
        }
    }

    static func run() {
        let client = Client()
        client.start()
        dispatchMain()
    }
}

class Server {

    init() {
        self.listener = try! NWListener(using: .tcp, on: 12345)
        self.timer = DispatchSource.makeTimerSource(queue: .main)
    }

    let listener: NWListener
    let timer: DispatchSourceTimer

    func start() throws {
        print("server will start")
        self.listener.stateUpdateHandler = self.stateDidChange(to:)
        self.listener.newConnectionHandler = self.didAccept(nwConnection:)
        self.listener.start(queue: .main)
    
        self.timer.setEventHandler(handler: self.heartbeat)
        self.timer.schedule(deadline: .now() + 5.0, repeating: 5.0)
        self.timer.activate()
    }

    func stateDidChange(to newState: NWListener.State) {
        switch newState {
        case .setup:
            break
        case .waiting:
            break
        case .ready:
            break
        case .failed(let error):
            print("server did fail, error: \(error)")
            self.stop()
        case .cancelled:
            break
        default:
            break
        }
    }

    private var connectionsByID: [Int: Connection] = [:]

    private func didAccept(nwConnection: NWConnection) {
        let connection = Connection(nwConnection: nwConnection)
        self.connectionsByID[connection.id] = connection
        connection.didStopCallback = { _ in
            self.connectionDidStop(connection)
        }
        connection.start()
        print("server did open connection \(connection.id)")
    }

    private func connectionDidStop(_ connection: Connection) {
        self.connectionsByID.removeValue(forKey: connection.id)
        print("server did close connection \(connection.id)")
    }

    private func stop() {
        self.listener.stateUpdateHandler = nil
        self.listener.newConnectionHandler = nil
        self.listener.cancel()
        for connection in self.connectionsByID.values {
            connection.didStopCallback = nil
            connection.stop()
        }
        self.connectionsByID.removeAll()
        self.timer.cancel()
    }

    private func heartbeat() {
        let timestamp = Date()
        print("server heartbeat, timestamp: \(timestamp)")
        for connection in self.connectionsByID.values {
            let data = "heartbeat, connection: \(connection.id), timestamp: \(timestamp)\r\n"
            connection.send(data: Data(data.utf8))
        }
    }

    static func run() {
        let listener = Server()
        try! listener.start()
        dispatchMain()
    }
}

/*
func main() {
    switch CommandLine.arguments.dropFirst() {
    case ["client"]: Client.run()
    case ["server"]: Server.run()
    default:
        print("usage: NWTest server | client")
        exit(EXIT_FAILURE)
    }
}

main()
*/
