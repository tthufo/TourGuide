//
//  TG_Filter_ViewController.swift
//  TourGuide
//
//  Created by Mac on 7/17/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

import RangeSeekSlider

import AVHexColor

protocol FilterDelegate:class {
    func filterDidNavigationBack(infor: NSDictionary, isHide: Bool)
}

class TG_Filter_ViewController: UIViewController, RangeSeekSliderDelegate {

    weak var filterDelegate: FilterDelegate?

    let titles = ["Sắp xếp", "Hạng sao"/*, "Mức giá"*/, "Loại hình", "Tiện nghi"]
    
    @IBOutlet var tableView: UITableView!
        
    var filterInfo: NSMutableDictionary!
    
    var dataInfo: NSMutableDictionary!
    
    var prepInfo: NSDictionary!
    
    var filterOption: NSDictionary!
    
    var isHide: Bool = false
    
    func didRequestAdditions() {
        LTRequest.sharedInstance().didRequestInfo(["absoluteLink":"".urlGet(postFix: "api/Hotels/ListAdditions"),
                                                   "Getparam":["hotelId":0],
                                                   "method":"GET",
                                                   "overrideAlert":1
            ], withCache: { (cache) in
                
        }) { (response, errorCode, error, isValid, header) in
            
            if errorCode != "200" {
                return
            }
            
            let result = response?.dictionize().reFormat()

            let array = result!["array"] as! NSArray
            
            let temp = NSMutableDictionary()
            
            for dict in array {
                
                let dataDict = dict as! NSDictionary
                
                let innerDict = ["%i".format(parameters: (dataDict["id"] as! Int) - 1):["title":dataDict.getValueFromKey("description"), "active":0, "img":"ic_%@_i".format(parameters: dataDict.getValueFromKey("id")), "id":(dataDict["id"] as! Int)]]
                
                temp.addEntries(from: innerDict)
            }
            
            self.filterOption = ["3":temp]
            
            self.dataInfo.addEntries(from:self.defaultSetting().reFormat() as! [AnyHashable : Any])
            
            self.tableView.reloadData()
        }
    }
    
    func prep() -> Bool {
        return prepInfo != nil
    }
        
    func defaultSetting() -> NSMutableDictionary {
        
        let dict: NSDictionary = ["0":["data":[["title":"  Hạng sao tăng dần","id":"asc"], ["title":"  Hạng sao giảm dần","id":"desc"]], "default":prep() ? (prepInfo["order_direction"] as! String) == "asc" ? "  Hạng sao tăng dần" : "  Hạng sao giảm dần" :"  Hạng sao tăng dần", "id":prep() ? (prepInfo["order_direction"] as! String) : "asc"],
                                  "1":["0":0,"1":0,"2":0,"3":0],
                                  "2":["0":["title":"Khách sạn","active":1,"img":"","id":1],"1":["title":"Resort","active":0,"img":"","id":2]],
                                  "3":[:]
//                                  "3":["0":["title":"Đưa đón khách sạn/sân bay","active":0,"img":"ic_1_i","id":1],
//                                       "1":["title":"Bữa sáng miễn phí","active":0,"img":"ic_2_i","id":2],
//                                       "2":["title":"Bể bơi ngoài trời","active":0,"img":"ic_3_i","id":3],
//                                       "3":["title":"Bể bơi trong nhà","active":0,"img":"ic_4_i","id":4],
//                                       "4":["title":"Bể bơi trẻ em","active":0,"img":"ic_5_i","id":5],
//                                       "5":["title":"Bãi đỗ xe","active":0,"img":"ic_6_i","id":6],
//                                       "6":["title":"Phòng họp","active":0,"img":"ic_7_i","id":7],
//                                       "7":["title":"Phòng tập thể thao","active":0,"img":"ic_8_i","id":8],
//                                       "8":["title":"Sân tennis","active":0,"img":"ic_9_i","id":9],
//                                       "9":["title":"Sân golf","active":0,"img":"ic_10_i","id":10],
//                                       "10":["title":"Thang máy","active":0,"img":"ic_11_i","id":11],
//                                       "11":["title":"Thêm giường phụ","active":0,"img":"ic_12_i","id":12],
//                                       "12":["title":"Wifi miễn phí","active":0,"img":"ic_13_i","id":13],
//                                       "13":["title":"Giặt là","active":0,"img":"ic_14_i","id":14],
//                                       "14":["title":"Nhà hàng","active":0,"img":"ic_15_i","id":15],
//                                       "15":["title":"Spa","active":0,"img":"ic_16_i","id":16],
//                                       "16":["title":"Truyền hình cáp/vệ tinh","active":0,"img":"ic_17_i","id":17]]
        ]

        let temp = NSMutableDictionary()
        
        temp.addEntries(from: dict.reFormat() as! [AnyHashable : Any])
        
        if filterOption != nil {
            temp.addEntries(from: self.filterOption.reFormat() as! [AnyHashable : Any])
        }
        
        if prep() {
            for star in (temp["1"] as! NSDictionary).allKeys {
                for starNumber in prepInfo["starNumber"] as! NSArray {
                    if (Int(truncating: starNumber as! NSNumber) - 3) == (star as AnyObject).integerValue {
                        (temp["1"] as! NSMutableDictionary)[star] = 1
                    }
                }
            }
            
            for type in (temp["2"] as! NSDictionary).allValues {
                
                (type as! NSMutableDictionary)["active"] = 0
                
                if (type as! [AnyHashable : Any])["id"] as! Int == prepInfo["hotelType"] as! Int {
                    (type as! NSMutableDictionary)["active"] = 1
                }
            }
            
            if (temp["3"] as! NSDictionary).allValues.count != 0 {
                for addition in (temp["3"] as! NSDictionary).allValues {
                    
                    (addition as! NSMutableDictionary)["active"] = 0
                    
                    for added in prepInfo["additions"] as! NSArray {
                        if (addition as! [AnyHashable : Any])["id"] as! Int == added as! Int {
                            (addition as! NSMutableDictionary)["active"] = 1
                        }
                    }
                }
            }
        }
        
        return temp
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.withCell("TG_Filter_Selection_Cell")

        tableView.withCell("TG_Filter_Rate_Cell")
        
        tableView.withCell("TG_Filter_Price_Cell")
        
        tableView.withCell("TG_Filter_Type_Cell")

        tableView.withHeaderOrFooter("TG_Filter_Header")
        
        tableView.contentInset = UIEdgeInsetsMake(20, 0, 30, 0)
        
        filterInfo = NSMutableDictionary()
        
        let temp: NSDictionary = ["additions":[],
                                  "keyword":"",
                                  "hotelType": 1,
                                  "maxPrice": 0,
                                  "minPrice": 0,
                                  "order_by": "star",
                                  "order_direction": "asc",// desc
                                  "starNumber": [],
                                  "promotion": false
                                  ]
        
        filterInfo.addEntries(from: temp.reFormat() as! [AnyHashable : Any])
        
        dataInfo = NSMutableDictionary()

//        dataInfo.addEntries(from:self.defaultSetting().reFormat() as! [AnyHashable : Any])
        
        self.dataInfo.addEntries(from:self.defaultSetting().reFormat() as! [AnyHashable : Any])
        
        didRequestAdditions()
    }

