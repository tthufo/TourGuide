//
//  TG_Menu_View.swift
//  TourGuide
//
//  Created by Mac on 8/17/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

import SwiftyStarRatingView

class TG_Menu_View: NSObject, UIPickerViewDataSource, UIPickerViewDelegate {
    
    var comp1: Int!
    
    var comp2: Int!
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerView.tag == 1 ? 54 : 108
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "%@%i".format(parameters: row >= 9 ? "" : "0", row + 1)
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if pickerView.tag == 1 {
            comp1 = row + 1
        } else {
            comp2 = row + 1
        }
        
        let pick2 = self.withView(pickerView.superview?.superview?.superview, tag: 2) as! UIPickerView
        
        if comp2 < comp1 {
            if pickerView == pick2 {
                pickerView.selectRow(comp1 - 1, inComponent: 0, animated: true)
                
                comp2 = comp1
                
                self.showToast("Số khách tối thiểu cần bằng số phòng", andPos: 0)
            } else {
                pick2.selectRow(comp1 - 1, inComponent: 0, animated: true)
                
                comp2 = comp1
                
                self.showToast("Số khách tối thiểu cần bằng số phòng", andPos: 0)
            }
        }
    }

    
    static var shareInstance = TG_Menu_View()
    
    private override init() {}
    
    func showMap(host: UIViewController, hotel: NSMutableDictionary, finished: @escaping (_ hotelId: String, _ like: String) -> Void) {
        let base = Bundle.main.loadNibNamed("TG_Menu_View",
                                            owner: nil,
                                            options: nil)![4] as! UIView
        base.frame = CGRect.init(x: 0, y: Int(screenHeight()), width: Int(screenWidth()), height: 260)
        
        let cover = Bundle.main.loadNibNamed("TG_Menu_View",
                                             owner: nil,
                                             options: nil)![1] as! UIView
        
        cover.frame = CGRect.init(x: 0, y: 0, width: Int(screenWidth()), height: Int(screenHeight()))
        
        host.view.addSubview(cover)
        
        host.view.addSubview(base)
        
        didMoveView(isShow: true, base: base, cover: cover)
        
        showInfo(cell: base, hotel: hotel)
        
        base.action(forTouch: [:]) { (objc) in
         
            finished(hotel.getValueFromKey("id"), "")
        }
        
        let like = self.withView(base, tag: 9) as! UIButton
        
        like.setImage(UIImage.init(named: hotel.getValueFromKey("isFavorite") == "0" ? "like_in" : "like_ac"), for: .normal)
                
        like.action(forTouch: [:]) { (objc) in
            
            if !logged() {
                self.showToast("Bạn phải đăng nhập để sử dụng tính năng này", andPos: 0)
                return
            }
            
            LTRequest.sharedInstance().didRequestInfo(["absoluteLink":"".urlGet(postFix: "api/Hotels/Favorite"),
                                                       "header":["Authorization":Information.token == nil ? "" : Information.token!],
                                                       "method":"GET",
                                                       "Getparam":["hotelId": hotel.getValueFromKey("id"), "favorite": hotel.getValueFromKey("isFavorite") == "0" ? "true" : "false"],
                                                       "overrideAlert":1
                ], withCache: { (cache) in
                    
            }) { (response, errorCode, error, isValid) in
                
                if errorCode != "200" {
                    self.showToast("Lỗi xảy ra, mời bạn thử lại", andPos: 0)
                    
                    return
                }
                
                hotel["isFavorite"] = hotel.getValueFromKey("isFavorite") == "0" ? 1 : 0
                
                like.setImage(UIImage.init(named: hotel.getValueFromKey("isFavorite") == "0" ? "like_in" : "like_ac"), for: .normal)
                
                finished("", hotel.getValueFromKey("id"))
            }
        }
        
        cover.action(forTouch: [:]) { (objc) in
            self.didMoveView(isShow: false, base: base, cover: cover)
        }
    }
    
//    func didLikeHotel(isLike: Bool, like: UIButton, hotelId: String) {
    
