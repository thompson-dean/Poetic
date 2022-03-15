//
//  Color.swift
//  Poetic
//
//  Created by Dean Thompson on 2022/03/15.
//

import Foundation


import Foundation
import SwiftUI

extension Color {
    
  init(_ hex: UInt, alpha: Double = 1) {
    self.init(
      .sRGB,
      red: Double((hex >> 16) & 0xFF) / 255,
      green: Double((hex >> 8) & 0xFF) / 255,
      blue: Double(hex & 0xFF) / 255,
      opacity: alpha
    )
  }
}

struct Colors {
    let lightPink = Color(0xFFF7FD)
    
}