    func rangeSeekSlider(_ slider: RangeSeekSlider, stringForMinValue minValue: CGFloat) -> String? {
        (dataInfo["1"] as! NSMutableDictionary)["min"] = Int(minValue)
        return "%.0f đ".format(parameters: minValue)
    }

    func rangeSeekSlider(_ slider: RangeSeekSlider, stringForMaxValue maxValue: CGFloat) -> String? {
        (dataInfo["1"] as! NSMutableDictionary)["max"] = Int(maxValue)
        return "%.0f đ".format(parameters: maxValue)
    }

    @IBAction func didPressBack() {
        self.dismiss(animated: true) {
            
        }
        
        self.filterDelegate?.filterDidNavigationBack(infor: prepInfo == nil ? ["reset":1] : [:], isHide: self.isHide)
    }
    
    @IBAction func didPressDelete() {
        
        prepInfo = nil
        
        dataInfo.removeAllObjects()
        
        dataInfo.addEntries(from:self.defaultSetting().reFormat() as! [AnyHashable : Any])
        
        tableView.reloadData()
    }
    
    @IBAction func didPressConfirm() {
        
        let orderType = dataInfo["0"] as! NSDictionary

        filterInfo["order_direction"] = orderType["id"]
        
        
        let orderStar = dataInfo["1"] as! NSDictionary

        let arrayStar = NSMutableArray()
        
        for index in 0...3 {
//            if orderStar["%i".format(parameters: index)] as! Int == 1 {
            if orderStar.getValueFromKey("%i".format(parameters: index)) == "1" {
                arrayStar.add(Int((orderStar.allKeys[index] as! String) == "3" ? "0" : (orderStar.allKeys[index] as! String) == "0" ? "3" : (orderStar.allKeys[index] as! String))! + 3)
            }
        }
        
        filterInfo["starNumber"] = arrayStar
        
        if isHide {
            filterInfo["starNumber"] = [Information.cardType()["star_level"]]
        }
        
        let orderHotelType = dataInfo["2"] as! NSDictionary

        for dict in orderHotelType.allValues {
            if (dict as! NSDictionary)["active"] as! Int == 1 {
                filterInfo["hotelType"] = (dict as! NSDictionary)["id"]
            }
        }
        
        
        let orderHotelAdd = dataInfo["3"] as! NSDictionary

        let arrayAdd = NSMutableArray()

        for dict in orderHotelAdd.allValues {
            if (dict as! NSDictionary)["active"] as! Int == 1 {
                arrayAdd.add((dict as! NSDictionary)["id"])
            }
        }
        
        filterInfo["additions"] = arrayAdd
        
        self.dismiss(animated: true) {
            
        }
        
        self.filterDelegate?.filterDidNavigationBack(infor: filterInfo, isHide: self.isHide)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension TG_Filter_ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return titles.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return isHide && (section == 0 || section == 1) ? CGFloat.leastNormalMagnitude :  33
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return isHide && (section == 0 || section == 1) ? CGFloat.leastNormalMagnitude :  0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let header = Bundle.main.loadNibNamed("TG_Filter_Header", owner: self, options: nil)?.first
        
        let head = (self.withView(header, tag: 22) as! UILabel)
        
        head.text = " %@".format(parameters: titles[section])
        
        head.isHidden = isHide && (section == 0 || section == 1)
        
        let view = (self.withView(header, tag: 15) as! UIView)
        
        view.alpha = 0
        
        return header as? UIView
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section < 2 ? (isHide && (section == 0 || section == 1)) ? 0 : 1 : (dataInfo["%i".format(parameters: section)] as! NSDictionary).allKeys.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: indexPath.section == 0 ? "TG_Filter_Selection_Cell" : indexPath.section == 1 ? "TG_Filter_Rate_Cell" :/* indexPath.section == 2 ? "TG_Filter_Price_Cell" :*/ "TG_Filter_Type_Cell", for: indexPath)
        
