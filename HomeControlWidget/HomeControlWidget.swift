//
//  HomeControlWidget.swift
//  HomeControlWidget
//
//  Created by Joachim Kittelberger on 24.01.24.
//  Copyright © 2024 Joachim Kittelberger. All rights reserved.
//


// Um das Widget zum neuladen von der WatchApp aus zu triggern muss dort einfach
// DispatchQueue.global().async {
//     WidgetCenter.shared.reloadTimelines(ofKind: "HomeControlWidget") in der main-Queue
// }
// aufgerufen werden





import WidgetKit
import SwiftUI

// wenn wir mehrere Widgets in einer App verwenden wollen, benötgien wir ein Bundle
// damit können unterschiedliche Widgets mit unterschiedlichen Views, TimelineProvider und TimelineEntry
// in einer WidgetExtension benutzt werden
@main       // if we use a WidgetBundle, @main must be at the bundle otherwise at the Widget
struct HomeControlWidgetBundle: WidgetBundle {
    @WidgetBundleBuilder
    var body: some Widget {
        HomeControlWidget()
        // next Widget
    }
}




//@main       // if we use a WidgetBundle, @main must be at the bundle otherwise at the widget
struct HomeControlWidget: Widget {
    let kind: String = "HomeControlWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            HomeControlWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("KibeSoft HomeControl")
        .description("Handle the HomeControl of KibeSoft")
#if os(watchOS)
        .supportedFamilies([.accessoryCircular, .accessoryInline, .accessoryRectangular, .accessoryCorner])
#else
        // for support in iOS
        .supportedFamilies([.accessoryCircular, .accessoryInline, .accessoryRectangular, .systemSmall, .systemMedium])
#endif
    }
}






extension ConfigurationAppIntent {
    fileprivate static var smiley: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        //intent.favoriteEmoji = "😀"
        return intent
    }
    
    fileprivate static var starEyes: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        //intent.favoriteEmoji = "🤩"
        return intent
    }
}







#Preview(as: .accessoryRectangular) {
    HomeControlWidget()
} timeline: {
    HomeControlEntry(date: .now, configuration: .smiley, currentStateLight: .hellerkannt, currentStateWind: .zuvielwind)
    HomeControlEntry(date: .now, configuration: .starEyes, currentStateLight: .dunkel, currentStateWind: .keinwind)
}

#Preview(as: .accessoryCircular) {
    HomeControlWidget()
} timeline: {
    HomeControlEntry(date: .now, configuration: .smiley, currentStateLight: .hellerkannt, currentStateWind: .zuvielwind)
    HomeControlEntry(date: .now, configuration: .starEyes, currentStateLight: .dunkel, currentStateWind: .keinwind)
}

#Preview(as: .accessoryInline) {
    HomeControlWidget()
} timeline: {
    HomeControlEntry(date: .now, configuration: .smiley, currentStateLight: .hellerkannt, currentStateWind: .zuvielwind)
    HomeControlEntry(date: .now, configuration: .starEyes, currentStateLight: .dunkel, currentStateWind: .keinwind)
}

#Preview(as: .accessoryCorner) {
    HomeControlWidget()
} timeline: {
    HomeControlEntry(date: .now, configuration: .smiley, currentStateLight: .hellerkannt, currentStateWind: .zuvielwind)
    HomeControlEntry(date: .now, configuration: .starEyes, currentStateLight: .dunkel, currentStateWind: .keinwind)
}
