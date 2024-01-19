//
//  PLCDataAccessibleDelegate.swift
//  HomeControl
//
//  Created by Joachim Kittelberger on 07.10.17.
//  Copyright © 2017 Joachim Kittelberger. All rights reserved.
//

// defines the functions getting data from a connected PLC
// tag ist a userdefined value to match the request with the right response
// the response comes with the corresponding tag from the request.

import Foundation


protocol PLCDataAccessibleDelegate {
    
    func didReceiveReadIntRegister(_ number: UInt, with value: Int, tag: UInt)
//    func didReceiveWriteIntRegister(_ number: UInt, tag: UInt)
    
    func didReceiveReadFlag(_ number: UInt, with value: Bool, tag: UInt)
    //func didReceiveSetFlag(_ number: UInt, tag: UInt)
    //func didReceiveClearFlag(_ number: UInt, tag: UInt)
 
    /*
    func didReceiveReadOutput(_ number: UInt, with value: Bool, tag: UInt)
    func didReceiveSetOutput(_ number: UInt, tag: UInt)
    func didReceiveClearOutput(_ number: UInt, tag: UInt)
    */
}
