//
//  TG_Information_Confirm_ViewController.swift
//  TourGuide
//
//  Created by Thanh Hai Tran on 8/23/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

import SwiftyStarRatingView

import MarqueeLabel

class TG_Information_Confirm_ViewController: UIViewController {

    @IBOutlet var titleLabel: MarqueeLabel!
    
    @IBOutlet var tableView: UITableView!
    
    var dataList: NSMutableArray!
    
    @IBOutlet var bottomCell: UITableViewCell!
    
    @IBOutlet var midCell: UITableViewCell!
    
    var detailInfo: NSMutableDictionary!
    
    var dataInfo: NSMutableDictionary!

    
    let titles = ["", "Thông tin liên hệ"]

    
    override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel.text = detailInfo.getValueFromKey("hotel_name")
        
        tableView.withCell("TG_Information_Confirm_Cell")

        tableView.withHeaderOrFooter("TG_Filter_Header")

        dataList = NSMutableArray()
        
        dataInfo = NSMutableDictionary()
        
        dataInfo.addEntries(from: detailInfo as! [AnyHashable : Any])
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    func getDate(date: Date) -> String {
        return (date as NSDate).string(withFormat: "yyyy-MM-dd")
    }
    
    @IBAction func submit(_ sender: Any) {
        self.view.endEditing(true)
        
        LTRequest.sharedInstance().didRequestInfo(["absoluteLink":"".urlGet(postFix: "api/Orders/Create"),
                                                   "header":["Authorization":Information.token == nil ? "" : Information.token!],
                                                   "date_from":getDate(date: (Information.start /*dataInfo["start"]*/ as! Date)),
                                                   "date_to":getDate(date: (Information.end /*dataInfo["end"]*/ as! Date)),
                                                   "hotel_id":dataInfo["id"] ?? "",
                                                   "order_date":getDate(date: Date()),
                                                   "people_count":1,
                                                   "room_count":dataInfo["roomNumber"] ?? "",
                                                   "room_type_id":(dataInfo["roomType"] as! NSDictionary)["roomTypeId"] ?? "",
                                                   "host":self,
                                                   "overrideLoading":1,
                                                   "overrideAlert":1
            ], withCache: { (cache) in
                
        }) { (response, errorCode, error, isValid) in
            
            if errorCode != "200" {
                self.showToast("Lỗi xảy ra, mời bạn thử lại", andPos: 0)
                
                return
            }
            
            let isSuccess = response?.dictionize()["success"] as! Bool
            
            if isSuccess {
                let booked = TG_Booked_ViewController()
                
                booked.detailInfo = response?.dictionize()
                
                self.navigationController?.pushViewController(booked, animated: true)
            } else {
                let message = response?.dictionize()["errors"] as! NSArray

                self.showToast(message.firstObject as! String, andPos: 0)
            }
        }
    }
    
    @IBAction func didPressBack() {
        self.navigationController?.popViewController(animated: true)
        
        (self.navigationController as! TG_Nav_ViewController).navigationDelegate?.didNavigationBack(infor: ["isFavorite":dataInfo["isFavorite"] ?? ""])
    }
    
    func didLikeHotel(isLike: Bool, like: UIButton, hotelId: String) {
        
        if !logged() {
            self.showToast("Bạn phải đăng nhập để sử dụng tính năng này", andPos: 0)
            return
        }
        
        LTRequest.sharedInstance().didRequestInfo(["absoluteLink":"".urlGet(postFix: "api/Hotels/Favorite"),
                                                   "header":["Authorization":Information.token == nil ? "" : Information.token!],
                                                   "method":"GET",
                                                   "Getparam":["hotelId": hotelId, "favorite": isLike ? "true" : "false"],
                                                   "overrideAlert":1
            ], withCache: { (cache) in
                
        }) { (response, errorCode, error, isValid) in
            
            if errorCode != "200" {
                self.showToast("Lỗi xảy ra, mời bạn thử lại", andPos: 0)
                
                return
            }
            
            self.didLike(isLike: isLike, like: like, hotelId: hotelId)
        }
    }
    
