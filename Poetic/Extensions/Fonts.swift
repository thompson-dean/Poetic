//
//  Font.swift
//  Poetic
//
//  Created by Dean Thompson on 2022/09/24.
//

import UIKit

struct Fonts {
    var newYorkFont: UIFont {
        let descriptor = UIFont.systemFont(ofSize: 48, weight: .bold).fontDescriptor
        
        if let serif = descriptor.withDesign(.serif) {
            return UIFont(descriptor: serif, size: 0.0)
        }
        return UIFont(descriptor: descriptor, size: 0.0)
    }
    
    var smallNewYorkFont: UIFont {
        let descriptor = UIFont.systemFont(ofSize: 16, weight: .bold).fontDescriptor
        
        if let serif = descriptor.withDesign(.serif) {
            return UIFont(descriptor: serif, size: 0.0)
        }
        return UIFont(descriptor: descriptor, size: 0.0)
    }
}

