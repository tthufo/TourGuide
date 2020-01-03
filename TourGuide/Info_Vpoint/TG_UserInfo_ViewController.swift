//
//  TG_UserInfo_ViewController.swift
//  TourGuide
//
//  Created by Mac on 7/26/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

class TG_UserInfo_ViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
        
    @IBOutlet var topCell: UITableViewCell!
    
    @IBOutlet var midCell: UITableViewCell!
    
    @IBOutlet var lastCell: UITableViewCell!

    
    let titles = ["Thông tin tài khoản", "Thông tin thẻ", "Thông tin xuất hóa đơn"]

    let header1 = ["Họ và tên:", "Email:", "Số điện thoại:", "Địa chỉ:"]
    
    let key1 = ["UserName", "Email", "PhoneNumber", "Address"]

    let header2 = ["Tên công ty:", "Mã số thuế:", "Địa chỉ công ty:", "Địa chỉ nhận hóa đơn:"]

    let key2 = ["company_name", "company_taxcode", "company_address", "tax_address"]

    let header3 = ["Mã thẻ:", "Loại thẻ:", "Tổng số đêm/năm:", "Số đêm còn lại", "Hạng sao:"]
    
    let key3 = ["cardNumber", "cardInfo", "nightInfo", "remainNight", "starInfo"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.withHeaderOrFooter("TG_Filter_Header")
        
        tableView.withCell("TG_UserInfo_Cell")
        
        tableView.contentInset = UIEdgeInsetsMake(20, 0, 40, 0)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
                
        tableView.rowHeight = UITableViewAutomaticDimension
        
        tableView.reloadData()
    }
    
    @IBAction func didPressBack() {
        self.dismiss(animated: true) {

        }
    }
    
    @IBAction func didPressChangeInfo() {
        self.navigationController?.pushViewController(TG_ChangeInfo_ViewController(), animated: true)
    }
    
    @IBAction func didPressChangPassWord() {
        
        let changePass = TG_ChangePass_ViewController()
        
        changePass.isRecover = false
        
        self.navigationController?.pushViewController(changePass, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}


extension TG_UserInfo_ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return titles.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 33
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let header = Bundle.main.loadNibNamed("TG_Filter_Header", owner: self, options: nil)?.first
        
        (self.withView(header, tag: 22) as! UILabel).text = "   %@".format(parameters: titles[section])
                
        let view = (self.withView(header, tag: 15) as! UIView)
        
        view.alpha = 0
        
        return header as? UIView
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? header1.count : section == 2 ? header2.count : header3.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TG_UserInfo_Cell", for: indexPath)
        
        let header = self.withView(cell, tag: 11) as! UILabel
        
        header.text = indexPath.section == 0 ? header1[indexPath.row] : indexPath.section == 2 ? header2[indexPath.row] : header3[indexPath.row]

        let content = self.withView(cell, tag: 12) as! UILabel

        
        let userInfo = INFO()["CustomerBasicInfo"] as! NSDictionary
        
        let dict = ["UserName":userInfo["UserName"], "Email":userInfo["Email"], "PhoneNumber":userInfo["PhoneNumber"], "Address":INFO()["address"], "City":"--"]
        
        let cardInfo = INFO()["CardType"] as! NSDictionary

//        let key3 = ["cardNumber", "cardInfo", "nightInfo", "remainNight", "starInfo"]

        let card = ["cardNumber":INFO()["card_number"], "cardInfo":cardInfo.getValueFromKey("description"), "nightInfo":cardInfo.getValueFromKey("total_nights"), "remainNight":INFO().getValueFromKey("remain_nights"), "starInfo":cardInfo.getValueFromKey("star_level")]
        
        content.text = indexPath.section == 0 ? dict[key1[indexPath.row]] as! String : indexPath.section == 2 ? INFO()[key2[indexPath.row]] as! String : card[key3[indexPath.row]] as! String

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
}
