//
//  View+onViewDidLoad.swift
//  WatchHomeControl Watch App
//
//  Created by Joachim Kittelberger on 27.12.23.
//  Copyright © 2023 Joachim Kittelberger. All rights reserved.
//

// Ergänzt die View um einen Modifier .onViewDidLoad.
// funktioniert sowohl unter iOS als auch unter watchOS
// wird aber erst nach .omAppear einmal aufgerufen


import SwiftUI


// ViewDidLoadModifier
struct ViewDidLoadModifier: ViewModifier {
    @State private var viewDidLoad = false
    let action: (() -> Void)?
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                if viewDidLoad == false {
                    viewDidLoad = true
                    action?()
                }
            }
    }
}


// Make it available in View
extension View {
    func onViewDidLoad(perform action: (() -> Void)? = nil) -> some View {
        self.modifier(ViewDidLoadModifier(action: action))
    }
}

// use it with .onViewDidLoad { }


