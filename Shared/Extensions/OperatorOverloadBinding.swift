//
//  OperatorOverloadBinding.swift
//  HomeControl
//
//  Created by Joachim Kittelberger on 11.01.24.
//  Copyright © 2024 Joachim Kittelberger. All rights reserved.
//

import SwiftUI


// if we need Binding with an optional, use this operator ?? overload
// https://stackoverflow.com/questions/57021722/swiftui-optional-textfield/61002589#61002589
// example: @State private var test: String?
// TextField("", text: $test ?? "default value")

func ??<T>(lhs: Binding<Optional<T>>, rhs: T) -> Binding<T> {
    Binding(
        get: { lhs.wrappedValue ?? rhs },
        set: { lhs.wrappedValue = $0 }
    )
}
