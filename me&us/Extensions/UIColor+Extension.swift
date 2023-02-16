//
//  UIColor+Extension.swift
//  me&us
//
//  Created by Federico on 02/02/23.
//

import UIKit

extension UIColor {
    static let primaryDarkText: UIColor = .init(hex: "#1F2021")
    static let secondaryDarkText: UIColor = .init(hex: "#5D5A57")
    
    static let primaryLightText: UIColor = .init(hex: "#D9D9D9")
    static let secondaryLightText: UIColor = .init(hex: "#A9A9A9")
    
    static let primaryBackground: UIColor = .init(hex: "#1F2021")
    static let secondaryBackground: UIColor = .init(hex: "#2A2B2F")
    
    static let primaryHighlight: UIColor = .init(hex: "#FFC627")
    
    static let darkLiver: UIColor = .init(hex: "#454549")
    static let dimGray: UIColor = .init(hex: "#6A6A6A")
    static let quickSilver: UIColor = .init(hex: "#A7A7A7")
    static let bluePurple: UIColor = .init(hex: "#A3B7FF")
    static let lightSalmon: UIColor = .init(hex: "#F89D7C")
    static let mellowApricot: UIColor = .init(hex: "#F8BC7E")
    static let floralWhite: UIColor = .init(hex: "#FCF6EF")
    static let ivory: UIColor = .init(hex: "#FCFDF3")
    
    convenience init(hex: String) {
            var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
            hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

            var rgb: UInt64 = 0

            var r: CGFloat = 0.0
            var g: CGFloat = 0.0
            var b: CGFloat = 0.0
            var a: CGFloat = 1.0

            let length = hexSanitized.count

        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else {
            self.init(red: 0, green: 0, blue: 0, alpha: 1)
            return
        }

            if length == 6 {
                r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
                g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
                b = CGFloat(rgb & 0x0000FF) / 255.0

            } else if length == 8 {
                r = CGFloat((rgb & 0xFF000000) >> 24) / 255.0
                g = CGFloat((rgb & 0x00FF0000) >> 16) / 255.0
                b = CGFloat((rgb & 0x0000FF00) >> 8) / 255.0
                a = CGFloat(rgb & 0x000000FF) / 255.0

            } else {
                self.init(red: 0, green: 0, blue: 0, alpha: 1)
                return
            }

        self.init(red: r, green: g, blue: b, alpha: a)
    }

}
