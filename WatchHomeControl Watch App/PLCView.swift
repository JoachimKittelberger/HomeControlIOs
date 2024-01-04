//
//  PLCView.swift
//  WatchHomeControl Watch App
//
//  Created by Joachim Kittelberger on 27.12.23.
//  Copyright © 2023 Joachim Kittelberger. All rights reserved.
//

import SwiftUI



struct PLCView: View {
    
    var body: some View {
        NavigationStack {
            Text("Steuerung-Seite")
                .navigationTitle("Steuerung")
//                .navigationBarTitleDisplayMode(.inline)
                .navigationBarTitleDisplayMode(.large)
            
        }
    }
}




#Preview {
    return PLCView()
}

