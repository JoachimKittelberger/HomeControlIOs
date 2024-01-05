//
//  Delivery.swift
//  HomeControl
//
//  Created by Joachim Kittelberger on 05.01.24.
//  Copyright © 2024 Joachim Kittelberger. All rights reserved.
//

import Foundation


enum Delivery {
  /// Deliver immediately. No retries on failure.
  case failable

  /// Deliver as soon as possible. Automatically retries on failure.
  /// All instances of the data will be transferred sequentially.
  case guaranteed

  /// High priority data like app settings. Only the most recent value is
  /// used. Any transfers of this type not yet delivered will be replaced
  /// with the new one.
  case highPriority
}
