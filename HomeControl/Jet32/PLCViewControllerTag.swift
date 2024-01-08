//
//  PLCViewControllerTag.swift
//  HomeControl
//
//  Created by Joachim Kittelberger on 05.01.24.
//  Copyright © 2024 Joachim Kittelberger. All rights reserved.
//

import Foundation


enum PLCViewControllerTag: UInt32 {
    case readSecond
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
