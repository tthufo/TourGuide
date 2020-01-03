//
//  TG_Search_Result_ViewController.swift
//  TourGuide
//
//  Created by Mac on 7/13/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

import SwiftyStarRatingView

class TG_Search_Result_ViewController: UIViewController {

    @IBOutlet var titleLabel: UILabel!
    
    
    @IBOutlet var from: UILabel!

    @IBOutlet var to: UILabel!

    
    @IBOutlet var tableView: UITableView!
    
    @IBOutlet var topBar: NSLayoutConstraint!
    
    @IBOutlet var bottomBar: UIView!

    var searchInfo: NSDictionary!
    
    var dataList: NSMutableArray!
    
    var filterInfo: NSMutableDictionary!
    
    
    var refreshHeader: UIRefreshControl!
    
    var pageIndex: Int = 1
    
    var totalPage: Int = 1
    
    var isLoadMore: Bool = false
    
    var proId: String = "0"
    
    var isHide: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel.text = searchInfo["type"] as? String
        
        
        from.text = "%@ Tháng %@".format(parameters: (searchInfo["start"] as! Date).dateComp(type: 0), (searchInfo["start"] as! Date).dateComp(type: 2))
        
        to.text = "%@ Tháng %@".format(parameters: (searchInfo["end"] as! Date).dateComp(type: 0), (searchInfo["end"] as! Date).dateComp(type: 2))

        
        tableView.withCell("TG_Search_Result_Cell_1")
        
        tableView.withHeaderOrFooter("TG_Filter_Header")
        
        tableView.withCell("TG_Empty_Cell")

        
        dataList = NSMutableArray()
        
        
        filterInfo = NSMutableDictionary()
        
        
        refreshHeader = UIRefreshControl.init()
        
        refreshHeader.addTarget(self, action: #selector(didReloadHotels), for: UIControlEvents.valueChanged)

        tableView.addSubview(refreshHeader)
        
        
        
        didInitBottomBar()
        
        didRequestHotels(isShow: true)
    }

    @objc func didReloadHotels() {
        isLoadMore = false
        pageIndex = 1
        totalPage = 1
        didRequestHotels(isShow: true)
    }
    
