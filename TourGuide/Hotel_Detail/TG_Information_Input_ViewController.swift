//
//  TG_Information_Input_ViewController.swift
//  TourGuide
//
//  Created by Thanh Hai Tran on 8/22/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

import TKFormTextField

import MarqueeLabel

protocol InputDelegate:class {
    func inputDidNavigationBack(infor: NSDictionary)
}

class TG_Information_Input_ViewController: UIViewController, UITextFieldDelegate {

    weak var inputDelegate: InputDelegate?
    
    @IBOutlet var titleLabel: MarqueeLabel!
    
    @IBOutlet var tableView: UITableView!
    
    @IBOutlet var bottomCell: UITableViewCell!
    
    @IBOutlet var midCell: UITableViewCell!

    var detailInfo: NSMutableDictionary!
    
    var dataInfo: NSMutableDictionary!
    
    @IBOutlet var alert: NSLayoutConstraint!
    
    @IBOutlet var topTitle: UILabel!
    
    var kb: KeyBoard!
    
    let titles = ["Thông tin chủ thẻ", "Thông tin người sử dụng phòng", ""]

    
    override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel.text = detailInfo.response(forKey: "hotel_name") ? detailInfo.getValueFromKey("hotel_name") : "Crystal Holidays"
        
        tableView.withCell("TG_Information_Cell")
        
        tableView.withHeaderOrFooter("TG_Filter_Header")
        
        dataInfo = NSMutableDictionary()
        
        (self.navigationController as! TG_Nav_ViewController).navigationDelegate = self
        
        kb = KeyBoard.shareInstance()
        
