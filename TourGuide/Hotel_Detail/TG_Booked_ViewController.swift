//
//  TG_Booked_ViewController.swift
//  TourGuide
//
//  Created by Mac on 8/23/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

class TG_Booked_ViewController: UIViewController {

    @IBOutlet var titleLabel: UILabel!
    
    var detailInfo: NSDictionary!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel.text =  "Cảm ơn bạn đã sử dụng dịch vụ của Crystal Holidays Hotel. Đơn đặt phòng của bạn %@ đang tiếp nhận và chờ xử lý. Bộ phận Booking sẽ gửi mã xác nhận đặt phòng sớm".format(parameters: detailInfo.getValueFromKey("id"))
    }
    
    @IBAction func backToTop() {
        self.navigationController?.popToRootViewController(animated: true)
        
        tabbar().rootSelect(index: 0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
