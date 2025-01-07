//
//  HomeControlWidgetEntryView.swift
//  HomeControlWidgetExtension
//
//  Created by Joachim Kittelberger on 24.01.24.
//  Copyright © 2024 Joachim Kittelberger. All rights reserved.
//

import SwiftUI
import WidgetKit


// Anzeige: Sonne/Dunkel - Wind/Kein Wind
// TODO use SF-Symbols for State

struct HomeControlWidgetEntryView : View {
    var entry: Provider.Entry

    //@Environment(\.widgetRenderingMode) var renderingMode
    @Environment(\.widgetFamily) var widgetFamily
    @Environment(\.isLuminanceReduced) var isLuminanceReduced
    
    
    var body: some View {
/*        VStack {
            HStack {
                Text("Time:")
                Text(entry.date, style: .time)
            }
            Text(entry.configuration.favoriteEmoji)
        }
  */
/*
        switch renderingMode {
        case .fullColor:
            Text("Testf")
        case .accented:
            Text("Testa")
        case .vibrant:
            Text("Testv")
        }
*/

        switch widgetFamily {
        case .accessoryCircular:
            ZStack {
                AccessoryWidgetBackground()
                HStack {
                    //Image("HomeControlIcon")
                    Image(systemName: "house")
                        .resizable()
                        .scaledToFit()
                        .widgetAccentable()
                        .foregroundColor(.blue)
                    // Evtl. Gauge-View für Tag/Nacht
                }
            }
        case .accessoryCorner:
            ZStack {
                AccessoryWidgetBackground()
                HStack {
                    Image(systemName: "house")
                    //.resizable()
                        .scaleEffect(CGSize(width: 1.5, height: 1.5))
                        .scaledToFit()
                        .widgetAccentable()
                        .foregroundColor(.blue)
                    //Text("Home")
                    //    .widgetAccentable()
                }
            }

        case .accessoryInline:
            ZStack {
                AccessoryWidgetBackground()
                HStack {
                    Image(systemName: "house")
                        .widgetAccentable()
                        .foregroundColor(.blue)

                    Text("HomeControl")
                        .widgetAccentable()
                }
            }
        case .accessoryRectangular:
            ZStack {
                //AccessoryWidgetBackground()       // Problem: Erzeugt ein runden Kreis in Bildmitte
                HStack {
                    Spacer()
                    Image(systemName: "house")
                        //.resizable()
                        //.scaledToFit()
                        .scaleEffect(CGSize(width: 1.5, height: 1.5))
                        .widgetAccentable()
                        .foregroundColor(.blue)
                    VStack(alignment: .leading) {
                        Text("HomeControl")
                            .font(.headline)
                            .widgetAccentable()
                            .foregroundColor(.blue)

                        if isLuminanceReduced {
                            // Hier sollte die Kommunikation reduziert werden
                            Text(entry.currentStateLight.description)
                                .font(.body)
                                .privacySensitive()     // wird im HomeScreen nur schemenhaft dargestellt
                        } else {
                            Text(entry.currentStateLight.description)
                                .font(.body)
                                .privacySensitive()     // wird im HomeScreen nur schemenhaft dargestellt
                        }

                        if isLuminanceReduced {
                            // Hier sollte die Kommunikation reduziert werden
                            Text(entry.currentStateWind.description)
                                .font(.body)
                                .privacySensitive()     // wird im HomeScreen nur schemenhaft dargestellt
                        } else {
                            Text(entry.currentStateWind.description)
                                .font(.body)
                                .privacySensitive()     // wird im HomeScreen nur schemenhaft dargestellt
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                }
                //.padding()
            }
        default:
            Text("Unknown Family: \(widgetFamily.description)")
        }
    }
 
    
    
}




