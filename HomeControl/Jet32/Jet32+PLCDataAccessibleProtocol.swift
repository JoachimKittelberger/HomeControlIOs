//
//  Jet32+PLCDataAccessibleProtocol.swift
//  HomeControl
//
//  Created by Joachim Kittelberger on 28.10.17.
//  Copyright © 2017 Joachim Kittelberger. All rights reserved.
//

import Foundation



// Muss von dem Kommunikationskanal implementiert werden, der Daten aus einer Steuerung lesen und
// schreiben kann

extension Jet32 : PLCDataAccessibleProtocol {

    // TODO: Hier könnte auch eine Funktion erstellt werden, die aus dem PLCDataAccessEntry das Jet32DataTelegram aufbaut und über Socket dann versendet.
    func readIntRegister(_ number: UInt, tag: UInt, delegate: PLCDataAccessibleDelegate? = nil) {
        // erzeuge einen neuen PLCDataAccessEntry und hänge diesen in die queue hinten rein
        let newEntry = PLCDataAccessEntry(type: .IntegerRegister, cmd: .read, comRef: UInt32(tag), number: UInt32(number), value: 0, delegate: delegate)
        PlcDataAccessQueue.append(newEntry)
        
        let Jet32Data = Jet32DataTelegram(receivePort: UInt32(udpPortReceive), command: Jet32Command.readVariable, number: newEntry.number, tag: newEntry.telegramID)
        outSocket?.send(Jet32Data.getData() as Data, withTimeout: timeout, tag:0)
    }
    

    func writeIntRegister(_ number: UInt, to value: Int, tag: UInt, delegate: PLCDataAccessibleDelegate? = nil) {
        print(String(describing: type(of: self)) + ".\(#function)[\(#line)]: number \(number) value: \(value) tag: \(tag) called")

        // erzeuge einen neuen PLCDataAccessEntry und hänge diesen in die queue hinten rein
        let newEntry = PLCDataAccessEntry(type: .IntegerRegister, cmd: .write, comRef: UInt32(tag), number: UInt32(number), value: UInt32(value), delegate: delegate)
        PlcDataAccessQueue.append(newEntry)
        
        //let Jet32Data = Jet32DataTelegram(receivePort: UInt32(udpPortReceive), command: Jet32Command.writeIntRegister, number: UInt32(number), value: UInt32(value))
        let Jet32Data = Jet32DataTelegram(receivePort: UInt32(udpPortReceive), command: Jet32Command.writeVariable, number: UInt32(number), tag: newEntry.telegramID, value: UInt32(value))
        outSocket?.send(Jet32Data.getData() as Data, withTimeout: timeout, tag:0)
    }

    
    
    func readFlag(_ number: UInt, tag: UInt, delegate: PLCDataAccessibleDelegate? = nil) {
        // erzeuge einen neuen PLCDataAccessEntry und hänge diesen in die queue hinten rein
        let newEntry = PLCDataAccessEntry(type: .Flag, cmd: .read, comRef: UInt32(tag), number: UInt32(number), value: 0, delegate: delegate)
        PlcDataAccessQueue.append(newEntry)

        let Jet32Data = Jet32DataTelegram(receivePort: UInt32(udpPortReceive), command: Jet32Command.readFlag, number: newEntry.number, tag: newEntry.telegramID)
        outSocket?.send(Jet32Data.getData() as Data, withTimeout: timeout, tag:0)
    }


    func setFlag(_ number: UInt, tag: UInt, delegate: PLCDataAccessibleDelegate? = nil) {
        print(String(describing: type(of: self)) + ".\(#function)[\(#line)]: number \(number) tag: \(tag) called")
        // erzeuge einen neuen PLCDataAccessEntry und hänge diesen in die queue hinten rein
        let newEntry = PLCDataAccessEntry(type: .Flag, cmd: .set, comRef: UInt32(tag), number: UInt32(number), value: 1, delegate: delegate)
        PlcDataAccessQueue.append(newEntry)
        
        let Jet32Data = Jet32DataTelegram(receivePort: UInt32(udpPortReceive), command: Jet32Command.setFlag, number: UInt32(number), tag: newEntry.telegramID)
        outSocket?.send(Jet32Data.getData() as Data, withTimeout: timeout, tag:0)
    }


    func clearFlag(_ number: UInt, tag: UInt, delegate: PLCDataAccessibleDelegate? = nil) {
        print(String(describing: type(of: self)) + ".\(#function)[\(#line)]: number \(number) tag: \(tag) called")
        // erzeuge einen neuen PLCDataAccessEntry und hänge diesen in die queue hinten rein
        let newEntry = PLCDataAccessEntry(type: .Flag, cmd: .clear, comRef: UInt32(tag), number: UInt32(number), value: 0, delegate: delegate)
        PlcDataAccessQueue.append(newEntry)

        let Jet32Data = Jet32DataTelegram(receivePort: UInt32(udpPortReceive), command: Jet32Command.resetFlag, number: UInt32(number), tag: newEntry.telegramID)
        outSocket?.send(Jet32Data.getData() as Data, withTimeout: timeout, tag:0)
    }
    

    
    
    /*
    
    
    func readOutput(_ number: UInt, tag: UInt, delegate: PLCDataAccessibleDelegate? = nil) {
    }
    func setOutput(_ number: UInt, tag: UInt, delegate: PLCDataAccessibleDelegate? = nil) {
        let Jet32Data = Jet32DataTelegram(receivePort: UInt32(udpPortReceive), command: Jet32Command.setOutput, number: UInt32(number))
        outSocket?.send(Jet32Data.getData() as Data, withTimeout: timeout, tag:0)
        print("setOutput \(number)")
        // TODO: udpsocket ReceiveWithTimeOut?????
    }
    func clearOutput(_ number: UInt, tag: UInt, delegate: PLCDataAccessibleDelegate? = nil) {
        let Jet32Data = Jet32DataTelegram(receivePort: UInt32(udpPortReceive), command: Jet32Command.clearOutput, number: UInt32(number))
        outSocket?.send(Jet32Data.getData() as Data, withTimeout: timeout, tag:0)
        print("clearOutput \(number)")
    }

     // TODO implement and perhabs delete delegate
     func readIntRegisterSync(_ number: UInt, tag: UInt, delegate: PLCDataAccessibleDelegate? = nil) -> Int {
         
         // erzeuge einen neuen PLCDataAccessEntry und hänge diesen in die queue hinten rein
         let newEntry = PLCDataAccessEntry(type: .IntegerRegister, cmd: .read, comRef: UInt32(tag), number: UInt32(number), value: 0, delegate: delegate)
         PlcDataAccessQueue.append(newEntry)
         
         let Jet32Data = Jet32DataTelegram(receivePort: UInt32(udpPortReceive), command: Jet32Command.readVariable, number: newEntry.number, tag: newEntry.telegramID)
         outSocket?.send(Jet32Data.getData() as Data, withTimeout: timeout, tag:0)
         
         let value: Int = 0
         
         // code für asynchrones lesen starten
         // code für zurück in Tabelle schreiben starten?????
         // beim zurückmelden muss dann die telegramID in der Queue gesucht werden und dieser Eintrag zurückgemeldet werden
         // wenn kein passender Eintrag gefunden wird, dann diesen einfach löschen und ignorieren
         // anschliessend diesen Eintrag löschen

        return value
     }

     */
     
 }