    func didLike(isLike: Bool, like: UIButton, hotelId: String) {
        dataInfo["isFavorite"] = isLike ? 1 : 0
        
        like.setImage(UIImage.init(named: isLike ? "like_ac" : "like_in"), for: .normal)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension TG_Information_Confirm_ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return titles.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section != 0 ? 33 : 20
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let header = Bundle.main.loadNibNamed("TG_Filter_Header", owner: self, options: nil)?.first
        
        (self.withView(header, tag: 22) as! UILabel).text = " %@".format(parameters: titles[section])
        
        (self.withView(header, tag: 22) as! UILabel).isHidden = section == 0
        
        let view = (self.withView(header, tag: 15) as! UIView)
        
        view.alpha = 0
        
        return header as? UIView
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
 
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 1 ? 1 : 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 1 {
            
            let userInfo = INFO()["CustomerBasicInfo"] as! NSDictionary

            
            let name = (self.withView(bottomCell, tag: 10) as! UILabel)
            
            name.text = (logged() ? userInfo["UserName"] : "") as? String
            
            
            
            let email = (self.withView(bottomCell, tag: 11) as! UILabel)
            
            email.text = (logged() ? userInfo["Email"] : "") as? String
            
            
            
            let phone = (self.withView(bottomCell, tag: 12) as! UILabel)
            
            phone.text = (logged() ? userInfo["PhoneNumber"] : "") as? String
            
            
            
            return bottomCell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TG_Information_Confirm_Cell", for: indexPath)

        let hotel: NSDictionary = dataInfo
        
        
        let start = Information.start /* detailInfo["start"]*/ as! Date
        
        let end = Information.end /* detailInfo["end"]*/ as! Date
        
        
        let startDate = self.withView(cell, tag: 40) as! UILabel
        
        startDate.text = "%@ Tháng %@".format(parameters: start.dateComp(type: 0), start.dateComp(type: 2))
        
        let startWeekDay = self.withView(cell, tag: 41) as! UILabel
        
        startWeekDay.text = "Thứ %@".format(parameters: start.dateComp(type: 1))
        
        
        
        let endDate = self.withView(cell, tag: 50) as! UILabel
        
        endDate.text = "%@ Tháng %@".format(parameters: end.dateComp(type: 0), end.dateComp(type: 2))
        
        let endWeekDay = self.withView(cell, tag: 51) as! UILabel
        
        endWeekDay.text = "Thứ %@".format(parameters: end.dateComp(type: 1))
        
        let diffInDays = Calendar.current.dateComponents([.day], from: start, to: end).day
        
        
        let nightNumb = self.withView(cell, tag: 60) as! UILabel
        
        nightNumb.text = "%i".format(parameters: (detailInfo["roomNumber"] as! Int) * diffInDays!)//"%i".format(parameters: diffInDays!)
        
        
        
        
        let condition = (self.withView(cell, tag: 8) as! UILabel)
        
        condition.isHidden = hotel.getValueFromKey("hasBuffet") == "0"
        
        
        let like = (self.withView(cell, tag: 9) as! UIButton)
        
        like.setImage(UIImage.init(named: hotel.getValueFromKey("isFavorite") == "0" ? "like_in" : "like_ac"), for: .normal)
        
        like.action(forTouch: nil) { (obj) in
            
            self.didLikeHotel(isLike: hotel.getValueFromKey("isFavorite") == "0" ? true : false, like: like, hotelId: hotel.getValueFromKey("id"))
            
        }
        
        
        
        let ava = (self.withView(cell, tag: 10) as! UIImageView)
        
        ava.imageUrl(url: hotel.getValueFromKey("avatar_image"))
        
        
        
        
        let title = (self.withView(cell, tag: 11) as! UILabel)
        
        title.text = hotel["hotel_name"] as? String
        
        
        
        let point = (self.withView(cell, tag: 12) as! UILabel)
        
        var pp = hotel.getValueFromKey("vote_star") as! String
        
        point.text = pp.count  > 3 ? pp.substring(to: 3) : pp.count == 1 ? "%@.0".format(parameters: pp) : pp
        
        
        let emotion = (self.withView(cell, tag: 13) as! UILabel)
        
        emotion.text = "tuyệt vời"
        
        
        
        let address = (self.withView(cell, tag: 14) as! UILabel)
        
        address.text = "Địa chỉ: %@ %@ %@ %@".format(parameters: hotel.getValueFromKey("address"), hotel.getValueFromKey("district"), hotel.getValueFromKey("province"), hotel.getValueFromKey("distance_from_center"))
        
        
        
        
        
        let star = (self.withView(cell, tag: 15) as! SwiftyStarRatingView)
        
        star.value = hotel["star_number"] as! CGFloat
        
        
        
        
        
        let price = (self.withView(cell, tag: 16) as! UILabel)
        
        price.text = ""//"%@VND".format(parameters: self.numerize((hotel["price"] as? NSString)?.numb()!))

        
        

        let roomType = (self.withView(cell, tag: 17) as! UILabel)

        roomType.text = (detailInfo["roomType"] as! NSDictionary)["roomName"] as? String



        let roomNumb = (self.withView(cell, tag: 18) as! UILabel)

        roomNumb.text = "%@ phòng".format(parameters: detailInfo.getValueFromKey("roomNumber"))
        
        
        
        
        if indexPath.section == 0 && indexPath.row == 1 {
            
            let nightNumb = self.withView(midCell, tag: 17) as! UILabel
            
            nightNumb.text = "%i đêm".format(parameters: (detailInfo["roomNumber"] as! Int) * diffInDays!)//"%i đêm".format(parameters: diffInDays!)
            
            return midCell
        }

        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
}
