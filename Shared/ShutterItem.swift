//
//  ShutterItem.swift
//  HomeControl
//
//  Created by Joachim Kittelberger on 07.06.17.
//  Copyright © 2017 Joachim Kittelberger. All rights reserved.
//

import Foundation


struct ShutterItem : Identifiable, Hashable {
    let id = UUID()         // TODO: Evtl mit ID tauschen oder ersetzen
    
    
    let name: String
    let ID: Int
    var isEnabled: Bool

    let outputUp: Int
    let outputDown: Int

    var isMovingDown: Bool = false
    var isMovingUp: Bool = false
    
    
    
    init(name: String, ID: Int, isEnabled: Bool, outputUp: Int, outputDown: Int) {
        self.name = name
        self.ID = ID
        self.isEnabled = isEnabled
        self.outputUp = outputUp
        self.outputDown = outputDown
    }
}