//        if !logged() {
//            self.showToast("Bạn phải đăng nhập để sử dụng tính năng này", andPos: 0)
//            return
//        }
//
//        LTRequest.sharedInstance().didRequestInfo(["absoluteLink":"".urlGet(postFix: "api/Hotels/Favorite"),
//                                                   "header":["Authorization":Information.token == nil ? "" : Information.token!],
//                                                   "method":"GET",
//                                                   "Getparam":["hotelId": hotelId, "favorite": isLike ? "true" : "false"],
//                                                   "overrideAlert":1
//            ], withCache: { (cache) in
//
//        }) { (response, errorCode, error, isValid) in
//
//            if errorCode != "200" {
//                self.showToast("Lỗi xảy ra, mời bạn thử lại", andPos: 0)
//
//                return
//            }
//
//            print(response)
//
////            like.setImage(UIImage.init(named: isLike ? "like_ac" : "like_in"), for: .normal)
//        }
//    }
    
//    func didLike(isLike: Bool, like: UIButton, hotelId: String) {
//        for dict in dataList {
//            if (dict as! NSMutableDictionary).getValueFromKey("id") == hotelId {
//                (dict as! NSMutableDictionary)["isFavorite"] = isLike ? 1 : 0
//            }
//        }
//
//        like.setImage(UIImage.init(named: isLike ? "like_ac" : "like_in"), for: .normal)
//    }
    
    func showInfo(cell: UIView, hotel: NSDictionary) {
        
        let condition = (self.withView(cell, tag: 8) as! UILabel)
        
        condition.isHidden = hotel.getValueFromKey("hasBuffet") == "0"
        
        
        let like = (self.withView(cell, tag: 9) as! UIButton)
        
        like.setImage(UIImage.init(named: hotel.getValueFromKey("isFavorite") == "0" ? "like_in" : "like_ac"), for: .normal)
        
        like.action(forTouch: nil) { (obj) in
            
            //self.didLikeHotel(isLike: hotel.getValueFromKey("isFavorite") == "0" ? true : false, like: like, hotelId: hotel.getValueFromKey("id"))
            
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
    }
    
    func showWith(room: Int, guest: Int, finished: @escaping (_ room: Int, _ guest: Int) -> Void) {
        let base = Bundle.main.loadNibNamed("TG_Menu_View",
                                                            owner: nil,
                                                            options: nil)?.first as! UIView
        base.frame = CGRect.init(x: 0, y: Int(screenHeight()), width: Int(screenWidth()), height: 227)
        
        let cover = Bundle.main.loadNibNamed("TG_Menu_View",
                                            owner: nil,
                                            options: nil)![1] as! UIView
        cover.frame = CGRect.init(x: 0, y: 0, width: Int(screenWidth()), height: Int(screenHeight()))
        
        tabbar().view.addSubview(cover)

        tabbar().view.addSubview(base)
        
        comp1 = room
        
        comp2 = guest
        
        
        let pick1 = self.withView(base, tag: 1) as! UIPickerView
        
        pick1.delegate = self
        
        pick1.selectRow(room - 1, inComponent: 0, animated: true)

        
        let pick2 = self.withView(base, tag: 2) as! UIPickerView
        
        pick2.delegate = self
        
        pick2.selectRow(guest - 1, inComponent: 0, animated: true)

        
        
        didMoveView(isShow: true, base: base, cover: cover)
        
        let cancel = tabbar().withView(base, tag: 11) as! UIButton
        
        cancel.action(forTouch: [:]) { (obj) in
            self.didMoveView(isShow: false, base: base, cover: cover)
        }
        
        let accept = tabbar().withView(base, tag: 12) as! UIButton
        
        accept.action(forTouch: [:]) { (obj) in
            
            if self.comp2 < self.comp1 {
                
                pick2.selectRow(self.comp1 - 1, inComponent: 0, animated: true)
                
                self.comp2 = self.comp1
                
                self.showToast("Số khách tối thiểu cần bằng số phòng", andPos: 0)
                
                return
            }
            
            self.didMoveView(isShow: false, base: base, cover: cover)
            
            finished(self.comp1, self.comp2)
        }
    }
    
    func didMoveView(isShow: Bool, base: UIView, cover: UIView) {
        UIView.animate(withDuration: 0.3, animations: {
            
            cover.isHidden = !isShow
            
            var frame =  base.frame
            
            frame.origin.y -= isShow ? 227 : -227
            
            base.frame = frame
        }) { (done) in
            if done && !isShow {
                base.removeFromSuperview()
                cover.removeFromSuperview()
            }
        }
    }
}
