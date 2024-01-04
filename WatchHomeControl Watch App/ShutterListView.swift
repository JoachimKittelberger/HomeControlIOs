//
//  ShutterListView.swift
//  WatchHomeControl Watch App
//
//  Created by Joachim Kittelberger on 27.12.23.
//  Copyright © 2023 Joachim Kittelberger. All rights reserved.
//

import SwiftUI



struct ShutterListView: View {
    @EnvironmentObject private var shutterListModel: ShutterList
    
    var body: some View {
        NavigationStack {
            List {
                ForEach($shutterListModel.items) { $item in
                    NavigationLink(destination: ShutterDetailView(shutterItem: item)) {
                        Text(item.name)
                    }
                }
                
                if (shutterListModel.items.isEmpty) {
                    Text("No items found")
                        .foregroundStyle(.gray)
                }
            }
            .navigationTitle("Rolläden")
//            .navigationBarTitleDisplayMode(.inline)
            .navigationBarTitleDisplayMode(.large)
            .listStyle(.elliptical)
        }

    }
}



#Preview {
    let shutterList = ShutterList()
    return ShutterListView()
        .environmentObject(shutterList)
}

