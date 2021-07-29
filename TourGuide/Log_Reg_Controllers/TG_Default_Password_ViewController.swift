//
//  TG_Default_Password_ViewController.swift
//  TourGuide
//
//  Created by Thanh Hai Tran on 9/12/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

import TKFormTextField

class TG_Default_Password_ViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var tableView: UITableView!
    
    @IBOutlet var topCell: UITableViewCell!
        
    
    @IBOutlet weak var oldpassword: TKFormTextField!
    
    @IBOutlet weak var password: TKFormTextField!
    
    @IBOutlet weak var submit: UIButton!
    
    var code: String!
    
    var info: String!

    var userName: String!

    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        oldpassword.placeholder = "Mật khẩu mới"
        oldpassword.enablesReturnKeyAutomatically = true
        oldpassword.returnKeyType = .next
        oldpassword.clearButtonMode = .whileEditing
        oldpassword.delegate = self
        oldpassword.isSecureTextEntry = true
        
        password.placeholder = "Nhập lại mật khẩu mới"
        password.enablesReturnKeyAutomatically = true
        password.returnKeyType = .next
        password.clearButtonMode = .whileEditing
        password.delegate = self
        password.isSecureTextEntry = true
        
     
        self.addTargetForErrorUpdating(oldpassword)
        self.addTargetForErrorUpdating(password)
        

        oldpassword.titleLabel.font = UIFont.systemFont(ofSize: 14)
        oldpassword.font = UIFont.systemFont(ofSize: 14)
        oldpassword.errorLabel.font = UIFont.systemFont(ofSize: 12)
        password.titleLabel.font = UIFont.systemFont(ofSize: 14)
        password.font = UIFont.systemFont(ofSize: 14)
        password.errorLabel.font = UIFont.systemFont(ofSize: 12)

        
        submitEnable(enable: false)
        
        oldpassword.accessibilityIdentifier = "oldpassword-textfield"
        password.accessibilityIdentifier = "password-textfield"
        
        submit.accessibilityIdentifier = "submit-button"
        
        let tapBackground = UITapGestureRecognizer(target: self, action: #selector(onTapBackground))
        self.view.addGestureRecognizer(tapBackground)
        
        tableView.withHeaderOrFooter("TG_Filter_Header")
        
        tableView.contentInset = UIEdgeInsetsMake(10, 0, 0, 0)
        
        print(code)
    }
    
    func submitEnable(enable: Bool) {
        submit.isEnabled = enable
        submit.alpha = enable ? 1 : 0.4
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
        return validationError(oldpassword) == nil && validationError(password) == nil
    }
    
    private func validationError(_ textField: TKFormTextField) -> String? {
        if textField.tag == 15 {
            return TKDataValidator.password(text: textField.text)
        }
        if textField.tag == 11 {
            return TKDataValidator.rePassword(text: textField.text, pass: oldpassword.text)
        }
        return nil
    }
    
    @IBAction func submit(_ sender: Any) {
        
        self.view.endEditing(true)
        
        didRequestChangePass()
    }
    
    @IBAction func didPressBack() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func didRequestChangePass() {
        let infoPlist = self.infoPlist()
        
        let host = (infoPlist! as NSDictionary).getValueFromKey("hostPort")
        
        let dict = NSMutableDictionary.init();
        
        if (code != "") {
            dict.addEntries(from:["absoluteLink":"".urlGet(postFix: "api/User/ResetPassword"),
                   "header":["Authorization":Information.token == nil ? "" : Information.token!],
                   "code": code,
                   "info": info,
                   "passwd": password.text ?? "",
                   "overrideAlert":1,
                   "overrideLoading":1,
                   "host":self])
        } else {
            dict.addEntries(from:["absoluteLink":"%@/Account/ChangeDefaultPassword".format(parameters: host! as CVarArg),
                    "password": password.text ?? "",
                    "username": userName ?? "",
                    "overrideAlert":1,
                    "overrideLoading":1,
                    "host":self])
        }
        
//        LTRequest.sharedInstance().didRequestInfo(["absoluteLink":"".urlGet(postFix: "api/User/ResetPassword"),
//                                                   "header":["Authorization":Information.token == nil ? "" : Information.token!],
//                                                   "code": code,
//                                                   "info": info,
//                                                   "passwd": password.text ?? "",
//                                                   "overrideAlert":1,
//                                                   "overrideLoading":1,
//                                                   "host":self], withCache: { (cache) in
        
        LTRequest.sharedInstance().didRequestInfo(dict as? [AnyHashable : Any], withCache: { (cache) in
                                                    
        }) { (response, errorCode, error, isValid, header) in
                        
            let isSuccess = response?.dictionize()[ response?.dictionize().response(forKey: "Succeeded") ?? false ? "Succeeded" : "success"] as! Bool
            
            if !isSuccess {
//                self.showToast((response?.dictionize()["errors"] as? Array)?.first, andPos: 0)
                self.showToast("Cập nhật mật khẩu không thành công, mời bạn thử lại", andPos: 0)

                return
            }
            
            self.showToast("Cập nhật mật khẩu thành công", andPos: 0)
            
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if (textField == oldpassword) {
            _ = password.becomeFirstResponder()
        }
        else if (textField == password) {
            _ = password.resignFirstResponder()
        }
        return true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension TG_Default_Password_ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 33
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let header = Bundle.main.loadNibNamed("TG_Filter_Header", owner: self, options: nil)?.first
        
        let head = (self.withView(header, tag: 22) as! UILabel)
        
        head.text = "Hãy nhập lại mật khẩu mới"
        
        head.font = UIFont.italicSystemFont(ofSize: 14)
        
        head.textColor = UIColor.darkText
        
        head.textAlignment = .center
        
        head.backgroundColor = UIColor.clear
        
        let view = (self.withView(header, tag: 15) as! UIView)
        
        view.alpha = 0
        
        return header as? UIView
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 160
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = topCell
        
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

