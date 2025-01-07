//
//  AppIntent.swift
//  HomeControlWidget
//
//  Created by Joachim Kittelberger on 24.01.24.
//  Copyright © 2024 Joachim Kittelberger. All rights reserved.
//

import WidgetKit
import AppIntents

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Configuration"
    static var description = IntentDescription("Widget für KibeSoft HomeControl")

    // An example configurable parameter.
    //@Parameter(title: "Favorite Emoji", default: "😃")
    //var favoriteEmoji: String
}



// Beispiel unter: https://www.youtube.com/watch?v=uod_PWE9_Ng
// und unter: https://www.youtube.com/watch?v=E0iOm1_WkJk Aktuell angeschaut bis 2:02:00
// um von Widget zur App zu kommunizieren
// Möglichkeit 1:
// In Widget muss dazu
//Button(intent: HomeControlIntent()) {
//    Image(systemName: "")
//}.buttonStyle(PlainButtonStyle)
// Möglichkeit 2: in WidgetView mit .widgetURL die URL senden zur App z.B. beim Tap auf das Widget
// könnte auch in einen Link(destiantion: url)mit dieser URL gepakt werden. Allerdings geht das nur ohne Optionals)
// und in App mit .onOpenURL() darauf reagieren



struct HomeControlIntent: AppIntent {
    
    static var title: LocalizedStringResource = "Home Control"
    static var description = IntentDescription("Move Blinds")
    
    // handle the action from the widget and get result if finished
    func perform() async throws -> some IntentResult {
        print("The widget was tapped")
        // Hier kann Daten im gemeinsamen Speicher verändert werden
        
        
        // send notification to app if something has changed
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .widgetChangedData, object: nil)
        }
        
        // muss dann in App darauf gehört werden
        //.onReceive(NotificationCenter.default.publisher(for: .widgetChangedData), perform: { _ in
        //    // get the latest Data from common Datas
        //})
        
        
        
        return .result()
    }
    
}


// eigene Notification fpr Widget -> App
extension Notification.Name {
    static let widgetChangedData = Notification.Name("WidgetChangedData")
    
}
