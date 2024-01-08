//
//  Jet32Delegate.swift
//  HomeControl
//
//  Created by Joachim Kittelberger on 16.06.17.
//  Copyright © 2017 Joachim Kittelberger. All rights reserved.
//

import Foundation


protocol Jet32Delegate {
    
    func didReceiveReadRegister(value: UInt, tag: UInt)
    func didReceiveReadFlag(value: Bool, tag: UInt)
    
}
