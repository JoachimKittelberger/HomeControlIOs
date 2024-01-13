//
//  Jet32+PlcDataAccessibleProtocol.swift
//  HomeControl
//
//  Created by Joachim Kittelberger on 28.10.17.
//  Copyright © 2017 Joachim Kittelberger. All rights reserved.
//

import Foundation



// Muss von dem Kommunikationskanal implementiert werden, der Daten aus einer Steuerung lesen und
// schreiben kann

extension Jet32 : PlcDataAccessibleProtocol {

    
    func readIntRegister(_ number: UInt, tag: UInt) {
        
        // erzeuge einen neuen PlcDataAccessEntry und hänge diesen in die queue hinten rein
        let newEntry = PlcDataAccessEntry(type: .IntegerRegister, cmd: .read, comRef: UInt32(tag), number: UInt32(number), value: 0)
        PlcDataAccessQueue.append(newEntry)
        
        let Jet32Data = Jet32DataTelegram(receivePort: UInt32(udpPortReceive), command: Jet32Command.readVariable, number: newEntry.number, tag: newEntry.telegramID)
        outSocket?.send(Jet32Data.getData() as Data, withTimeout: timeout, tag:0)

        
        
        // code für asynchrones lesen starten
        // code für zurück in Tabelle schreiben starten?????
        // beim zurückmelden muss dann die telegramID in der Queue gesucht werden und dieser Eintrag zurückgemeldet werden
        // wenn kein passender Eintrag gefunden wird, dann diesen einfach löschen und ignorieren
        // anschliessend diesen Eintrag löschen
        
    }
    
    
    
    func readIntRegisterSync(_ number: UInt, tag: UInt) -> Int {
        
        // erzeuge einen neuen PlcDataAccessEntry und hänge diesen in die queue hinten rein
        let newEntry = PlcDataAccessEntry(type: .IntegerRegister, cmd: .read, comRef: UInt32(tag), number: UInt32(number), value: 0)
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
    
    
    func writeIntRegister(_ number: UInt, to value: Int, tag: UInt) {
        // TODO: evtl. wird dies beim write gar nicht benötigt
        // erzeuge einen neuen PlcDataAccessEntry und hänge diesen in die queue hinten rein
//        let newEntry = PlcDataAccessEntry(type: .IntegerRegister, cmd: .write, comRef: UInt32(tag), number: UInt32(number), value: UInt32(value))
//        PlcDataAccessQueue.append(newEntry)

        
        //let Jet32Data = Jet32DataTelegram(receivePort: UInt32(udpPortReceive), command: Jet32Command.writeIntRegister, number: UInt32(number), value: UInt32(value))
        let Jet32Data = Jet32DataTelegram(receivePort: UInt32(udpPortReceive), command: Jet32Command.writeVariable, number: UInt32(number), value: UInt32(value))
        outSocket?.send(Jet32Data.getData() as Data, withTimeout: timeout, tag:0)
//        print("writeIntRegister \(number) with \(value)")
    }

    
    
    func readFlag(_ number: UInt, tag: UInt) {

        // erzeuge einen neuen PlcDataAccessEntry und hänge diesen in die queue hinten rein
        let newEntry = PlcDataAccessEntry(type: .Flag, cmd: .read, comRef: UInt32(tag), number: UInt32(number), value: 0)
        PlcDataAccessQueue.append(newEntry)

        let Jet32Data = Jet32DataTelegram(receivePort: UInt32(udpPortReceive), command: Jet32Command.readFlag, number: newEntry.number, tag: newEntry.telegramID)
        outSocket?.send(Jet32Data.getData() as Data, withTimeout: timeout, tag:0)
        
        
    }
    func setFlag(_ number: UInt, tag: UInt) {

        // ohne PlcDataAccessEntry arbeiten
        
        let Jet32Data = Jet32DataTelegram(receivePort: UInt32(udpPortReceive), command: Jet32Command.setFlag, number: UInt32(number))
        outSocket?.send(Jet32Data.getData() as Data, withTimeout: timeout, tag:0)
        //print("setFlag \(number)")
        // TODO: udpsocket ReceiveWithTimeOut?????

    }
    func clearFlag(_ number: UInt, tag: UInt) {

        // ohne PlcDataAccessEntry arbeiten
        
        let Jet32Data = Jet32DataTelegram(receivePort: UInt32(udpPortReceive), command: Jet32Command.resetFlag, number: UInt32(number))
        outSocket?.send(Jet32Data.getData() as Data, withTimeout: timeout, tag:0)
        //print("resetFlag \(number)")
        // TODO: udpsocket ReceiveWithTimeOut?????

    }
    

    func readOutput(_ number: UInt, tag: UInt) {
    }
    func setOutput(_ number: UInt, tag: UInt) {
        /*
        let Jet32Data = Jet32DataTelegram(receivePort: UInt32(udpPortReceive), command: Jet32Command.setOutput, number: UInt32(number))
        outSocket?.send(Jet32Data.getData() as Data, withTimeout: timeout, tag:0)
        print("setOutput \(number)")
        // TODO: udpsocket ReceiveWithTimeOut?????
         */

    }
    func clearOutput(_ number: UInt, tag: UInt) {
/*
        let Jet32Data = Jet32DataTelegram(receivePort: UInt32(udpPortReceive), command: Jet32Command.clearOutput, number: UInt32(number))
        outSocket?.send(Jet32Data.getData() as Data, withTimeout: timeout, tag:0)
        print("clearOutput \(number)")
*/
    }
 }
