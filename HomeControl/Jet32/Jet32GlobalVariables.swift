//
//  Jet32GlobalVariables.swift
//  HomeControl
//
//  Created by Joachim Kittelberger on 08.06.17.
//  Copyright © 2017 Joachim Kittelberger. All rights reserved.
//

import Foundation

class Jet32GlobalVariables {
    
    // flags in PLC. Set the Flags to true and the PLC will do the Commands
    static let flagIsAutomaticBlind = 100
    static let flagIsAutomaticShutter = 101
    
    static let flagCmdAllAutomaticShuttersUp = 102
    static let flagCmdAllAutomaticShuttersDown = 103
    static let flagIsAutomaticSummerMode = 104
    static let flagCmdAllAutomaticShuttersDownSummerPos = 105
    static let flagCmdAllAutomaticShuttersUpSummerPos = 106

    static let flagIsSaunaOn = 107
    
    static let flagUseSunsetSettings = 108
    
    
    // registers for controlling the settings
    static let regCurrentStateNightDay = 1000100    // state for eDayState (day = 0, night = 1)
    static let regCurrentStateWind = 1000101       // ToHighDetected = 0, ToHighState = 1, LowDetected = 2, LowState = 3
    static let regCurrentStateLight = 1000102      // OnDetected = 0, OnState = 1, OffDetected = 2, OffState = 3
    
    static let regUpTimeHour = 1000110
    static let regUpTimeMinute = 1000111
    static let regDownTimeHour = 1000112
    static let regDownTimeMinute = 1000113
    
    static let regUpTimeHourWeekend = 1000114
    static let regUpTimeMinuteWeekend = 1000115
    
    static let regSunsetHourForToday = 1000122
    static let regSunsetMinuteForToday = 1000123
    static let regSunsetOffsetInMin = 1000124
    
    
    // registers for RealTimeClock in Jetter PLC
    static let regHour = 102913
    static let regMinute = 102912
    static let regSecond = 102911
    
    static let regYear = 102917
    static let regMonth = 102916
    static let regDay = 102915

}
