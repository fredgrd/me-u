//
//  UIFont+Extension.swift
//  me&us
//
//  Created by Federico on 04/02/23.
//

import UIKit

public extension UIFont {
    
    var rounded: UIFont {
        guard let desc = self.fontDescriptor.withDesign(.rounded)
        else { return self }
        return UIFont(descriptor: desc, size: self.pointSize)
    }
    
    static func font(ofSize size: CGFloat, weight: Weight, descriptor: UIFontDescriptor.SystemDesign = .rounded) -> UIFont {
        let sysFont = UIFont.systemFont(ofSize: size, weight: weight)
        sysFont.fontDescriptor.withDesign(descriptor)
        
        return sysFont
    }
}
