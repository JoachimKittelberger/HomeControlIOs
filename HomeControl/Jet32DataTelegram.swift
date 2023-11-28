//
//  Jet32DataTelegram.swift
//  HomeControl
//
//  Created by Joachim Kittelberger on 10.06.17.
//  Copyright © 2017 Joachim Kittelberger. All rights reserved.
//

import Foundation


enum Jet32Command: UInt8 {
    case setOutput = 0x87
    case clearOutput = 0x88
    case writeIntRegister = 0x52
    case readIntRegister = 0x51
    case readFlag = 0x4B
    case setFlag = 0x4C
    case resetFlag = 0x4D
    case readVariable = 0x7C
    case writeVariable = 0x7D
}



class Jet32DataTelegram {
    
    // maximum lenght is header[20] + data[10]
    var dataHeader : [UInt8] = [
        0x4A, 0x57, 0x49, 0x50,
        0x00, 0x01, 0x00, 0x01,         // protocol version 1.1
        0x00, 0x00, 0x00, 0x00,         // communication reference
        0x00, 0x00, 0x00, 0x00,         // receive Port
        0x00, 0x00, 0x00, 0x00,         // reserved
        
        0x00,                           // set Output
        0x00,                           // modifier byte
        0x00, 0x00, 0x00, 0x00,         // number of Output
        0x00, 0x00, 0x00, 0x00]         // index
    
    var length = 30
    
    
    init(receivePort: UInt32, command: Jet32Command, number: UInt32, tag: UInt32 = 0, value: UInt32 = 0) {

        // insert communication reference
        var myInt: UInt32 = tag
        var myIntData = Data(bytes: &myInt, count: MemoryLayout.size(ofValue: myInt))
        
        dataHeader[8] = myIntData[3]
        dataHeader[9] = myIntData[2]
        dataHeader[10] = myIntData[1]
        dataHeader[11] = myIntData[0]

        // insert receive port
        myInt = receivePort
        myIntData = Data(bytes: &myInt, count: MemoryLayout.size(ofValue: myInt))
        
        dataHeader[12] = myIntData[3]
        dataHeader[13] = myIntData[2]
        dataHeader[14] = myIntData[1]
        dataHeader[15] = myIntData[0]
        
        // command
        dataHeader[20] = command.rawValue

        switch command {
        case .clearOutput,
             .setOutput:

            myInt = number
            myIntData = Data(bytes: &myInt, count: MemoryLayout.size(ofValue: myInt))
            
            dataHeader[22] = myIntData[3]
            dataHeader[23] = myIntData[2]
            dataHeader[24] = myIntData[1]
            dataHeader[25] = myIntData[0]
            length = dataHeader.count       // TODO: Die echte Länge je nach Telegramm zurückgeben. Hier stimmt es aber
       
        case .writeIntRegister:

            // register number: Don't use this version with newer controller
            myInt = number
            myIntData = Data(bytes: &myInt, count: MemoryLayout.size(ofValue: myInt))

            dataHeader[21] = myIntData[2]
            dataHeader[22] = myIntData[1]
            dataHeader[23] = myIntData[0]
 
            // register value
            myInt = value
            myIntData = Data(bytes: &myInt, count: MemoryLayout.size(ofValue: myInt))
            
            dataHeader[24] = myIntData[3]
            dataHeader[25] = myIntData[2]
            dataHeader[26] = myIntData[1]
            dataHeader[27] = myIntData[0]
            length = 28
            
        case .readIntRegister:

            // register number: Don't use this version with newer controller
            myInt = number
            myIntData = Data(bytes: &myInt, count: MemoryLayout.size(ofValue: myInt))
            
            dataHeader[21] = myIntData[2]
            dataHeader[22] = myIntData[1]
            dataHeader[23] = myIntData[0]
            length = 24
  
        case .readFlag,
             .setFlag,
             .resetFlag:
            
            // flag number
            myInt = number
            myIntData = Data(bytes: &myInt, count: MemoryLayout.size(ofValue: myInt))
            
            dataHeader[21] = myIntData[1]
            dataHeader[22] = myIntData[0]
            length = 23

        case .readVariable:
            // variable number
            myInt = number
            myIntData = Data(bytes: &myInt, count: MemoryLayout.size(ofValue: myInt))
            
            dataHeader[21] = myIntData[3]
            dataHeader[22] = myIntData[2]
            dataHeader[23] = myIntData[1]
            dataHeader[24] = myIntData[0]
            length = 25
            
        case .writeVariable:
            // variable number
            myInt = number
            myIntData = Data(bytes: &myInt, count: MemoryLayout.size(ofValue: myInt))
            
            dataHeader[21] = myIntData[3]
            dataHeader[22] = myIntData[2]
            dataHeader[23] = myIntData[1]
            dataHeader[24] = myIntData[0]

            dataHeader[25] = 0x11       // DataType Long
            
            // register value
            myInt = value
            myIntData = Data(bytes: &myInt, count: MemoryLayout.size(ofValue: myInt))
            
            dataHeader[26] = myIntData[3]
            dataHeader[27] = myIntData[2]
            dataHeader[28] = myIntData[1]
            dataHeader[29] = myIntData[0]
            length = 30
           
            
            
//        default:
//            print("Error default should never happen")
        }
    }
    
    
    public func getData() -> NSData {
        return NSData(bytes: dataHeader, length: length)
    }
    
    
    
}
