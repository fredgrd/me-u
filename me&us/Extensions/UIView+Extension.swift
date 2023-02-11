//
//  UIView+Extension.swift
//  me&us
//
//  Created by Federico on 03/02/23.
//

import UIKit

extension UIView {
    var safeAreaBottom: CGFloat {
            if #available(iOS 11, *) {
                if let window = UIApplication.shared.keyWindow {
                    return window.safeAreaInsets.bottom
                }
            }
            return 0
        }
        
        var safeAreaTop: CGFloat {
            if #available(iOS 11, *) {
                if let window = UIApplication.shared.keyWindow {
                    return window.safeAreaInsets.top
                }
            }
            return 0
        }
}
