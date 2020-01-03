//
//  TG_Booking_ViewController.swift
//  TourGuide
//
//  Created by Mac on 7/13/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

import SwiftyStarRatingView

class TG_Booking_ViewController: UIViewController {
    
    
    @IBOutlet var tableView: UITableView!
    
    var dataList: NSMutableArray!
    
    @IBOutlet var topView: UIView!

    var refreshHeader: UIRefreshControl!

    var pageIndex: Int = 1
    
    var totalPage: Int = 1
    
    var isLoadMore: Bool = false
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        tableView.withCell("TG_Booking_Cell_1")
        
        tableView.withCell("TG_Booking_Cell_2")

        tableView.withCell("TG_Empty_Cell")

        dataList = NSMutableArray()
        
        refreshHeader = UIRefreshControl.init()
        
        refreshHeader.addTarget(self, action: #selector(didReloadOrder), for: UIControlEvents.valueChanged)
        
        tableView.addSubview(refreshHeader)
    }
    
    @objc func didReloadOrder() {
        isLoadMore = false
        pageIndex = 1
        totalPage = 1
        didRequestOrder(isShow: true)
    }
    
    @objc func didRequestOrder(isShow: Bool) {
        
        if !logged() {
            return
        }
        
        LTRequest.sharedInstance().didRequestInfo(["absoluteLink":"".urlGet(postFix: "api/Orders/ListByStatus"),
                                                   "header":["Authorization":Information.token == nil ? "" : Information.token!],
                                                   "Getparam":["StatusId":1],
                                                   "method":"GET",
                                                   "host":self,
                                                   "overrideLoading":isShow ? 1 : 0,
                                                   "overrideAlert":1
            ], withCache: { (cache) in
                
        }) { (response, errorCode, error, isValid) in
            
            self.refreshHeader.endRefreshing()
            
            if errorCode != "200" {
                self.showToast("Lỗi xảy ra, mời bạn thử lại", andPos: 0)
                
                return
            }
                        
            let result = response?.dictionize().reFormat()
            
            self.totalPage = result!["total_page"] as! Int
            
            self.pageIndex += 1

            if !self.isLoadMore {
                self.dataList.removeAllObjects()
            }
            
            self.dataList.addObjects(from: result!["data"] as! [Any])
            
            self.tableView.cellVisible()
        }
    }
  
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        topView.isHidden = logged()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        
        if logged() {
            //tableView.didScrolltoTop(false)
        }
        
        didRequestOrder(isShow: false)
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
        for dict in dataList {
            if (dict as! NSMutableDictionary).getValueFromKey("id") == hotelId {
                (dict as! NSMutableDictionary)["isFavorite"] = isLike ? 1 : 0
            }
        }
        
