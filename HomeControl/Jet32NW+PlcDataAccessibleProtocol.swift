//
//  Jet32NW+PlcDataAccessibleProtocol.swift
//  HomeControl
//
//  Created by Joachim Kittelberger on 10.04.19.
//  Copyright © 2019 Joachim Kittelberger. All rights reserved.
//

import Foundation
// Muss von dem Kommunikationskanal implementiert werden, der Daten aus einer Steuerung lesen und
// schreiben kann

extension Jet32NW : PlcDataAccessibleProtocol {
    
    
    func readIntRegister(_ number: UInt, tag: UInt) {
        
        // erzeuge einen neuen PlcDataAccessEntry und hänge diesen in die queue hinten rein
        let newEntry = PlcDataAccessEntry(type: .IntegerRegister, cmd: .read, comRef: UInt32(tag), number: UInt32(number), value: 0)
        
        PlcDataAccessQueue.append(newEntry)
        
        
        let Jet32Data = Jet32DataTelegram(receivePort: UInt32(udpPortReceive), command: Jet32Command.readVariable, number: newEntry.number, tag: newEntry.telegramID)
/*        outSocket?.send(Jet32Data.getData() as Data, withTimeout: timeout, tag:0)
*/
        
        
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
/*        outSocket?.send(Jet32Data.getData() as Data, withTimeout: timeout, tag:0)
*/
        var value: Int = 0
        
        
        
        
        
        
        // code für asynchrones lesen starten
        // code für zurück in Tabelle schreiben starten?????
        // beim zurückmelden muss dann die telegramID in der Queue gesucht werden und dieser Eintrag zurückgemeldet werden
        // wenn kein passender Eintrag gefunden wird, dann diesen einfach löschen und ignorieren
        // anschliessend diesen Eintrag löschen
        
        
        return value
    }
    
    
    func writeIntRegister(_ number: UInt, to value: Int, tag: UInt) {
        
    }
    
    func readFlag(_ number: UInt, tag: UInt) {
        
        // erzeuge einen neuen PlcDataAccessEntry und hänge diesen in die queue hinten rein
        let newEntry = PlcDataAccessEntry(type: .Flag, cmd: .read, comRef: UInt32(tag), number: UInt32(number), value: 0)
        
        PlcDataAccessQueue.append(newEntry)
        
        let Jet32Data = Jet32DataTelegram(receivePort: UInt32(udpPortReceive), command: Jet32Command.readFlag, number: newEntry.number, tag: newEntry.telegramID)
/*        outSocket?.send(Jet32Data.getData() as Data, withTimeout: timeout, tag:0)
*/
        
    }
    func setFlag(_ number: UInt, tag: UInt) {
        
    }
    func clearFlag(_ number: UInt, tag: UInt) {
        
    }
    
    func readOutput(_ number: UInt, tag: UInt) {
        
    }
    func setOutput(_ number: UInt, tag: UInt) {
        
    }
    func clearOutput(_ number: UInt, tag: UInt) {
        
    }
}
