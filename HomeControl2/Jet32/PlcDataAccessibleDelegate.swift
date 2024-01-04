//
//  PlcDataAccessibleDelegate.swift
//  HomeControl
//
//  Created by Joachim Kittelberger on 07.10.17.
//  Copyright © 2017 Joachim Kittelberger. All rights reserved.
//

// defines the functions getting data from a connected PLC
// tag ist a userdefined value to match the request with the right response
// the response comes with the corresponding tag from the request.

import Foundation


protocol PlcDataAccessibleDelegate {
    
    func didRedeiveReadIntRegister(_ number: UInt, with value: Int, tag: UInt)
    func didRedeiveWriteIntRegister(_ number: UInt, tag: UInt)
    
    func didRedeiveReadFlag(_ number: UInt, with value: Bool, tag: UInt)
    func didRedeiveSetFlag(_ number: UInt, tag: UInt)
    func didRedeiveClearFlag(_ number: UInt, tag: UInt)
    
    func didRedeiveReadOutput(_ number: UInt, with value: Bool, tag: UInt)
    func didRedeiveSetOutput(_ number: UInt, tag: UInt)
    func didRedeiveClearOutput(_ number: UInt, tag: UInt)
    
}
