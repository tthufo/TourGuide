//
//  TG_ChangPass_ViewController.swift
//  TourGuide
//
//  Created by Mac on 7/20/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

import TKFormTextField

class TG_ChangePass_ViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var tableView: UITableView!
    
    @IBOutlet var topBar: NSLayoutConstraint!
    
    @IBOutlet var topCell: UITableViewCell!
    
    @IBOutlet var botCell: UITableViewCell!

    
    @IBOutlet weak var email: TKFormTextField!
    
    @IBOutlet weak var oldpassword: TKFormTextField!

    @IBOutlet weak var password: TKFormTextField!
    
    @IBOutlet weak var rePassword: TKFormTextField!
    
    @IBOutlet weak var submit: UIButton!
    
    @IBOutlet weak var submitChange: UIButton!

    @IBOutlet weak var titleLabel: UILabel!

    
    var isRecover: Bool!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        titleLabel.text = isRecover ? "Bạn quên mật khẩu" : "Đổi mật khẩu"
        
        email.placeholder = "Email/Mã thẻ thành viên"
        email.enablesReturnKeyAutomatically = true
        email.returnKeyType = .done
        email.clearButtonMode = .whileEditing
        email.delegate = self
        
        oldpassword.placeholder = "Mật khẩu cũ"
        oldpassword.enablesReturnKeyAutomatically = true
        oldpassword.returnKeyType = .next
        oldpassword.clearButtonMode = .whileEditing
        oldpassword.delegate = self
        oldpassword.isSecureTextEntry = true
        
        password.placeholder = "Mật khẩu mới"
        password.enablesReturnKeyAutomatically = true
        password.returnKeyType = .next
        password.clearButtonMode = .whileEditing
        password.delegate = self
        password.isSecureTextEntry = true

        rePassword.placeholder = "Nhập lại mật khẩu mới"
        rePassword.enablesReturnKeyAutomatically = true
        rePassword.returnKeyType = .done
        rePassword.clearButtonMode = .whileEditing
        rePassword.delegate = self
        rePassword.isSecureTextEntry = true
        
        
        self.addTargetForErrorUpdating(email)
        self.addTargetForErrorUpdating(oldpassword)
        self.addTargetForErrorUpdating(password)
        self.addTargetForErrorUpdating(rePassword)
        
        
        email.titleLabel.font = UIFont.systemFont(ofSize: 14)
        email.font = UIFont.systemFont(ofSize: 14)
        email.errorLabel.font = UIFont.systemFont(ofSize: 12)
        oldpassword.titleLabel.font = UIFont.systemFont(ofSize: 14)
        oldpassword.font = UIFont.systemFont(ofSize: 14)
        oldpassword.errorLabel.font = UIFont.systemFont(ofSize: 12)
        password.titleLabel.font = UIFont.systemFont(ofSize: 14)
        password.font = UIFont.systemFont(ofSize: 14)
        password.errorLabel.font = UIFont.systemFont(ofSize: 12)
        rePassword.titleLabel.font = UIFont.systemFont(ofSize: 14)
        rePassword.font = UIFont.systemFont(ofSize: 14)
        rePassword.errorLabel.font = UIFont.systemFont(ofSize: 12)
        
        submitEnable(enable: false)
        
        email.accessibilityIdentifier = "email-textfield"
        oldpassword.accessibilityIdentifier = "oldpassword-textfield"
        password.accessibilityIdentifier = "password-textfield"
        rePassword.accessibilityIdentifier = "repassword-textfield"
        
        submit.accessibilityIdentifier = "submit-button"
        
        submitChange.accessibilityIdentifier = "submit-button"

        let tapBackground = UITapGestureRecognizer(target: self, action: #selector(onTapBackground))
        self.view.addGestureRecognizer(tapBackground)
        
        topBar.constant = iOS_VERSION_GREATER_THAN_OR_EQUAL_TO(version: "11") ? 44 : 64
        
        tableView.withHeaderOrFooter("TG_Filter_Header")
        
        tableView.contentInset = UIEdgeInsetsMake(10, 0, 0, 0)
        
        submitChange.isHidden = isRecover
    }

    func submitEnable(enable: Bool) {
        if isRecover {
            submit.isEnabled = enable
            submit.alpha = enable ? 1 : 0.4
        } else {
            submitChange.isEnabled = enable
            submitChange.alpha = enable ? 1 : 0.4
        }
    }

    @objc func onTapBackground() {
        self.view.endEditing(true)
    }

    func addTargetForErrorUpdating(_ textField: TKFormTextField) {
        textField.addTarget(self, action: #selector(clearErrorIfNeeded), for: .editingChanged)
        textField.addTarget(self, action: #selector(updateError), for: .editingDidEnd)
    }

    @objc func updateError(textField: TKFormTextField) {
        textField.error = validationError(textField)
        submitEnable(enable: isAllTextFieldsValid())
    }

    @objc func clearErrorIfNeeded(textField: TKFormTextField) {
        if validationError(textField) == nil {
            textField.error = nil
        }
        submitEnable(enable: isAllTextFieldsValid())
    }

    fileprivate func isAllTextFieldsValid() -> Bool {
        return isRecover ? validationError(email) == nil : (validationError(oldpassword) == nil && validationError(password) == nil && validationError(rePassword) == nil)
    }

    private func validationError(_ textField: TKFormTextField) -> String? {
        if textField.tag == 10 {
            return TKDataValidator.empty(text: textField.text)
        }
        if textField.tag == 11 {
            return TKDataValidator.password(text: textField.text)
        }
        if textField.tag == 12 {
            return TKDataValidator.rePassword(text: textField.text, pass: password.text)
        }
        if textField.tag == 15 {
            return TKDataValidator.password(text: textField.text)
        }
        return nil
    }

    @IBAction func submit(_ sender: Any) {
        
        self.view.endEditing(true)
        
        if isRecover {
            didRequestForgotPass()
        } else {
            didRequestChangePass()
        }
    }

    @IBAction func didPressBack() {
        self.navigationController?.popViewController(animated: true)
    }

    func didRequestForgotPass() {

        (CustomField.shareText() as! CustomField).requesting("".urlGet(postFix:"api/User/ForgotPassword"), andInfo: email.text) { (success, objc) in
            if success {
                let err = (objc!["errors"] as! NSArray).firstObject
                if (objc! as NSDictionary).getValueFromKey("success") == "1" {
                    let defaultChange = TG_Default_Password_ViewController()
                    
                    defaultChange.code = (objc! as NSDictionary).getValueFromKey("code")
                    
                    defaultChange.info = self.email.text
                    
                    self.navigationController?.pushViewController(defaultChange, animated: true)
                } else {
                    self.showToast(err as! String, andPos: 0)
                }
            } else {
                self.showToast("Lỗi xảy ra, mời bạn thử lại", andPos: 0)
            }
        }
    }
    
    func didRequestChangePass() {
        LTRequest.sharedInstance().didRequestInfo(["absoluteLink":"".urlGet(postFix: "api/User/ChangePassword"),
                                                   "header":["Authorization":Information.token == nil ? "" : Information.token!],
                                                   "OldPassword": oldpassword.text,
                                                   "Password": password.text,
                                                   "UserName": (INFO()["CustomerBasicInfo"] as! NSDictionary)["UserName"],
                                                   "overrideAlert":1,
                                                   "overrideLoading":1,
                                                   "host":self], withCache: { (cache) in
                                                    
        }) { (response, errorCode, error, isValid, header) in
                        
            if errorCode != "200" {
                self.showToast("Cập nhật mật khẩu thất bại, mời bạn thử lại sau", andPos: 0)

                return
            }
            
            self.showToast("Cập nhật mật khẩu thành công", andPos: 0)
            
            self.didPressBack()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if isRecover {
            if (textField == email) {
                _ = email.resignFirstResponder()
            }
        } else {
            if (textField == oldpassword) {
                _ = password.resignFirstResponder()
            }
            else if (textField == password) {
                _ = rePassword.becomeFirstResponder()
            } else if(textField == rePassword) {
                _ = rePassword.resignFirstResponder()
                if isAllTextFieldsValid() {
                    submit(isRecover ? submit : submitChange)
                }
            }
        }
        return true
    }

    @objc func didPressShowPolicy(gesture: UITapGestureRecognizer) {
        let myLabel = gesture.view as! UILabel
        let text = (myLabel.text)!
        let termsRange = (text as NSString).range(of: "điều khoản dịch vụ")
        if gesture.didTapAttributedTextInLabel(label: myLabel, inRange: termsRange) {
            print("Tapped dịch vụ")
        } else {
            print("Tapped none")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension TG_ChangePass_ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return isRecover ? 33 : CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let header = Bundle.main.loadNibNamed("TG_Filter_Header", owner: self, options: nil)?.first
        
        let head = (self.withView(header, tag: 22) as! UILabel)
        
        head.text = isRecover ? "Vui lòng điền email vào ô bên dưới. Chúng tôi sẽ giúp bạn lấy lại mật khẩu." : ""
        
        head.font = UIFont.italicSystemFont(ofSize: 14)
        
        head.textColor = UIColor.darkText
        
        head.textAlignment = .center
        
        head.backgroundColor = UIColor.clear
        
        let view = (self.withView(header, tag: 15) as! UIView)
        
        view.alpha = 0
        
        return header as? UIView
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return isRecover ? 150 : 220
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = isRecover ? topCell : botCell
        
        let topView = self.withView(cell, tag: 111) as! UIView
        
        topView.layer.shadowColor = UIColor.black.cgColor
        topView.layer.shadowOffset = CGSize(width: 1, height: 1)
        topView.layer.shadowOpacity = 0.2
        topView.layer.shadowRadius = 2.0
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
}

