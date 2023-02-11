//
//  ITPhoneNumberTextField.swift
//  me&us
//
//  Created by Federico on 04/02/23.
//

import UIKit
import PhoneNumberKit

class ITPhoneNumberTextField: PhoneNumberTextField {
    override var defaultRegion: String {
        get {
            return "IT"
        }
        set {} // exists for backward compatibility
    }
}
