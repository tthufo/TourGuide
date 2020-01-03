//
//  TG_Login_ViewController.swift
//  TourGuide
//
//  Created by Mac on 7/19/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

import TKFormTextField


protocol LoginDelegate:class {
    func didReloadData(data: NSDictionary)
}

class TG_Login_ViewController: UIViewController, UITextFieldDelegate {

    weak var delegate: LoginDelegate?

    @IBOutlet var tableView: UITableView!
    
    @IBOutlet var topBar: NSLayoutConstraint!
    
    @IBOutlet var topCell: UITableViewCell!
    
    @IBOutlet weak var email: TKFormTextField!
    
    @IBOutlet weak var password: TKFormTextField!
    
    @IBOutlet weak var submit: UIButton!
    
    @IBOutlet weak var checkEmail: UIImageView!
    
    @IBOutlet weak var checkPassword: UIImageView!
    
    @IBOutlet var registerTitle: UILabel!
    
    @IBOutlet var changePass: UILabel!

    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        email.placeholder = "Mã thẻ thành viên"
        email.enablesReturnKeyAutomatically = true
        email.returnKeyType = .next
        email.clearButtonMode = .whileEditing
        email.delegate = self
        
        email.text = self.getValue("codeId") != nil ? self.getValue("codeId") : ""
        
        password.placeholder = "Mật khẩu"
        password.enablesReturnKeyAutomatically = true
        password.returnKeyType = .done
        password.clearButtonMode = .whileEditing
        password.delegate = self
        password.isSecureTextEntry = true
        
        self.addTargetForErrorUpdating(email)
        self.addTargetForErrorUpdating(password)
        
        
        email.titleLabel.font = UIFont.systemFont(ofSize: 14)
        email.font = UIFont.systemFont(ofSize: 14)
        email.errorLabel.font = UIFont.systemFont(ofSize: 12)
        password.titleLabel.font = UIFont.systemFont(ofSize: 14)
        password.font = UIFont.systemFont(ofSize: 14)
        password.errorLabel.font = UIFont.systemFont(ofSize: 12)
        
        submitEnable(enable: false)
        
        email.accessibilityIdentifier = "email-textfield"
        password.accessibilityIdentifier = "password-textfield"
        submit.accessibilityIdentifier = "submit-button"
        
        let tapBackground = UITapGestureRecognizer(target: self, action: #selector(onTapBackground))
        self.view.addGestureRecognizer(tapBackground)
        
        topBar.constant = iOS_VERSION_GREATER_THAN_OR_EQUAL_TO(version: "11") ? 44 : 64
        
        registerTitle.action(forTouch: [:]) { (obj) in
            self.navigationController?.pushViewController(TG_Register_ViewController(), animated: true)
        }
        
        changePass.action(forTouch: [:]) { (obj) in
            
            let changePass = TG_ChangePass_ViewController()
            
            changePass.isRecover = true
            
            self.navigationController?.pushViewController(changePass, animated: true)
        }
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
        return validationError(email) == nil && validationError(password) == nil
    }

    private func validationError(_ textField: TKFormTextField) -> String? {
        if textField.tag == 10 {
            return TKDataValidator.empty(text: textField.text)
        }
        if textField.tag == 11 {
            return TKDataValidator.password(text: textField.text)
        }
        return nil
    }

    @IBAction func submit(_ sender: Any) {
        self.view.endEditing(true)
        
        self.showSVHUD("Đang tải", andOption: 0)
        
        didAuthorize()
    }

    @IBAction func didPressBack() {
        self.dismiss(animated: true) {
        }
        
        //user().didChangeState(isLogIn: true)
    }

    @IBAction func didPressFace() {
//        FB_Plugin.shareInstance().startLoginFacebook { (response, result, errorCode, description, error) in
//            //print(result)
//        }
    }
    
    @IBAction func didPressGoogle() {
//        GG_PlugIn.shareInstance().startLogGoogle(completion: { (response, result, errorCode, description, error) in
//            //print(result)
//        }, andHost: self)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == email {
            //checkEmail.alpha = 0
        }
        
