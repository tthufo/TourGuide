//
//  TG_Favorite_ViewController.swift
//  TourGuide
//
//  Created by Mac on 7/13/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

import SwiftyStarRatingView

import AVHexColor

class TG_Favorite_ViewController: UIViewController {
    
    
    @IBOutlet var tableView: UITableView!
    
    var dataList: NSMutableArray!
    
    @IBOutlet var topView: UIView!
    
    var refreshHeader: UIRefreshControl!

    var pageIndex: Int = 1
    
    var totalPage: Int = 1
    
    var isLoadMore: Bool = false
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        tableView.withCell("TG_Search_Result_Cell_1")
        
        tableView.withCell("TG_Empty_Cell")

        dataList = NSMutableArray()
        
        refreshHeader = UIRefreshControl.init()
        
        refreshHeader.addTarget(self, action: #selector(didReloadFavorite), for: UIControlEvents.valueChanged)
        
        tableView.addSubview(refreshHeader)
    }
    
    @objc func didReloadFavorite() {
        isLoadMore = false
        pageIndex = 1
        totalPage = 1
        didRequestFavorite(isShow: true)
    }
    
    @objc func didRequestFavorite(isShow: Bool) {
        
        if !logged() {
            
            return
        }
        
        LTRequest.sharedInstance().didRequestInfo(["absoluteLink":"".urlGet(postFix: "api/Hotels/ListFavorite"),
                                                   "header":["Authorization":Information.token == nil ? "" : Information.token!],
                                                   "Getparam":["page_index":pageIndex],
                                                   "method":"GET",
                                                   "host":self,
                                                   "overrideLoading":isShow ? 1 : 0,
                                                   "overrideAlert":1
            ], withCache: { (cache) in
                
        }) { (response, errorCode, error, isValid, header) in
            
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
        
        didRequestFavorite(isShow: false)
    }
    
    @IBAction func didPressBack() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func didPressLogIn() {
        let nav = TG_Nav_ViewController.init(rootViewController: TG_Login_ViewController())
        
        nav.isNavigationBarHidden = true
        
        nav.navigationDelegate = self
        
        nav.modalPresentationStyle = .fullScreen

        self.present(nav, animated: true, completion: {
            
        })
    }
    
    func didLikeHotel(isLike: Bool, like: UIButton, hotelId: String) {
        
        if Information.token == nil {
            self.showToast("Bạn phải đăng nhập để sử dụng tính năng này", andPos: 0)
            return
        }
        
        LTRequest.sharedInstance().didRequestInfo(["absoluteLink":"".urlGet(postFix: "api/Hotels/Favorite"),
                                                   "header":["Authorization":Information.token == nil ? "" : Information.token!],
                                                   "method":"GET",
                                                   "Getparam":["hotelId": hotelId, "favorite": isLike ? "true" : "false"],
                                                   "overrideAlert":1
            ], withCache: { (cache) in
                
        }) { (response, errorCode, error, isValid, header) in
            
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
                dataList.remove(dict)
            }
        }
        
        like.setImage(UIImage.init(named: isLike ? "like_ac" : "like_in"), for: .normal)
        
        tableView.reloadData(withAnimation: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension TG_Favorite_ViewController: NavigationDelegate {
    
    func didNavigationBack(infor: NSDictionary) {
        topView.isHidden = logged()
    }
}

extension TG_Favorite_ViewController: UITableViewDataSource, UITableViewDelegate {
    
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
                
                self.didRequestFavorite(isShow: true)
                
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
        
        price.text = "" //"%@VND".format(parameters: self.numerize((hotel["price"] as? NSString)?.numb()!))

        
        
        
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
                didRequestFavorite(isShow: true)
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
        
        detail.detailInfo = ["hotelId":hotel.getValueFromKey("id")]
        
        self.navigationController?.pushViewController(detail, animated: true)
    }
}