        let dict = dataInfo["%i".format(parameters: indexPath.section)] as! NSMutableDictionary
        
        
        if indexPath.section == 0 {
            
            let selection = self.withView(cell, tag: 11) as! DropButton
            
            let def = dict["default"]
            
            selection.setTitle(def as? String, for: .normal)

            let array = dict["%@".format(parameters: "data")]
            
            selection.action(forTouch: [:]) { (result) in
                selection.didDropDown(withData: array as! [Any], andCompletion: { (selected) in
                    
                    if selected == nil {
                        return
                    }
                    
                    let selecting = ((selected as! NSDictionary)["data"] as! NSDictionary)["title"]
                    
                    selection.setTitle(selecting as? String, for: .normal)
                    
                    dict["default"] = selecting
                    
                    dict["id"] = ((selected as! NSDictionary)["data"] as! NSDictionary)["id"]
                })
            }
        }
        
        if indexPath.section == 1 {
            let rating = self.withView(cell, tag: 11) as! UIStackView
            
            for index in 0...rating.subviews.count - 1 {
                
                let innerDict = dict["%i".format(parameters: index)] as! Int

                let view = (self.withView(rating, tag: Int32(index + 100)) as! UIView)
            
                view.action(forTouch: [:]) { (obj) in
                    
                    (self.withView(view, tag: 1) as! UIImageView).image = UIImage.init(named: (dict["%i".format(parameters: index)] as! Int) == 1 ? "star_g" : "star_yellow")

                    (self.withView(view, tag: 2) as! UILabel).textColor = (dict["%i".format(parameters: index)] as! Int) == 1 ? UIColor.lightGray : AVHexColor.color(withHexString: "#DAAF51")

                    (self.withView(view, tag: 3) as! UIView).alpha = (dict["%i".format(parameters: index)] as! Int) == 1 ? 0 : 1
                    
                    dict["%i".format(parameters: index)] = (dict["%i".format(parameters: index)] as! Int) == 0 ? 1 : 0
                }
                
                (self.withView(view, tag: 1) as! UIImageView).image = UIImage.init(named: innerDict == 0 ? "star_g" : "star_yellow")

                (self.withView(view, tag: 2) as! UILabel).textColor = innerDict == 0 ? UIColor.lightGray : AVHexColor.color(withHexString: "#DAAF51")

                (self.withView(view, tag: 3) as! UIView).alpha = innerDict == 0 ? 0 : 1
            }
        }
        
        
        if indexPath.section >= 2 {
            
            let innerDict = dict["%i".format(parameters: indexPath.row)] as! NSMutableDictionary

            let image = self.withView(cell, tag: 10) as! UIImageView
            
            image.image = UIImage.init(named: (innerDict["img"] as? String)!)
            
            let title = self.withView(cell, tag: 11) as! UILabel
            
            title.text = "%@%@".format(parameters: indexPath.section == 2 ? "" : "           ", (innerDict["title"] as? String)!)
            
            
            let check = self.withView(cell, tag: 12) as! UIButton
            
            check.setImage(UIImage.init(named: (innerDict["active"] as! Int) == 0 ? "check_in" : "check_ac"), for: .normal)

            check.action(forTouch: [:]) { (objc) in
                
                if indexPath.section == 2 {
                    for inside in dict.allValues {
                        (inside as! NSMutableDictionary)["active"] = 0
                    }
                    
                    self.tableView.reloadData()
                }
                
                check.setImage(UIImage.init(named: (innerDict["active"] as! Int) != 0 ? "check_in" : "check_ac"), for: .normal)
                
                innerDict["active"] = (innerDict["active"] as! Int) == 0 ? 1 : 0
            }
        }
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
}
