//
//  TG_Point_ViewController.swift
//  TourGuide
//
//  Created by Mac on 7/24/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

class TG_Point_ViewController: UIViewController {
    
    let titles = ["Thông tin Vpoint", "Lịch sử giao dịch"]

    let content = ["Vpoint có thể dùng:", "Vpoint chờ kích hoạt:", "Vpoint sẽ hết hạn:"]

    
    @IBOutlet var tableView: UITableView!
    
    @IBOutlet var topBar: NSLayoutConstraint!
    
    var dataList: NSMutableArray!
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.withCell("TG_Point_Cell")
        
        tableView.withHeaderOrFooter("TG_Filter_Header")
        
        tableView.contentInset = UIEdgeInsetsMake(20, 0, 0, 0)
        
        topBar.constant = iOS_VERSION_GREATER_THAN_OR_EQUAL_TO(version: "11") ? 44 : 64
    }

    @IBAction func didPressBack() {
        self.dismiss(animated: true) {
            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension TG_Point_ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return titles.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 33 : 66
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let header = Bundle.main.loadNibNamed("TG_Filter_Header", owner: self, options: nil)?.first
        
        (self.withView(header, tag: 22) as! UILabel).text = "   %@".format(parameters: titles[section])
        
        let view = (self.withView(header, tag: 15) as! UIView)
        
        view.alpha =  section == 1 ? 1 : 0
        
        return header as? UIView
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section >= 1 ? 10 : 3 //(dataInfo["%i".format(parameters: section)] as! NSDictionary).allKeys.count : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TG_Point_Cell", for: indexPath)
        
        let view = (self.withView(cell, tag: 15) as! UIView)
        
        view.alpha = indexPath.section == 0 ? 1 : 0
        
        if indexPath.section == 0 {
            let title = self.withView(cell, tag: 11) as! UILabel
            
            title.text = content[indexPath.row]
            
            let point = self.withView(cell, tag: 12) as! UILabel
            
            point.textColor = indexPath.row == 0 ? UIColor.green : indexPath.row == 1 ? UIColor.darkGray : UIColor.red
            
            point.text = "%@ Vpoint".format(parameters: "10")
        } else {
            let title = self.withView(cell, tag: 11) as! UILabel
            
            title.text = "Đặt phòng khách sạn"
            
            let point = self.withView(cell, tag: 12) as! UILabel
            
            point.textColor = UIColor.green
            
            point.text = "+%@ Vpoint".format(parameters: "100")
        }
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
}