    @objc func didRequestHotels(isShow: Bool) {
        
        if filterInfo.allKeys.count != 0 {
            filterInfo.addEntries(from: ["absoluteLink":"".urlGet(postFix:"api/Hotels/GetByFilter"),
                                         "header":["Authorization":Information.token == nil ? "" : Information.token!],
                                         "page_index":pageIndex,
                                         "total_rooms":Information.room,
                                         "lat":self.coor(isLat: true),
                                         "lng":self.coor(isLat: false),
                                         "overrideLoading":isShow ? 1 : 0,
                                         "host":self,
                                         "overrideAlert":1])
            
            print(filterInfo)
            
            filterInfo["keyword"] = self.searchInfo["keyword"]
        }
        
        let request: NSDictionary = filterInfo.allKeys.count == 0 ? ["absoluteLink":"".urlGet(postFix: searchInfo.response(forKey: "best") ? "api/Hotels/GetBest" : searchInfo.response(forKey: "province") ? "api/Hotels/GetByProvince" : "api/Hotels/GetNearest"),
                                     "method":"GET",
                                     "header":["Authorization":Information.token == nil ? "" : Information.token!],
                                     "Getparam":searchInfo.response(forKey: "best") ? ["provinceId":self.proId, "total_rooms":Information.room, "lon":searchInfo.response(forKey:"mag") ? 0 : self.coor(isLat: false), "lat":searchInfo.response(forKey:"mag") ? 0 : self.coor(isLat: true), "keyword": searchInfo.response(forKey: "keyword") ? searchInfo.getValueFromKey("keyword") : "", "starLevel":searchInfo.response(forKey: "all") ? "0" : Information.cardType().getValueFromKey("star_level"), "page_index":pageIndex] : searchInfo.response(forKey: "province") ? ["total_rooms":Information.room, "provId":searchInfo.getValueFromKey("province"), "page_index":pageIndex] : ["total_rooms":Information.room,"lon":self.coor(isLat: false), "lat":self.coor(isLat: true), "page_index":pageIndex, "keyword":searchInfo.response(forKey: "keyword") ? searchInfo.getValueFromKey("keyword") : ""] as Any,
                                     "overrideLoading":isShow ? 1 : 0,
                                     "host":isShow ? self : NSNull(),
                                     "overrideAlert":1] : filterInfo
        
        LTRequest.sharedInstance().didRequestInfo(request as! [AnyHashable : Any], withCache: { (cache) in
                
        }) { (response, errorCode, error, isValid) in
            
            self.refreshHeader.endRefreshing()
            
            if errorCode != "200" {
                
                self.dataList.removeAllObjects()
                
                self.tableView.cellVisible()

                self.bottomBar.alpha = 0
                
                return
            }
            
            let result = response?.dictionize().reFormat()
            
//            if result?.getValueFromKey("data") == "" {
//
//                self.tableView.cellVisible()
//
//                return
//            }
            
            if !(result!["data"] as AnyObject).isKind(of: NSArray.self) {
                
                self.tableView.cellVisible()

                return
            }
            
            self.totalPage = result!["total_page"] as! Int
            
            self.pageIndex += 1

            if !self.isLoadMore {
                self.dataList.removeAllObjects()
            }
            
//            self.dataList.addObjects(from: result!["data"] as! [Any])
            
            self.dataList.addObjects(from: (result!["data"] as! NSArray).withMutable())

            
            self.tableView.cellVisible()
            
            self.bottomBar.alpha = self.dataList.count != 0 ? 1 : 0
                        
            if self.presentedViewController != nil && (self.presentedViewController?.isKind(of: TG_Map_ViewController.self))! {
                
                let mapView = (self.presentedViewController as! TG_Map_ViewController)

                mapView.dataList = self.dataList

                mapView.filterInfo = self.filterInfo
                
                mapView.isHide = (logged() && self.searchInfo.response(forKey: "isHide"))

                mapView.didUpdateMapData()
            }
        }
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
    
    func reload(hotelId: String, isLike: Int) {
        for dict in self.dataList {
            if (dict as! NSMutableDictionary).getValueFromKey("id") == hotelId {
                (dict as! NSMutableDictionary)["isFavorite"] = isLike // (dict as! NSMutableDictionary).getValueFromKey("isFavorite") == "0" ? 1 : 0
            }
        }
        self.tableView.reloadData()
    }
    
    func didInitBottomBar() {
        bottomBar.frame = CGRect.init(x: Int((screenWidth() - 230)/2), y: Int(screenHeight() - 50), width: 230, height: 40)
        
        self.view.addSubview(bottomBar)
    }
    
    func didChangeBottomBar(show: Bool) {
        UIView.animate(withDuration: 0.4) {
            var rect = self.bottomBar.frame
            rect.origin.y = CGFloat(!show ? Float(self.screenHeight() - 50) : self.screenHeight())
            self.bottomBar.frame = rect
        }
    }
    
    func coor(isLat: Bool) -> Float {
        
//        return isLat ? 21.030069 : 105.776559
        
        let location = Permission.shareInstance()
        
        if (location?.isLocationEnable())! {
            
            let cor = (location!.currentLocation()[isLat ? "lat" : "lng"] as? NSNumber)?.floatValue ?? 0
            
            return cor
        }
        
        return 0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    @IBAction func didPressBack() {
        self.navigationController?.popViewController(animated: true)
    }
   
    @IBAction func didPressMap() {
        let mapView = TG_Map_ViewController()
        
        mapView.mapDelegate = self
        
        mapView.dataList = dataList
        
        mapView.filterInfo = filterInfo
        
        mapView.isHide = (logged() && searchInfo.response(forKey: "isHide"))
        
        self.present(mapView, animated: true) {
            
        }
    }
    
    @IBAction func didPressFilter() {
        let filter = TG_Filter_ViewController()
        
        filter.filterDelegate = self
        
        if filterInfo.allKeys.count != 0 {
            filter.prepInfo = filterInfo
        }
        
        filter.isHide = (logged() && searchInfo.response(forKey: "isHide"))
        
        self.present(filter, animated: true) {
            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension TG_Search_Result_ViewController: MapDelegate {
    
    func mapDidChangeData(data: NSMutableArray) {
        
        dataList.removeAllObjects()
        
        dataList.addObjects(from: data as! [Any])
        
        tableView.cellVisible()
    }
}

extension TG_Search_Result_ViewController: FilterDelegate {
    
    func filterDidNavigationBack(infor: NSDictionary, isHide: Bool) {
        
        if infor.response(forKey: "reset") {
            return
        }
        
        if infor.allKeys.count == 0 {
            return
        }
        
        filterInfo.removeAllObjects()
        
        if !infor.response(forKey: "reset") {
            filterInfo.addEntries(from: infor as! [AnyHashable : Any])
        }
        
        self.pageIndex = 1
        
        didRequestHotels(isShow: !infor.response(forKey: "reset"))
    }
}

extension TG_Search_Result_ViewController: DetailDelegate {
    
    func detailDidNavigationBack(infor: NSDictionary) {
        
        if !logged() {
            return
        }
        
        for dict in dataList {
            if (dict as! NSDictionary).getValueFromKey("id") == infor.getValueFromKey("id") {
                (dict as! NSMutableDictionary)["isFavorite"] = infor["isFavorite"]
            }
        }
        
        tableView.cellVisible()
    }
}

extension TG_Search_Result_ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 33
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let header = Bundle.main.loadNibNamed("TG_Filter_Header", owner: self, options: nil)?.first
        
        let head = (self.withView(header, tag: 22) as! UILabel)
        
        head.text = "Danh sách khách sạn của bạn"
        
        head.font = UIFont.italicSystemFont(ofSize: 14)
        
        head.textColor = UIColor.darkText
        
        head.textAlignment = .center
        
        head.backgroundColor = UIColor.clear
        
        let view = (self.withView(header, tag: 15) as! UIView)
        
        view.alpha = 0
        
        return header as? UIView
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        didChangeBottomBar(show: scrollView.panGestureRecognizer.translation(in: scrollView).y < 0)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return dataList.count == 0 ? tableView.frame.size.height : UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataList.count == 0 ? 1 : dataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: dataList.count == 0 ? "TG_Empty_Cell" : "TG_Search_Result_Cell_1", for: indexPath)
        
        if dataList.count == 0 {
            let reTry = (self.withView(cell, tag: 12) as! UIButton)
            
            reTry.action(forTouch: nil) { (obj) in
                
                self.didRequestHotels(isShow: true)
                
            }
            
            return cell
        }
        
        let hotel = dataList[indexPath.row] as! NSDictionary
        
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

        price.text = ""//"%@VND".format(parameters: (hotel["price"] as? NSString) == "" ? "0" : self.numerize((hotel["price"] as? NSString)?.numb()!))

        
        
        let des = (self.withView(cell, tag: 17) as! UILabel)
        
        des.text = hotel.getValueFromKey("description") == "" ? "Thông tin đang được cập nhật" : hotel.getValueFromKey("description")
        
        
        
        let remain = (self.withView(cell, tag: 18) as! UILabel)

        remain.text = "Chỉ còn %@ phòng trống trên Crystal Holidays".format(parameters: hotel.getValueFromKey("total_avaiable_room"))
        
        return cell
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if self.pageIndex == 1 {
            return
        }
        
        if indexPath.row == dataList.count - 1 {
            if self.pageIndex <= self.totalPage {
                isLoadMore = true
                didRequestHotels(isShow: true)
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
        
        detail.detailDelegate = self
        
        detail.detailInfo = ["hotelId":hotel.getValueFromKey("id"), "start":searchInfo["start"] as! Date, "end":searchInfo["end"] as! Date, "hasBuffet":hotel["hasBuffet"]]
        
        self.navigationController?.pushViewController(detail, animated: true)
    }
}