        if textField == password {
            //checkPassword.alpha = 0
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == email {
            //checkEmail.alpha = validationError(email) == nil ? 1 : 0
        }
        
        if textField == password {
            //checkPassword.alpha = validationError(password) == nil ? 1 : 0
        }
    }

    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if (textField == email) {
            _ = password.becomeFirstResponder()
        }
        else if (textField == password) {
            _ = password.resignFirstResponder()
            if isAllTextFieldsValid() {
                submit(submit)
            }
        }
        return true
    }
    
    func didAuthorize() {
//        let defaultChange = TG_Default_Password_ViewController()
//                
//        defaultChange.info = self.email.text
//        
//        defaultChange.userName = self.email.text
//        
//        self.navigationController?.pushViewController(defaultChange, animated: true)
        
        let infoPlist = self.infoPlist()
        
        let host = (infoPlist! as NSDictionary).getValueFromKey("hostPort")
        
        let config = OIDServiceConfiguration.init(authorizationEndpoint: URL.init(string: "%@/connect/authorize".format(parameters: host! as CVarArg))!, tokenEndpoint: URL.init(string: "%@/connect/token".format(parameters: host! as CVarArg))!)
        
        let token = OIDTokenRequest.init(configuration: config, grantType: "password", authorizationCode: "offline_access openid profile", redirectURL: URL.init(string: "%@/oauth2redirect".format(parameters: host! as CVarArg)), clientID: "crystal.app", clientSecret: "secret", scopes: [OIDScopeOpenID, OIDScopeProfile], refreshToken: "", codeVerifier: "", additionalParameters: ["username":email.text!,"password":password.text!])
        
        OIDAuthorizationService.perform(token) { (response, error) in
            
            if error != nil {
                
                self.hideSVHUD()
                
                self.showToast(self.errorMessage(error: (error?._userInfo as! NSDictionary)["OIDOAuthErrorResponseErrorKey"] as! NSDictionary), andPos: 0)
                
                return
            }
            
            self.addValue(response?.accessToken, andKey: "token")
            
            Information.saveToken()
            
            self.didRequestUserInfo()
        }
    }
    
    func errorMessage(error: NSDictionary) -> String {
        
        print(error)
        
        var err = ""
        
        let eMess = error.getValueFromKey("error_description")
        
        if eMess == "" {
            err = "Lỗi xẩy ra, mời bạn thử lại"
        }
        
        if eMess == "password not match" {
            err = "Mật khẩu không đúng, mời bạn thử lại"
        }
        
        if eMess == "invalid user" {
            err = "Mã thẻ thành viên không đúng, mời bạn thử lại"
        }
        
        if eMess == "await_verify" {
            err = "Tài khoản đang được được kích hoạt, mời bạn thử lại sau"
        }
        
        if eMess == "reset_password" {
            err = "Yêu cầu đổi lại mật khẩu mới"
        }
        
        if eMess == "default_password" {
            err = "Yêu cầu đổi lại mật khẩu mới"
            
            let defaultChange = TG_Default_Password_ViewController()
            
            defaultChange.code = error.getValueFromKey("code")
                        
            defaultChange.info = self.email.text
            
            defaultChange.userName = self.email.text
            
            self.navigationController?.pushViewController(defaultChange, animated: true)
        }

        return err
    }
    
    func didRequestUserInfo() {
        LTRequest.sharedInstance().didRequestInfo(["absoluteLink":"".urlGet(postFix: "api/User/Info"),
                                                   "header":["Authorization":Information.token == nil ? "" : Information.token!],
                                                   "method":"GET",
                                                   "overrideAlert":"1",
                                                   "host":self], withCache: { (cache) in
            
        }) { (response, errorCode, error, isValid) in
            self.hideSVHUD()
            
            if errorCode != "200" {
                self.showToast("Lỗi xảy ra, không thể lấy thông tin người dùng", andPos: 0)
                
                self.removeValue("token")
                
                Information.removeInfo()
                
                return
            }
            
            self.add(response?.dictionize().reFormat() as! [AnyHashable : Any], andKey: "info")
            
            self.addValue(self.email.text, andKey: "codeId")
            
            Information.saveInfo()
            
            (self.parent as! TG_Nav_ViewController).navigationDelegate?.didNavigationBack(infor: [:])
            
            self.didPressBack()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}


extension TG_Login_ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 395
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
