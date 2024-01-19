//
//  HomeControlControllerTag.swift
//  HomeControl
//
//  Created by Joachim Kittelberger on 05.01.24.
//  Copyright © 2024 Joachim Kittelberger. All rights reserved.
//

import Foundation



// enumeratiom for all tags, which should be read from application
// this enum goes into tag-Parameter of read-Functions and come
// back in callback functions in tag-Parameter
enum HomeControlControllerTag: UInt32 {
    case readSecond = 1
    case readMinute
    case readHour
    case readHourShutterUp
    case readMinuteShutterUp
    case readHourShutterDown
    case readMinuteShutterDown
    case readHourShutterUpWeekend
    case readMinuteShutterUpWeekend
    
    case readIsAutomaticBlind
    case readIsAutomaticShutter
    case readIsAutomaticSummerMode

    case readIsSaunaOn
    
    case readCurrentStateNightDay
    case readCurrentStateWind
    case readCurrentStateLight
    
    case readUseSunsetSettings
    case readSunsetHourForToday
    case readSunsetMinuteForToday
    case readSunsetOffsetInMin
}