        didPrepareData()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        kb.keyboardOff()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        kb.keyboard { (height, isOn) in
            self.tableView.contentInset = UIEdgeInsetsMake(0, 0, isOn ? (height - 50) : 0, 0)
        }
    }
    
    func didPrepareData() {
        
        let temp = NSMutableDictionary()
        
        let userInfo = !logged() ? [:] : INFO()["CustomerBasicInfo"] as! NSDictionary
        
        temp["0"] = [["userName":logged() ? userInfo["UserName"] : "", "email":logged() ? userInfo["Email"] : "", "phone":logged() ? userInfo["PhoneNumber"] : ""], ["userName":logged() ? userInfo["UserName"] : "", "email":logged() ? userInfo["Email"] : "", "phone":logged() ? userInfo["PhoneNumber"] : ""]]
        
        temp["1"] = [["userName":logged() ? userInfo["UserName"] : "", "email":logged() ? userInfo["Email"] : "", "phone":logged() ? userInfo["PhoneNumber"] : ""]]
        
        temp["2"] = [["bonusCode":""]]
        
        dataInfo.addEntries(from: temp.reFormat() as! [AnyHashable : Any])
        
        let cardInfo = !logged() ? [:] : INFO()["CardType"] as! NSDictionary

        
        self.alert.constant = logged() ? cardInfo.getValueFromKey("star_level") == detailInfo.getValueFromKey("star_number") ? 0 : 42 : 0
        
        if logged() {
            topTitle.text = "Bạn đang đặt khách sạn có hạng %@ hơn hạng thẻ của mình.".format(parameters: (cardInfo["star_level"] as! Int) > (detailInfo["star_number"] as! Int) ? "nhỏ" : "lớn")
        } else {
            topTitle.text = ""
        }
                
        tableView.reloadData()
    }
    
    @IBAction func didPressBack() {
        self.navigationController?.popViewController(animated: true)
        
        self.inputDelegate?.inputDidNavigationBack(infor: ["isFavorite":detailInfo["isFavorite"] ?? ""])
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func addTargetForErrorUpdating(_ textField: TKFormTextField) {
        textField.addTarget(self, action: #selector(clearErrorIfNeeded), for: .editingChanged)
        textField.addTarget(self, action: #selector(updateError), for: .editingDidEnd)
    }
    
    @objc func updateError(textField: TKFormTextField) {
        textField.error = validationError(textField)
    }
    
    @objc func clearErrorIfNeeded(textField: TKFormTextField) {
        if validationError(textField) == nil {
            textField.error = nil
        }
    }

    private func validationError(_ textField: TKFormTextField) -> String? {
        
        self.tableView.beginUpdates()
                
        self.tableView.endUpdates()
        
        return TKDataValidator.empty(text: textField.text)
    }
    
    @IBAction func submit(_ sender: Any) {
        self.view.endEditing(true)
        
        if !logged() {
            self.showToast("Hãy đăng nhập để xử dụng tính năng này", andPos: 0)
            
            return
        }
                
        let confirm = TG_Information_Confirm_ViewController()
        
        dataInfo.addEntries(from: detailInfo as! [AnyHashable : Any])
        
        confirm.detailInfo = dataInfo

        self.navigationController?.pushViewController(confirm, animated: true)
    }

    @IBAction func didAddMore() {
        let arrayInput = dataInfo["1"] as! NSMutableArray
        
        let extra = ["userName":"", "email":"", "phone":""]
        
        arrayInput.add((extra as NSDictionary).reFormat())
        
        tableView.reloadData()
    }
    
    @IBAction func didPressLogIn() {
        let nav = TG_Nav_ViewController.init(rootViewController: TG_Login_ViewController())
        
        nav.isNavigationBarHidden = true
        
        nav.navigationDelegate = self
        
        nav.modalPresentationStyle = .fullScreen
        
        self.present(nav, animated: true, completion: {
            
        })
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        
        return true
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if textField.tag == 900 {
            ((dataInfo["2"] as! NSMutableArray)[0] as! NSMutableDictionary)["bonusCode"] = textField.text
        } else {
            let key = textField.tag == 10 ? "userName" : textField.tag == 11 ? "email" : "phone"
            
            ((dataInfo["%@".format(parameters: textField.accessibilityLabel!)] as! NSMutableArray)[Int(textField.accessibilityValue!)!] as! NSMutableDictionary)[key] = textField.text
        }
    }
}

extension TG_Information_Input_ViewController: NavigationDelegate {
    
    func didNavigationBack(infor: NSDictionary) {
        
        if infor.response(forKey: "isFavorite") {
            detailInfo["isFavorite"] = infor["isFavorite"]
        } else {
            if !logged() {
                return
            }
            
            let userInfo = INFO()["CustomerBasicInfo"] as! NSDictionary
            
            let mainMember = dataInfo["0"] as! NSArray
            
            for dict in mainMember {
                (dict as! NSMutableDictionary)["userName"] = userInfo["UserName"]
                (dict as! NSMutableDictionary)["email"] = userInfo["Email"]
                (dict as! NSMutableDictionary)["phone"] = userInfo["PhoneNumber"]
            }
            
            let extraMember = dataInfo["1"] as! NSArray
            
            for dict in extraMember {
                (dict as! NSMutableDictionary)["userName"] = userInfo["UserName"]
                (dict as! NSMutableDictionary)["email"] = userInfo["Email"]
                (dict as! NSMutableDictionary)["phone"] = userInfo["PhoneNumber"]
                break
            }
        }
        
        let cardInfo = !logged() ? [:] : INFO()["CardType"] as! NSDictionary

        
        self.alert.constant = logged() ? cardInfo.getValueFromKey("star_level") == detailInfo.getValueFromKey("star_number") ? 0 : 42 : 0
        
        if logged() {
            topTitle.text = "Bạn đang đặt khách sạn có hạng %@ hơn hạng thẻ của mình.".format(parameters: (cardInfo["star_level"] as! Int) > (detailInfo["star_number"] as! Int) ? "nhỏ" : "lớn")
        } else {
            topTitle.text = ""
        }
        
        tableView.reloadData()
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
}

extension TG_Information_Input_ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return titles.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 2 ? CGFloat.leastNormalMagnitude : 33
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let header = Bundle.main.loadNibNamed("TG_Filter_Header", owner: self, options: nil)?.first
        
        (self.withView(header, tag: 22) as! UILabel).text = " %@".format(parameters: titles[section])
        
        (self.withView(header, tag: 22) as! UILabel).isHidden = section == 2
        
        let view = (self.withView(header, tag: 15) as! UIView)
        
        view.alpha = 0
        
        return header as? UIView
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.section == 2 ? 336 : UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 137
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 1 ? (dataInfo["1"] as! NSArray).count : section == 0 ? !logged() ? 2 : 1 : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let arrayInput = dataInfo["%i".format(parameters: indexPath.section)] as! NSMutableArray
        
        let dataInput = arrayInput[indexPath.row] as! NSMutableDictionary
        
        if indexPath.section == 2 {
            
            let start = Information.start /*detailInfo["start"]*/ as! Date
            
            let end = Information.end /*detailInfo["end"]*/ as! Date

            
            let startDate = self.withView(bottomCell, tag: 10) as! UILabel
            
            startDate.text = "%@ Tháng %@".format(parameters: start.dateComp(type: 0), start.dateComp(type: 2))
            
            let startWeekDay = self.withView(bottomCell, tag: 11) as! UILabel
            
            startWeekDay.text = "Thứ %@".format(parameters: start.dateComp(type: 1))
            
            
            
            let endDate = self.withView(bottomCell, tag: 20) as! UILabel
            
            endDate.text = "%@ Tháng %@".format(parameters: end.dateComp(type: 0), end.dateComp(type: 2))
            
            let endWeekDay = self.withView(bottomCell, tag: 21) as! UILabel
            
            endWeekDay.text = "Thứ %@".format(parameters: end.dateComp(type: 1))
            
            let diffInDays = Calendar.current.dateComponents([.day], from: start, to: end).day

            
            let roomNumb = self.withView(bottomCell, tag: 30) as! UILabel

            roomNumb.text = "%i".format(parameters: (detailInfo["roomNumber"] as! Int) * diffInDays!)//"%i".format(parameters: diffInDays!)
            
            

            
            let card = self.withView(bottomCell, tag: 40) as! UILabel
            
            card.text = logged() ? (INFO()["CardType"] as! NSDictionary).getValueFromKey("description") : "Thẻ Family"
            
            let roomType = self.withView(bottomCell, tag: 41) as! MarqueeLabel
            
            roomType.text = (detailInfo["roomType"] as! NSDictionary)["roomName"] as? String
            
            
            

            let roomNight = self.withView(bottomCell, tag: 50) as! UILabel
            
            roomNight.text = "%@ phòng x %i đêm = %i đêm".format(parameters: detailInfo.getValueFromKey("roomNumber"), diffInDays!, (detailInfo["roomNumber"] as! Int) * diffInDays!)
            
            
            let bonus = self.withView(bottomCell, tag: 900) as! UITextField

            bonus.text = dataInput["bonusCode"] as? String
            
            bonus.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
            
            return bottomCell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TG_Information_Cell", for: indexPath)
        
        
//        let arrayInput = dataInfo["%i".format(parameters: indexPath.section)] as! NSMutableArray
//
//        let dataInput = arrayInput[indexPath.row] as! NSMutableDictionary

        
        for view in (cell.contentView.subviews.first?.subviews)! {
            if view.isKind(of: TKFormTextField.self) {
                
                let textField = (view as! TKFormTextField)
                
                textField.delegate = self
                
                textField.accessibilityLabel = "%i".format(parameters: indexPath.section)
                
                textField.accessibilityValue = "%i".format(parameters: indexPath.row)

                if textField.tag == 10 {
                    textField.text = dataInput["userName"] as? String
                }
                
                if textField.tag == 11 {
                    textField.text = dataInput["email"] as? String
                }
                
                if textField.tag == 12 {
                    textField.text = dataInput["phone"] as? String
                    
                    textField.inputAccessoryView = self.toolBar()
                }
                
                textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
            }
        }
        
        
        let delete = self.withView(cell, tag: 15) as! UIButton
        
        delete.isHidden = indexPath.row == 0
        
        delete.action(forTouch: [:]) { (obj) in
            arrayInput.removeObject(at: indexPath.row)
            
            self.tableView.reloadData()
        }
        
        if indexPath.section == 0 && indexPath.row == 1 {
            return midCell
        }
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
}
