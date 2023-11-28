//
//  PlcDataAccessEntry.swift
//  HomeControl
//
//  Created by Joachim Kittelberger on 07.10.17.
//  Copyright © 2017 Joachim Kittelberger. All rights reserved.
//

import Foundation



class PlcDataAccessEntry {
 
    enum DataType {
        case IntegerRegister, Flag, Input, Output, FloatRegister, String
    }
    enum Command {
        case read, write, clear, set
    }

    
    
    //    let cmd: Jet32Command
    
    let type: DataType
    let cmd: Command
    let comRef : UInt32
    let number: UInt32
    let value: UInt32
    
    var retVal: UInt32
    var telegramID: UInt32
    
    static var globalID: UInt32 = 0;
    
    
    /*
     let tag: UInt32
     var telegramID: UINT32          // muss bei jeder Kommunikation statisch hochgezählt werden
     
     // Daten sollten sein:
     Type: IntReg,Flag, Input, Output, FloatReg?, String?
     Command: Read, Write, Clear, Set
     CommunicationReference: Zuordnung beim Ergebnis zurückliefern
     Number : UInt32
     Value : UInt32
     RetVal : UInt32 (und bei String?
     Evtl. Name der Variablen, um nur noch diesen in der App zu verwenden?
     
     
     */
    init(type: DataType, cmd: Command, comRef : UInt32, number: UInt32, value: UInt32) {
        self.type = type
        self.cmd = cmd
        self.comRef = comRef
        self.number = number
        self.value = value
        
        PlcDataAccessEntry.globalID += 1
        self.telegramID = PlcDataAccessEntry.globalID
        
        self.retVal = 0;
//        print("Create new PlcDataAccessEntry \(self.telegramID)")
    }
    
    //send()
    
}

/*
// infos über MultiThreading-Programmierung:
https://www.appcoda.com/grand-central-dispatch/
*/



