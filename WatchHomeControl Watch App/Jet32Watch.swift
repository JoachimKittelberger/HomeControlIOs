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




