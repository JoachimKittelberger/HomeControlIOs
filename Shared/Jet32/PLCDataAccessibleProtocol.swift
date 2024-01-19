//
//  PLCDataAccessibleProtocol.swift
//  HomeControl
//
//  Created by Joachim Kittelberger on 07.10.17.
//  Copyright © 2017 Joachim Kittelberger. All rights reserved.
//

// defines the functions to access data from a connected PLC
// tag ist a userdefined value to match the request with the right response
// the response comes with the corresponding tag from the request.

import Foundation


protocol PLCDataAccessibleProtocol {
    
    func readIntRegister(_ number: UInt, tag: UInt, delegate: PLCDataAccessibleDelegate?)
    func writeIntRegister(_ number: UInt, to value: Int, tag: UInt, delegate: PLCDataAccessibleDelegate?)
    
    func readFlag(_ number: UInt, tag: UInt, delegate: PLCDataAccessibleDelegate?)
    func setFlag(_ number: UInt, tag: UInt, delegate: PLCDataAccessibleDelegate?)
    func clearFlag(_ number: UInt, tag: UInt, delegate: PLCDataAccessibleDelegate?)
 /*
    func readOutput(_ number: UInt, tag: UInt, delegate: PLCDataAccessibleDelegate?)
    func setOutput(_ number: UInt, tag: UInt, delegate: PLCDataAccessibleDelegate?)
    func clearOutput(_ number: UInt, tag: UInt, delegate: PLCDataAccessibleDelegate?)
    
    func readIntRegisterSync(_ number: UInt, tag: UInt, delegate: PLCDataAccessibleDelegate?) -> Int
  */
}

