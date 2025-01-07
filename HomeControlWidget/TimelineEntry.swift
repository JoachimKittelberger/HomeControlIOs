//
//  TimelineEntry.swift
//  HomeControlWidgetExtension
//
//  Created by Joachim Kittelberger on 25.01.24.
//  Copyright © 2024 Joachim Kittelberger. All rights reserved.
//

import WidgetKit



struct HomeControlEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent

    let currentStateLight: LightState
    let currentStateWind: WindState
}




