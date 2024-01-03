//
//  ShutterList.swift
//  HomeControl
//
//  Created by Joachim Kittelberger on 07.06.17.
//  Copyright © 2017 Joachim Kittelberger. All rights reserved.
//

import Foundation

// shutters with the same ID as in the PLC
// ID ist also offset for Flags
enum Shutters: Int {
    case BlindLeft = 0,
    BlindMiddle,
    BlindRight,
    
    TerraceRight,
    LivingRoomLeft,
    LivingRoomRight,
    TerraceLeft,
    Kitchen,
    Office,
    Toilet,
    Bath,
    Guest,
    DoorGallery,
    DoorSleeping,
    SkylightBath,
    SkylightGallery,
    SkylightStaircase,
    ShutterSkylightGallery,
    ShutterSkylightStaircase,
    ShutterSkylightBath,
    
    HobbyLeft,
    HobbyRight
}

// used with rawValue

//MARK: implementation of ShutterList
class ShutterList : NSObject, ObservableObject {
    
    @Published var items = [ShutterItem]()
    
    
    override init() {
        super.init()

        items.append(ShutterItem(name: "Jalousie links", ID: Shutters.BlindLeft.rawValue, isEnabled: true, outputUp: 100000203, outputDown: 100000204))
        items.append(ShutterItem(name: "Jalousie mitte", ID: Shutters.BlindMiddle.rawValue, isEnabled: true, outputUp: 100000205, outputDown: 100000206))
        items.append(ShutterItem(name: "Jalousie rechts", ID: Shutters.BlindRight.rawValue, isEnabled: true, outputUp: 100000207, outputDown: 100000208))
        items.append(ShutterItem(name: "Dachfenster Treppenhaus", ID: Shutters.SkylightStaircase.rawValue, isEnabled: true, outputUp: 100000403, outputDown: 100000404))
        items.append(ShutterItem(name: "Dachfenster Galerie", ID: Shutters.SkylightGallery.rawValue, isEnabled: true, outputUp: 100000401, outputDown: 100000402))
        items.append(ShutterItem(name: "Rolladen Dachfenster Treppenhaus", ID: Shutters.ShutterSkylightStaircase.rawValue, isEnabled: true, outputUp: 100000407, outputDown: 100000408))
        items.append(ShutterItem(name: "Rolladen Dachfenster Galerie", ID: Shutters.ShutterSkylightGallery.rawValue, isEnabled: true, outputUp: 100000405, outputDown: 100000406))
        items.append(ShutterItem(name: "Rolladen Wohnzimmer links", ID: Shutters.LivingRoomLeft.rawValue, isEnabled: true, outputUp: 100000215, outputDown: 100000216))
        items.append(ShutterItem(name: "Rolladen Wohnzimmer rechts", ID: Shutters.LivingRoomRight.rawValue, isEnabled: true, outputUp: 100000213, outputDown: 100000214))
        items.append(ShutterItem(name: "Rolladen Terrasse links", ID: Shutters.TerraceLeft.rawValue, isEnabled: true, outputUp: 100000211, outputDown: 100000212))
        items.append(ShutterItem(name: "Rolladen Terrasse rechts", ID: Shutters.TerraceRight.rawValue, isEnabled: true, outputUp: 100000209, outputDown: 100000210))
        items.append(ShutterItem(name: "Rolladen Küche", ID: Shutters.Kitchen.rawValue, isEnabled: true, outputUp: 100000301, outputDown: 100000302))
        items.append(ShutterItem(name: "Rolladen Büro Andrea", ID: Shutters.Office.rawValue, isEnabled: true, outputUp: 100000303, outputDown: 100000304))
        items.append(ShutterItem(name: "Rolladen WC", ID: Shutters.Toilet.rawValue, isEnabled: true, outputUp: 100000305, outputDown: 100000306))
        items.append(ShutterItem(name: "Rolladen Schlafzimmer", ID: Shutters.DoorSleeping.rawValue, isEnabled: true, outputUp: 100000313, outputDown: 100000314))
        items.append(ShutterItem(name: "Rolladen Büro Joachim", ID: Shutters.DoorGallery.rawValue, isEnabled: true, outputUp: 100000311, outputDown: 100000312))
        items.append(ShutterItem(name: "Rolladen Gästezimmer", ID: Shutters.Guest.rawValue, isEnabled: true, outputUp: 100000309, outputDown: 100000310))
        items.append(ShutterItem(name: "Rolladen Bad", ID: Shutters.Bath.rawValue, isEnabled: true, outputUp: 100000307, outputDown: 100000308))
        items.append(ShutterItem(name: "Rolladen Hobbyraum links", ID: Shutters.HobbyLeft.rawValue, isEnabled: true, outputUp: 100000411, outputDown: 100000412))
        items.append(ShutterItem(name: "Rolladen Hobbyraum rechts", ID: Shutters.HobbyRight.rawValue, isEnabled: true, outputUp: 100000413, outputDown: 100000414))
    }

    func getShutterItems() -> [ShutterItem] {
        return items
    }
    
    func getShutter(forIndex index: Int) -> ShutterItem {
        return items[index]
    }
    
}
