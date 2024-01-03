//
//  SettingsView.swift
//  WatchHomeControl Watch App
//
//  Created by Joachim Kittelberger on 27.12.23.
//  Copyright © 2023 Joachim Kittelberger. All rights reserved.
//

import SwiftUI



struct SettingsView: View {
    
    var body: some View {
        NavigationStack {
            Text("Einstellungen-Seite")
                .navigationTitle("Einstellungen")
//                .navigationBarTitleDisplayMode(.inline)
                .navigationBarTitleDisplayMode(.large)
        }
    }
}


#Preview {
    return SettingsView()
}
