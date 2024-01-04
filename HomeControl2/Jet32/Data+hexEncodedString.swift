//
//  Data+hexEncodedString.swift
//  HomeControl
//
//  Created by Joachim Kittelberger on 09.06.17.
//  Copyright © 2017 Joachim Kittelberger. All rights reserved.
//

import Foundation


extension Data {
    func hexEncodedString() -> String {
        return map { String(format: "%02hhx", $0) }.joined()
    }
}
