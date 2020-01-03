//
//  TKDataValidator.swift
//  TKFormTextFieldDemo
//
//  Created by Thongchai Kolyutsakul on 1/1/17.
//  Copyright © 2017 Viki. All rights reserved.
//

import Foundation

// Stores functions that validates input text.
// Each function takes a text.
// Returns an error string if that text is invalid, or nil if valid.
class TKDataValidator {
  class func email(text: String?) -> String? {
    guard let text = text, !text.isEmpty else {
      return "Email không được để trống"
    }
    guard text.tk_isValidEmail() else {
      return "Email không hợp lệ"
    }
    return nil
  }
  
    class func empty(text: String?) -> String? {
        guard let text = text, !text.isEmpty else {
            return "Thông tin không được để trống"
        }
        return nil
    }
    
  class func password(text: String?) -> String? {
    guard let text = text, !text.isEmpty else {
      return "Mật khẩu không được để trống"
    }
    guard text.characters.count >= 6  else {
        return "Mật khẩu phải có 6 ký tự"
    }
    return nil
  }
    
    class func rePassword(text: String?, pass: String?) -> String? {
        guard let text = text, !text.isEmpty else {
            return "Mật khẩu không được để trống"
        }
        guard text.characters.count >= 6  else {
            return "Mật khẩu phải có 6 ký tự"
        }
        guard text == pass  else {
            return "Mật khẩu không trùng"
        }
        return nil
    }
}

private extension String {
  func tk_isValidEmail() -> Bool {
    let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
    let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegex)
    return emailTest.evaluate(with: self)
  }
}
