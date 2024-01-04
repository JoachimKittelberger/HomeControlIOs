//
//  PlcDataAccessibleProtocol.swift
//  HomeControl
//
//  Created by Joachim Kittelberger on 07.10.17.
//  Copyright © 2017 Joachim Kittelberger. All rights reserved.
//

// defines the functions to access data from a connected PLC
// tag ist a userdefined value to match the request with the right response
// the response comes with the corresponding tag from the request.

import Foundation


protocol PlcDataAccessibleProtocol {
    
    func readIntRegister(_ number: UInt, tag: UInt)
    func writeIntRegister(_ number: UInt, to value: Int, tag: UInt)
    
    func readFlag(_ number: UInt, tag: UInt)
    func setFlag(_ number: UInt, tag: UInt)
    func clearFlag(_ number: UInt, tag: UInt)
    
    func readOutput(_ number: UInt, tag: UInt)
    func setOutput(_ number: UInt, tag: UInt)
    func clearOutput(_ number: UInt, tag: UInt)
    
    func readIntRegisterSync(_ number: UInt, tag: UInt) -> Int
}

