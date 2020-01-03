//
//  TG_Register_ViewController.swift
//  TourGuide
//
//  Created by Mac on 7/20/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

import TKFormTextField

class TG_Register_ViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var tableView: UITableView!
    
    @IBOutlet var topBar: NSLayoutConstraint!
    
    @IBOutlet var topCell: UITableViewCell!
    
    @IBOutlet weak var email: TKFormTextField!
    
    @IBOutlet weak var password: TKFormTextField!
    
    @IBOutlet weak var rePassword: TKFormTextField!

    @IBOutlet weak var submit: UIButton!
    
    @IBOutlet weak var checkEmail: UIImageView!
    
    @IBOutlet weak var checkPassword: UIImageView!
    
    @IBOutlet weak var checkRePassword: UIImageView!

    @IBOutlet weak var back: UIButton!

    
    @IBOutlet var policy: UILabel!
    
    @IBOutlet var registerTitle: UILabel!
    
    var isPresent: Bool = false
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        back.setImage(UIImage.init(named: isPresent ? "x" : "back_a"), for: .normal)
        
        email.placeholder = "Email"
        email.enablesReturnKeyAutomatically = true
        email.returnKeyType = .next
        email.clearButtonMode = .whileEditing
        email.delegate = self
        
        
        password.placeholder = "Mật khẩu"
        password.enablesReturnKeyAutomatically = true
        password.returnKeyType = .next
        password.clearButtonMode = .whileEditing
        password.delegate = self
        password.isSecureTextEntry = true
        
        rePassword.placeholder = "Nhập lại mật khẩu"
        rePassword.enablesReturnKeyAutomatically = true
        rePassword.returnKeyType = .done
        rePassword.clearButtonMode = .whileEditing
        rePassword.delegate = self
        rePassword.isSecureTextEntry = true
        
        
        self.addTargetForErrorUpdating(email)
        self.addTargetForErrorUpdating(password)
        self.addTargetForErrorUpdating(rePassword)

        
        email.titleLabel.font = UIFont.systemFont(ofSize: 14)
        email.font = UIFont.systemFont(ofSize: 14)
        email.errorLabel.font = UIFont.systemFont(ofSize: 12)
        password.titleLabel.font = UIFont.systemFont(ofSize: 14)
        password.font = UIFont.systemFont(ofSize: 14)
        password.errorLabel.font = UIFont.systemFont(ofSize: 12)
        
        submitEnable(enable: false)
        
        email.accessibilityIdentifier = "email-textfield"
        password.accessibilityIdentifier = "password-textfield"
        rePassword.accessibilityIdentifier = "repassword-textfield"

        submit.accessibilityIdentifier = "submit-button"
        
        let tapBackground = UITapGestureRecognizer(target: self, action: #selector(onTapBackground))
        self.view.addGestureRecognizer(tapBackground)
        
        topBar.constant = iOS_VERSION_GREATER_THAN_OR_EQUAL_TO(version: "11") ? 44 : 64
        
        registerTitle.action(forTouch: [:]) { (obj) in
            self.navigationController?.popViewController(animated: true)
        }
        
        let gesture = UITapGestureRecognizer.init(target: self, action: #selector(didPressShowPolicy(gesture:)))
        
        policy.addGestureRecognizer(gesture)
    }
    
    func submitEnable(enable: Bool) {
        submit.isEnabled = enable
        submit.alpha = enable ? 1 : 0.4
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.rowHeight = UITableViewAutomaticDimension
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
        return validationError(email) == nil && validationError(password) == nil && validationError(rePassword) == nil
    }
    
    private func validationError(_ textField: TKFormTextField) -> String? {
        if textField.tag == 10 {
            return TKDataValidator.email(text: textField.text)
        }
        if textField.tag == 11 {
            return TKDataValidator.password(text: textField.text)
        }
        if textField.tag == 12 {
            return TKDataValidator.rePassword(text: textField.text, pass: password.text)
        }
        return nil
    }
    
    @IBAction func submit(_ sender: Any) {
        self.view.endEditing(true)
    }
    
    @IBAction func didPressBack() {
        if isPresent {
            self.dismiss(animated: true) {
                
            }
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func didPressFace() {
//        FB_Plugin.shareInstance().startLoginFacebook { (response, result, errorCode, description, error) in
//            print(result)
//        }
    }
    
    @IBAction func didPressGoogle() {
//        GG_PlugIn.shareInstance().startLogGoogle(completion: { (response, result, errorCode, description, error) in
//            print(result)
//        }, andHost: self)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == email {
            checkEmail.alpha = 0
        }
        
        if textField == password {
            checkPassword.alpha = 0
        }
        
        if textField == rePassword {
            checkRePassword.alpha = 0
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == email {
            checkEmail.alpha = validationError(email) == nil ? 1 : 0
        }
        
        if textField == password {
            checkPassword.alpha = validationError(password) == nil ? 1 : 0
        }
        
        if textField == rePassword {
            checkRePassword.alpha = validationError(rePassword) == nil ? 1 : 0
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if (textField == email) {
            _ = password.becomeFirstResponder()
        }
        else if (textField == password) {
            _ = rePassword.becomeFirstResponder()
        } else if(textField == rePassword) {
            _ = rePassword.resignFirstResponder()
            if isAllTextFieldsValid() {
                submit(submit)
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


extension TG_Register_ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 462
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
