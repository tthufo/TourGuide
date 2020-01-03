//
//  TG_Info_ViewController.swift
//  TourGuide
//
//  Created by Mac on 7/24/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

import TKFormTextField

class TG_ChangeInfo_ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var tableView: UITableView!
    
    @IBOutlet var topBar: NSLayoutConstraint!
    
    @IBOutlet var topCell: UITableViewCell!
    
    @IBOutlet var midCell: UITableViewCell!
    
    @IBOutlet var lastCell: UITableViewCell!


    
    @IBOutlet weak var userName: TKFormTextField!
    
    @IBOutlet weak var userEmail: TKFormTextField!
    
    @IBOutlet weak var userPhone: TKFormTextField!
    
    @IBOutlet weak var userAddress: TKFormTextField!

    
    
    @IBOutlet weak var companyName: TKFormTextField!
    
    @IBOutlet weak var taxNumb: TKFormTextField!
    
    @IBOutlet weak var companyAddress: TKFormTextField!
    
    @IBOutlet weak var billAddress: TKFormTextField!
    
    
    @IBOutlet weak var dayButton: DropButton!
    
    @IBOutlet weak var monthButton: DropButton!

    @IBOutlet weak var yearButton: DropButton!


    
    @IBOutlet var maleButton: UIButton!
    
    @IBOutlet var feMaleButton: UIButton!

    
    @IBOutlet var checkEmailButton: UIButton!
    
    @IBOutlet var checkBonusButton: UIButton!
    
    @IBOutlet var submit: UIButton!

    
    var dob: String!
    
    
    var dayList: NSMutableArray!
    
    var monthList: NSMutableArray!

    var yearList: NSMutableArray!

    
    var updateInfo: NSMutableDictionary!
    
    var kb: KeyBoard!
    
    
    
    let titles = ["Thông tin tài khoản", "Thông tin tùy chỉnh", "Thông tin xuất hóa đơn"]


    override func viewDidLoad() {
        
        super.viewDidLoad()

        let tapBackground = UITapGestureRecognizer(target: self, action: #selector(onTapBackground))
        
        self.view.addGestureRecognizer(tapBackground)
        
        tableView.withHeaderOrFooter("TG_Filter_Header")
        
        tableView.contentInset = UIEdgeInsetsMake(20, 0, 40, 0)
                
        
        updateInfo = NSMutableDictionary.init(dictionary: INFO().reFormat())
        
        let userInfo = INFO()["CustomerBasicInfo"] as! NSDictionary

        
        
        dayList = NSMutableArray()
        
        monthList = NSMutableArray()
        
        yearList = NSMutableArray()

        
        
        userName.placeholder = "Họ và Tên"

        userName.text = userInfo["UserName"] as? String
        
        
            
        userEmail.placeholder = "Email"
        
        userEmail.text = userInfo["Email"] as! String

        
        
        userPhone.placeholder = "Số điện thoại"
        
        userPhone.text = userInfo["PhoneNumber"] as! String

        userPhone.inputAccessoryView = self.toolBar()
        
        
        userAddress.placeholder = "Địa chỉ"

        userAddress.text = updateInfo["address"] as? String
        
        
        
        
        companyName.placeholder = "Tên công ty"
        
        companyName.text = updateInfo["company_name"] as? String
        
        
        
        
        taxNumb.placeholder = "Mã số thuế"
        
        taxNumb.text = updateInfo["company_taxcode"] as? String
        
        
        

        companyAddress.placeholder = "Địa chỉ công ty"
        
        companyAddress.text = updateInfo["company_address"] as? String
        
        
        
        
        billAddress.placeholder = "Địa chỉ nhận hóa đơn"
        
        billAddress.text = updateInfo["tax_address"] as? String
        
        
        
        
//        self.addTargetForErrorUpdating(companyName)
//        self.addTargetForErrorUpdating(taxNumb)
//        self.addTargetForErrorUpdating(companyAddress)
//        self.addTargetForErrorUpdating(billAddress)
        
        
        self.addTargetForErrorUpdating(userName)
        self.addTargetForErrorUpdating(userEmail)
        self.addTargetForErrorUpdating(userPhone)
//        self.addTargetForErrorUpdating(userAddress)

        
        didConfig(textField: companyName)
        didConfig(textField: taxNumb)
        didConfig(textField: companyAddress)
        didConfig(textField: billAddress)
        
        didConfig(textField: userName)
        didConfig(textField: userEmail)
        didConfig(textField: userPhone)
        didConfig(textField: userAddress)

        
        
        billAddress.returnKeyType = .done

        userAddress.returnKeyType = .done
        
        userPhone.keyboardType = .phonePad
        
        
        
        userName.accessibilityIdentifier = "email-textfield"
        userEmail.accessibilityIdentifier = "password-textfield"
        userPhone.accessibilityIdentifier = "repassword-textfield"
        userAddress.accessibilityIdentifier = "address-textfield"

        
        companyName.accessibilityIdentifier = "compName-textfield"
        taxNumb.accessibilityIdentifier = "taxNumb-textfield"
        companyAddress.accessibilityIdentifier = "compAddress-textfield"
        billAddress.accessibilityIdentifier = "billAddress-textfield"
        
        
        
        submitEnable(enable: true)

        submit.accessibilityIdentifier = "submit-button"
        
        
        let gender = (updateInfo["gender"] as! String) == "M"
        
        maleButton.setImage(UIImage.init(named: gender ? "check_r_ac" : "check_r_in"), for: .normal)
        
        feMaleButton.setImage(UIImage.init(named: gender ? "check_r_in" : "check_r_ac"), for: .normal)

        
        maleButton.action(forTouch: [:]) { (obj) in
            self.feMaleButton.setImage(UIImage.init(named: "check_r_in"), for: .normal)
            self.maleButton.setImage(UIImage.init(named: "check_r_ac"), for: .normal)
            self.updateInfo["gender"] = "M"
        }
        
        feMaleButton.action(forTouch: [:]) { (obj) in
            self.feMaleButton.setImage(UIImage.init(named: "check_r_ac"), for: .normal)
            self.maleButton.setImage(UIImage.init(named: "check_r_in"), for: .normal)
            self.updateInfo["gender"] = "F"
        }
        
        let subMail = updateInfo.getValueFromKey("email_subscribe") == "1"
        self.checkEmailButton.setImage(UIImage.init(named:subMail ? "check_ac" : "check_in"), for: .normal)

        let subBonus = updateInfo.getValueFromKey("promotion_subscribe") == "1"
        self.checkBonusButton.setImage(UIImage.init(named:subBonus ? "check_ac" : "check_in"), for: .normal)

        checkEmailButton.action(forTouch: [:]) { (obj) in
            self.checkEmailButton.setImage(UIImage.init(named:self.updateInfo.getValueFromKey("email_subscribe") == "0" ? "check_ac" : "check_in"), for: .normal)
            self.updateInfo["email_subscribe"] = self.updateInfo.getValueFromKey("email_subscribe") == "1" ? 0 : 1
        }
        
        checkBonusButton.action(forTouch: [:]) { (obj) in
            self.checkBonusButton.setImage(UIImage.init(named:self.updateInfo.getValueFromKey("promotion_subscribe") == "0" ? "check_ac" : "check_in"), for: .normal)
            self.updateInfo["promotion_subscribe"] = self.updateInfo.getValueFromKey("promotion_subscribe") == "1" ? 0 : 1
        }
        
        kb = KeyBoard.shareInstance()
        
        preConfigDate()
        
        reloadDate()
    }
    
    func toolBar() -> UIToolbar {
        
        let toolBar = UIToolbar.init(frame: CGRect.init(x: 0, y: 0, width: Int(self.screenWidth()), height: 50))
        
        toolBar.barStyle = .default
        
        toolBar.items = [UIBarButtonItem.init(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
                         UIBarButtonItem.init(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
                         UIBarButtonItem.init(title: "Thoát", style: .done, target: self, action: #selector(disMiss))]
        return toolBar
    }
    
    @objc func disMiss() {
        self.view.endEditing(true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        kb.keyboardOff()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.rowHeight = UITableViewAutomaticDimension
        
        kb.keyboard { (height, isOn) in
            self.tableView.contentInset = UIEdgeInsetsMake(20, 0, isOn ? height : 40, 0)
        }
    }
    
    @objc func reloadDate() {
        getDateComponent(type: 2)
        
        getDateComponent(type: 1)
        
        getDateComponent(type: 0)
        
        let day = Int((dayButton.titleLabel?.text?.components(separatedBy: " ").last)!)

        let lastDay = Int((dayList.lastObject as! NSDictionary)["title"] as! String)

        if day! > lastDay! {
            dayButton.setTitle("Ngày %i".format(parameters:lastDay!), for: .normal)
        }
        
        dob = "%@-%@-%@T00:00:00".format(parameters: (yearButton.titleLabel?.text?.components(separatedBy: " ").last)!, (monthButton.titleLabel?.text?.components(separatedBy: " ").last)!, (dayButton.titleLabel?.text?.components(separatedBy: " ").last)!)
    }
    
    @IBAction func didPressYear() {
        yearButton.didDropDown(withData: yearList as! [Any]?) { (obj) in
            if (obj != nil) {
                
                let name = obj as! NSDictionary
                
                self.yearButton.setTitle("Năm %@".format(parameters:((name["data"] as! NSDictionary)["title"] as? String)!), for: .normal)
                
                self.perform(#selector(self.reloadDate), with: nil, afterDelay: 0.3)
            }
        }
        
        self.view.endEditing(true)
    }
    
    @IBAction func didPressMonth() {
        monthButton.didDropDown(withData: monthList as! [Any]?) { (obj) in
            if (obj != nil) {
                
                let name = obj as! NSDictionary
                
                self.monthButton.setTitle("Tháng %@".format(parameters:((name["data"] as! NSDictionary)["title"] as? String)!), for: .normal)
                
                self.perform(#selector(self.reloadDate), with: nil, afterDelay: 0.3)
            }
        }
        
        self.view.endEditing(true)
    }
    
    @IBAction func didPressDay() {
        dayButton.didDropDown(withData: dayList as! [Any]?) { (obj) in
            if (obj != nil) {
                let name = obj as! NSDictionary
                
                self.dayButton.setTitle("Ngày %@".format(parameters:((name["data"] as! NSDictionary)["title"] as? String)!), for: .normal)
                
                self.perform(#selector(self.reloadDate), with: nil, afterDelay: 0.3)
            }
        }
        
        self.view.endEditing(true)
    }
    
    func isLeapYear() -> Bool {
        let year = Int((yearButton.titleLabel?.text?.components(separatedBy: " ").last)!)
        
        return (year! % 4 == 0 && year! % 100 != 0)||(year! % 400 == 0);
    }
    
    func getDays() -> Int {
        let month = Int((monthButton.titleLabel?.text?.components(separatedBy: " ").last)!)
    
        var daysInMonth = 0
        if (month == 4 || month == 6 || month == 9 || month == 11) {
            daysInMonth = 30
        } else if (month == 2) {
            daysInMonth = isLeapYear() ? 29 : 28;
        } else {
            daysInMonth = 31;
        }
        return daysInMonth
    }
    
    func getDateComponent(type: Int) {
        switch type {
        case 0:
            dayList.removeAllObjects()
            for index in 1...getDays() {
                dayList.add(["title":"%i".format(parameters: index)])
            }
            break
        case 1:
            monthList.removeAllObjects()
            for index in 1...12 {
                monthList.add(["title":"%i".format(parameters: index)])
            }
            break
        case 2:
            yearList.removeAllObjects()
            for index in 1950...2010 {
                yearList.add(["title":"%i".format(parameters: index)])
            }
            break
        default: break
            
        }
    }
    
    func preConfigDate() {
        
        let dob = (INFO()["dob"] as! NSString).date(withFormat: "yyyy-MM-dd'T'HH:mm:ss") as Date

        let date = dob //Date()
        let calendar = Calendar.current
        
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        
        dayButton.setTitle("Ngày %i".format(parameters: day), for: .normal)
        
        monthButton.setTitle("Tháng %i".format(parameters: month), for: .normal)

        yearButton.setTitle("Năm %i".format(parameters: year), for: .normal)
    }
    
    
    func didConfig(textField: TKFormTextField) {
        textField.titleLabel.font = UIFont.systemFont(ofSize: 14)
        textField.font = UIFont.systemFont(ofSize: 14)
        textField.errorLabel.font = UIFont.systemFont(ofSize: 12)
        
        textField.enablesReturnKeyAutomatically = true
        textField.returnKeyType = .next
        textField.clearButtonMode = .whileEditing

        textField.delegate = self
    }
    
    func submitEnable(enable: Bool) {
        submit.isEnabled = enable
        submit.alpha = enable ? 1 : 0.4
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
        return validationError(userName) == nil && validationError(userEmail) == nil && validationError(userPhone) == nil
    }
    
    private func validationError(_ textField: TKFormTextField) -> String? {
        return TKDataValidator.empty(text: textField.text)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if (textField == userName) {
            _ = userPhone.becomeFirstResponder()
        }
        else if (textField == userPhone) {
            _ = userAddress.becomeFirstResponder()
        } else if(textField == userAddress) {
            _ = userAddress.resignFirstResponder()
        }
        
        if (textField == companyName) {
            _ = taxNumb.becomeFirstResponder()
        }
        else if (textField == taxNumb) {
            _ = companyAddress.becomeFirstResponder()
        } else if(textField == companyAddress) {
            _ = billAddress.becomeFirstResponder()
        } else if(textField == billAddress) {
            _ = billAddress.resignFirstResponder()
        }
        return true
    }
    
   @IBAction func diđUpdateInfo() {
        
//        let userInfo = INFO()["CustomerBasicInfo"] as! NSDictionary
    
        LTRequest.sharedInstance().didRequestInfo(["absoluteLink":"".urlGet(postFix: "api/User/UpdateInfo"),
                                                   "header":["Authorization":Information.token == nil ? "" : Information.token!],
                                                   "fullname":userName.text,
                                                   "email":userEmail.text,
                                                   "mobile":userPhone.text,
                                                   "crh_point":INFO()["crh_point"],
                                                   "gender":updateInfo["gender"],
                                                   "company_name":companyName.text,
                                                   "company_taxcode":taxNumb.text,
                                                   "company_address":companyAddress.text,
                                                   "tax_address":billAddress.text,
                                                   "email_subscribe":updateInfo.getValueFromKey("email_subscribe") == "1" ? "true" : "false",
                                                   "promotion_subscribe":updateInfo.getValueFromKey("promotion_subscribe") == "1" ? "true" : "false",
                                                   "address":userAddress.text,
                                                   "dob":dob,
                                                   "host":self,
                                                   "overrideLoading":1,
                                                   "overrideAlert":1
            ], withCache: { (cache) in
                
        }) { (response, errorCode, error, isValid) in
            
            if errorCode != "200" {
                self.showToast("Lỗi xảy ra, mời bạn thử lại", andPos: 0)
                
                return
            }
            
            self.showToast((response?.dictionize()["success"] as! Bool) ? "Cập nhật thành công" : "Cập nhật không thành công. Mời bạn thử lại", andPos: 0)

            self.didRefreshUserInfo()
        }
    }
    
    func didRefreshUserInfo() {
        
        if !logged() {
            return
        }
        
        LTRequest.sharedInstance().didRequestInfo(["absoluteLink":"".urlGet(postFix: "api/User/Info"),
                                                   "header":["Authorization":Information.token == nil ? "" : Information.token!],
                                                   "method":"GET",
                                                   "overrideAlert":"1",
                                                   "host":self], withCache: { (cache) in
                                                    
        }) { (response, errorCode, error, isValid) in
            
            if errorCode != "200" {
                return
            }
            
            self.add(response?.dictionize().reFormat() as! [AnyHashable : Any], andKey: "info")
            
            Information.saveInfo()
            
            self.didPressBack()
        }
    }
    
    @IBAction func didPressBack() {
        self.view.endEditing(true)
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func onTapBackground() {
        self.view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}


extension TG_ChangeInfo_ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return titles.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 33
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let header = Bundle.main.loadNibNamed("TG_Filter_Header", owner: self, options: nil)?.first
        
        (self.withView(header, tag: 22) as! UILabel).text = "   %@".format(parameters: titles[section])
        
        (self.withView(header, tag: 22) as! UILabel).backgroundColor = UIColor.clear
        
        let view = (self.withView(header, tag: 15) as! UIView)
        
        view.alpha = 0
        
        return header as? UIView
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
           let drop = self.withView(topCell, tag: 999) as! DropButton
            
            drop.action(forTouch: [:]) { (obj) in
                drop.didDropDown(withData: [["title":"Thành phố 1"],["title":"Thành phố 1"]]) { (objc) in
                    
                    if (objc != nil) {
                    
                        let name = objc as! NSDictionary
                        
                        drop.setTitle((name["data"] as! NSDictionary)["title"] as? String, for: .normal)
                    }
                }
            }
        }
        
        return indexPath.section == 0 ? topCell : indexPath.section == 1 ? midCell : lastCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
}
