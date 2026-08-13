//
//  PoeticWidgetsBundle.swift
//  PoeticWidgets
//
//  Created by Dean Thompson on 2026/08/11.
//

import WidgetKit
import SwiftUI

@main
struct PoeticWidgetsBundle: WidgetBundle {
    var body: some Widget {
        PoemOfTheDayWidget()
        FavoritesWidget()
    }
}
