//
//  States.swift
//  HomeControl
//
//  Created by Joachim Kittelberger on 24.01.24.
//  Copyright © 2024 Joachim Kittelberger. All rights reserved.
//

import Foundation


enum LightState: Int {
    case hellerkannt = 0,
         hell,
         dunkelerkannt,
         dunkel,
         unknown

    var description: String {
        switch self {
        case .hellerkannt:
            return "hell erkannt"
        case .hell:
            return "hell"
        case .dunkelerkannt:
            return "dunkel erkannt"
        case .dunkel:
            return "dunkel"
        case .unknown:
            return "unbekannt"
//        default:
//            return "reserved"
        }
    }
}


enum WindState: Int {
    case winderkannt = 0,
         zuvielwind,
         keinwinderkannt,
         keinwind,
         unknown

    var description: String {
        switch self {
        case .winderkannt:
            return "Wind erkannt"
        case .zuvielwind:
            return "Wind"
        case .keinwinderkannt:
            return "kein Wind erkannt"
        case .keinwind:
            return "kein Wind"
        case .unknown:
            return "unbekannt"
//        default:
//            return "reserved"
        }
    }
}


/*
protocol DescriptableEnum  {
      var description: String { get }
}
*/

//enum NightDayState: Int, DescriptableEnum {
enum NightDayState: Int {
    case day = 0,
         night,
         unknown
    
    var description: String {
        switch self {
        case .day:
            return "Tag"
        case .night:
            return "Nacht"
        case .unknown:
            return "unbekannt"
//        default:
//            return "reserved"
        }
    }
}