        like.setImage(UIImage.init(named: isLike ? "like_ac" : "like_in"), for: .normal)
    }
    
    @IBAction func didPressBack() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func didPressLogIn() {
        let nav = TG_Nav_ViewController.init(rootViewController: TG_Login_ViewController())
        
        nav.isNavigationBarHidden = true
        
        nav.navigationDelegate = self
        
        self.present(nav, animated: true, completion: {
            
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension TG_Booking_ViewController: NavigationDelegate {
    
    func didNavigationBack(infor: NSDictionary) {
        topView.isHidden = logged()
    }
}

extension TG_Booking_ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return dataList.count == 0 ? tableView.frame.size.height : UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return dataList.count == 0 ? tableView.frame.size.height : 340
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataList.count == 0 ? 1 : dataList.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if dataList.count == 0 {
            return 1
        }
        
        let hotel = dataList[section] as! NSDictionary
        
        return dataList.count == 0 ? 1 : (hotel["HotelOrders"] as! NSArray).count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: dataList.count == 0 ? "TG_Empty_Cell" : indexPath.row == 0 ? "TG_Booking_Cell_1" : "TG_Booking_Cell_2", for: indexPath)
        
        if dataList.count == 0 {
            
            let textRetry = (self.withView(cell, tag: 11) as! UILabel)

            textRetry.text = "Bạn chưa đặt phòng. Vui lòng thao tác và thử lại."
            
            let reTry = (self.withView(cell, tag: 12) as! UIButton)
            
            reTry.action(forTouch: nil) { (obj) in
                
                self.didRequestOrder(isShow: true)
                
            }
            
            return cell
        }
        
        let hotel = dataList[indexPath.section] as! NSDictionary
        
        if indexPath.row == 0 {
            
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
            
            
            
            let order = (hotel["HotelOrders"] as! NSArray).firstObject as! NSDictionary
            
            
            let fee = (self.withView(cell, tag: 17) as! UILabel)
            
            fee.text = "%@VNĐ".format(parameters: order.getValueFromKey("order_fee"))
            
            
            
            let code = (self.withView(cell, tag: 18) as! UILabel)
            
            code.text = order.getValueFromKey("order_number") == "" ? order.getValueFromKey("orderStatus") : order["order_code"] as? String
            
            
            
            
            let start = (order["date_from"] as! NSString).date(withFormat: "yyyy-MM-dd'T'HH:mm:ss")
            
            let end = (order["date_to"] as! NSString).date(withFormat: "yyyy-MM-dd'T'HH:mm:ss")
            
            
            let startDate = self.withView(cell, tag: 40) as! UILabel
            
            startDate.text = "%@ Tháng %@".format(parameters: (start?.dateComp(type: 0))!, (start?.dateComp(type: 2))!)
            
            let startWeekDay = self.withView(cell, tag: 41) as! UILabel
            
            startWeekDay.text = "Thứ %@".format(parameters: (start?.dateComp(type: 1))!)
            
            
            
            let endDate = self.withView(cell, tag: 50) as! UILabel
            
            endDate.text = "%@ Tháng %@".format(parameters: (end?.dateComp(type: 0))!, (end?.dateComp(type: 2))!)
            
            let endWeekDay = self.withView(cell, tag: 51) as! UILabel
            
            endWeekDay.text = "Thứ %@".format(parameters: (end?.dateComp(type: 1))!)
            
            let diffInDays = Calendar.current.dateComponents([.day], from: start!, to: end!).day
            
            
            let nightNumb = self.withView(cell, tag: 60) as! UILabel
            
            nightNumb.text = "%i".format(parameters: diffInDays!)
            
        } else {
            
            let order = (hotel["HotelOrders"] as! NSArray)[indexPath.row] as! NSDictionary
            
            
            let fee = (self.withView(cell, tag: 17) as! UILabel)
            
            fee.text = "%@VNĐ".format(parameters: order.getValueFromKey("order_fee"))
            
            
            
            let code = (self.withView(cell, tag: 18) as! UILabel)
            
            code.text = order.getValueFromKey("order_number") == "" ? order.getValueFromKey("orderStatus") : order["order_code"] as? String
            
            
            
            
            let start = (order["date_from"] as! NSString).date(withFormat: "yyyy-MM-dd'T'HH:mm:ss")
            
            let end = (order["date_to"] as! NSString).date(withFormat: "yyyy-MM-dd'T'HH:mm:ss")
            
            
            let startDate = self.withView(cell, tag: 40) as! UILabel
            
            startDate.text = "%@ Tháng %@".format(parameters: (start?.dateComp(type: 0))!, (start?.dateComp(type: 2))!)
            
            let startWeekDay = self.withView(cell, tag: 41) as! UILabel
            
            startWeekDay.text = "Thứ %@".format(parameters: (start?.dateComp(type: 1))!)
            
            
            
            let endDate = self.withView(cell, tag: 50) as! UILabel
            
            endDate.text = "%@ Tháng %@".format(parameters: (end?.dateComp(type: 0))!, (end?.dateComp(type: 2))!)
            
            let endWeekDay = self.withView(cell, tag: 51) as! UILabel
            
            endWeekDay.text = "Thứ %@".format(parameters: (end?.dateComp(type: 1))!)
            
            let diffInDays = Calendar.current.dateComponents([.day], from: start!, to: end!).day
            
            
            let nightNumb = self.withView(cell, tag: 60) as! UILabel
            
            nightNumb.text = "%i".format(parameters: diffInDays!)
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if self.pageIndex == 1 {
            return
        }
        
        if indexPath.row == dataList.count - 1 {
            if self.pageIndex <= self.totalPage {
                isLoadMore = true
                didRequestOrder(isShow: true)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if dataList.count == 0 {
            return
        }
        
        let hotel = dataList[indexPath.row] as! NSDictionary
        
        let detail = TG_Hotel_Detail_ViewController()
        
        detail.detailInfo = ["hotelId":hotel.getValueFromKey("id"), "disable":1]
        
        self.navigationController?.pushViewController(detail, animated: true)
    }
}

