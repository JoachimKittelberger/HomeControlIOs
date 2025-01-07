//
//  Provider.swift
//  HomeControlWidgetExtension
//
//  Created by Joachim Kittelberger on 24.01.24.
//  Copyright © 2024 Joachim Kittelberger. All rights reserved.
//

//import Foundation
import SwiftUI
import WidgetKit



struct Provider: AppIntentTimelineProvider {
    // Platzhalter, bis das Widget geladen wurde. Wird z.B. angezeigt, wenn der Benutzer ein Widget hinzufügt
    func placeholder(in context: Context) -> HomeControlEntry {
        HomeControlEntry(date: Date(), configuration: ConfigurationAppIntent(), currentStateLight: .dunkel, currentStateWind: .keinwind)
    }

    // ist die aktuelle Version des Widgets. Wird bei Hinzufügen eines Widgets angezeigt
    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> HomeControlEntry {
        //if (context.isPreview) {
        //}
        
        createTimelineEntry(date: Date(), configuration: configuration)
        //HomeControlEntry(date: Date(), configuration: configuration, currentStateLight: .hell, currentStateWind: .zuvielwind)
    }
    
    // um das Widget zu updaten
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<HomeControlEntry> {
        return createTimeline(date: Date(), configuration: configuration)
    }

    
    func recommendations() -> [AppIntentRecommendation<ConfigurationAppIntent>] {
        // Create an array with all the preconfigured widgets to show.
        [AppIntentRecommendation(intent: ConfigurationAppIntent(), description: "KibeSoft HomeControlWidget")]
    }
    
        
    
    // Erzeuge einen Eintrag mit den aktuellen Daten
    func createTimelineEntry(date: Date, configuration: ConfigurationAppIntent) -> HomeControlEntry {
        // TODO: hier aktuellen Wert für Wind und Light besorgen
        // Use AppGroups
        // Use if let userDefaults = UserDefaults(suitName: nameOfAppGroup) {
        //  userDefaults.set("test 1" as AnyObject, forKey: "key1")
        //  let value1 = userDefaults.string(forKey: "key1")
        // }
        
        // hier die userdefaults der Gruppe lesen
        //let defaults = UserDefaults(suiteName: "group.de.jetter.HomeControl")
        //let value = defaults?.string(forKey: "myKeyString") ?? "No String"

        
        return HomeControlEntry(date: date, configuration: configuration, currentStateLight: .hell, currentStateWind: .zuvielwind)
        // create the HomeControlEntry
    }
    
    
    // Erzeuge einen Timeline-Eintrag mit den aktuellen Daten
    func createTimeline(date: Date, configuration: ConfigurationAppIntent) -> Timeline<HomeControlEntry> {
/*
        // Hier könnten verschiedene TimelineEntrys erzeugt werden mit den Infos, die das Widget dann zu der angegebenen Zeit
        // anzeigen soll. Wird dann automatisch geladen. Z.B. für Kalendereinträge ...
        var entries: [HomeControlEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = HomeControlEntry(date: entryDate, configuration: configuration, currentStateLight: .hell, currentStateWind: .keinwind)
            entries.append(entry)
        }
        return Timeline(entries: entries, policy: .atEnd)
*/

         
        let entry = createTimelineEntry(date: date, configuration: configuration)
        return Timeline(entries: [entry], policy: .atEnd)
    }
    
    
}
