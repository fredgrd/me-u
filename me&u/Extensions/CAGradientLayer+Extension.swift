//
//  CAGradientLayer+Extension.swift
//  me&us
//
//  Created by Federico on 15/02/23.
//

import UIKit

extension CAGradientLayer {
    
    enum GradientStyle {
        case fadingMask
    }
    
    static func gradientLayer(for style: GradientStyle, in frame: CGRect) -> Self {
        let layer = Self()
        layer.colors = colors(for: style)
        layer.frame = frame
        return layer
    }
    
    private static func colors(for style: GradientStyle) -> [CGColor] {
        let beginColor: UIColor
        let endColor: UIColor
        
        switch style {
        case .fadingMask:
            beginColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 1)
            endColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0)
        }
        return [beginColor.cgColor, endColor.cgColor]
    }
}
