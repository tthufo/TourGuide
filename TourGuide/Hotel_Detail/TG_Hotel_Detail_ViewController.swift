//
//  TG_Hotel_Detail_ViewController.swift
//  TourGuide
//
//  Created by Mac on 8/21/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

import SwiftyStarRatingView

import FSPagerView

protocol DetailDelegate:class {
    func detailDidNavigationBack(infor: NSDictionary)
}

class TG_Hotel_Detail_ViewController: UIViewController, FSPagerViewDataSource,FSPagerViewDelegate {

    weak var detailDelegate: DetailDelegate?

    @IBOutlet var tableView: UITableView!
    
    @IBOutlet var bottomView: UIView!

    var dataList: NSMutableArray!
    
    var imageList: NSMutableArray!
    
    var dataInfo: NSMutableDictionary!
    
    var detailInfo: NSDictionary!
    
    var roomType: String!
    
    @IBOutlet var buffet: NSLayoutConstraint!
    
    @IBOutlet var topCell: UITableViewCell!

    @IBOutlet var roomBtn: DropButton!
    
    @IBOutlet var orderBtn: UIButton!

    @IBOutlet var alert: NSLayoutConstraint!
    
    @IBOutlet var topTitle: UILabel!
    
    let titles = ["", "Loại phòng", "Tiện nghi"]
    
    @IBOutlet var pageControl: UIPageControl!
    
    @IBOutlet weak var pagerView: FSPagerView! {
        didSet {
            self.pagerView.register(FSPagerViewCell.self, forCellWithReuseIdentifier: "cell")
            self.pagerView.itemSize = .zero
            self.pagerView.interitemSpacing = 10
            self.pagerView.alwaysBounceHorizontal = true
            self.pagerView.isInfinite = true
            self.pagerView.automaticSlidingInterval = 3
        }
    }
    
    func numberOfItems(in pagerView: FSPagerView) -> Int {
        return self.imageList.count
    }
    
    func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
        pagerView.deselectItem(at: index, animated: true)
    }
    
    public func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "cell", at: index)
        let image = self.imageList.count == 0 ? "" : (self.imageList![index] as! NSDictionary).getValueFromKey("image_name")
        cell.imageView?.imageUrl(url: image as! String)
        cell.imageView?.contentMode = .scaleAspectFill
        return cell
    }
    
    func pagerViewDidScroll(_ pagerView: FSPagerView) {
        guard self.pageControl.currentPage != pagerView.currentIndex else {
            return
        }
        self.pageControl.currentPage = pagerView.currentIndex
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        roomType = ""
        
        tableView.withCell("TG_Filter_Type_Cell")

        tableView.withHeaderOrFooter("TG_Filter_Header")
        
        dataList = NSMutableArray()
        
        imageList = NSMutableArray()
        
        dataInfo = NSMutableDictionary()
        
        tableView.contentInset = UIEdgeInsetsMake(0, 0, detailInfo.response(forKey: "disable") ? 0 : 35, 0)
        
        bottomView.isHidden = detailInfo.response(forKey: "disable")
        
        alert.constant = 0
        
        didRequestDetail()
    }

    func didRequestDetail() {
        LTRequest.sharedInstance().didRequestInfo(["absoluteLink":"".urlGet(postFix: "api/Hotels/Detail"),
                                                   "header":["Authorization":Information.token == nil ? "" : Information.token!],
                                                   "method":"GET",
                                                   "Getparam":["id": detailInfo.getValueFromKey("hotelId")],
                                                   "host":self,
                                                   "overrideLoading":1,
                                                   "overrideAlert":1
            ], withCache: { (cache) in
                
        }) { (response, errorCode, error, isValid, header) in

            if errorCode != "200" {
                self.showToast("Lỗi xảy ra, mời bạn thử lại", andPos: 0)
                
                return
            }
            
            self.bottomView.isUserInteractionEnabled = true
            
            self.didReformatData(data: (response?.dictionize().reFormat())!)
        }
    }
    
    func roomNumb() -> NSMutableArray {
        let array = NSMutableArray()
        
//        let total = ((dataInfo["total_avaiable_room"] as! Int) < (Information.room as NSString).integerValue) ? (dataInfo["total_avaiable_room"] as! Int) : (Information.room as NSString).integerValue + 1
        
        var total = 0
        
        if (dataInfo.getValueFromKey("total_avaiable_room") as NSString).integerValue > (Information.room as NSString).integerValue {
            total = (dataInfo["total_avaiable_room"] as! Int) + 1
        } else {
            total = (Information.room as NSString).integerValue + 1
        }
        
        for i in stride(from: 1, to: total, by: 1) {
            array.add(["title":"  %i phòng".format(parameters: i), "number_of_room":i])
        }
        
        return array
    }
    
    @IBAction func didPressRoom(sender: DropButton) {
        sender.didDropDown(withData: roomNumb() as! [Any]) { (objc) in
            
            if (objc != nil) {
                
                let name = objc as! NSDictionary
                
                sender.setTitle((name["data"] as! NSDictionary)["title"] as? String, for: .normal)
                
                self.dataInfo["number_of_room"] = (name["data"] as! NSDictionary)["number_of_room"]
            }
        }
    }
    
    @IBAction func didPressSubmit() {
        
        if roomType == "" {
            self.showToast("Bạn chưa chọn loại phòng", andPos: 0)
            
            return
        }
        
        let input = TG_Information_Input_ViewController()
        
        input.inputDelegate = self
        
        dataInfo["end"] = Information.end// detailInfo["end"]
        
        dataInfo["start"] = Information.start//detailInfo["start"]
        
        dataInfo["roomType"] = dataInfo["room_type_and_name"]
        
        dataInfo["roomNumber"] = dataInfo["number_of_room"]
        
        input.detailInfo = dataInfo
        
        self.navigationController?.pushViewController(input, animated: true)
    }
    
    func didReformatData(data: NSMutableDictionary) {
        
        dataInfo.removeAllObjects()

        let arr = data["HotelRoomTypes"] as! NSArray
        
        for dict in arr {
            (dict as! NSMutableDictionary)["active"] = 0
        }
        
        dataInfo.addEntries(from: data as! [AnyHashable : Any])
        
        dataInfo["hasBuffet"] = self.detailInfo["hasBuffet"]
        
        roomBtn.setTitle("  %@ phòng".format(parameters: Information.room), for: .normal)
        
        dataInfo["number_of_room"] = (Information.room as NSString).integerValue
        
        self.didLayoutDetail()
    }
    
    func didLayoutDetail() {
        
        self.imageList.addObjects(from: dataInfo["HotelImages"] as! [Any])
        
        self.pageControl.numberOfPages = self.imageList!.count

        self.pagerView.alpha = self.imageList.count == 0 ? 0 : 1
        
        self.pagerView.reloadData()
        
        let image = self.withView(topCell, tag: 10) as! UIImageView
        
        image.imageUrl(url: dataInfo.getValueFromKey("avatar_image"))
        
        (self.withView(topCell, tag: 11) as! UILabel).text = dataInfo.getValueFromKey("hotel_name")
        
        (self.withView(topCell, tag: 12) as! UILabel).text = "Địa chỉ: %@ %@ %@ %@".format(parameters: dataInfo.getValueFromKey("address"), dataInfo.getValueFromKey("district"), dataInfo.getValueFromKey("province"), dataInfo.getValueFromKey("distance_from_center"))
        
        (self.withView(topCell, tag: 13) as! UILabel).text = "Điện thoại liên hệ: %@".format(parameters: dataInfo.getValueFromKey("phone"))

        (self.withView(topCell, tag: 14) as! UILabel).text = ""//"Giá: %@VNĐ".format(parameters: (dataInfo.getValueFromKey("price")! as NSString).numb())

        buffet.constant = dataInfo.getValueFromKey("hasBuffet") == "0" ? 0 : 100
                
        (self.withView(topCell, tag: 15) as! UILabel).action(forTouch: [:]) { (obj) in
            let webView = TG_Web_Detail_ViewController()
            
            webView.detailInfo = ["link":self.dataInfo.getValueFromKey("website")]
            
            self.navigationController?.pushViewController(webView, animated: true)
        }
        
        (self.withView(topCell, tag: 17) as! SwiftyStarRatingView).value = self.dataInfo["star_number"] as! CGFloat
        
        (self.withView(topCell, tag: 19) as! UILabel).text = "%@ %@ %@".format(parameters: dataInfo.getValueFromKey("address"), dataInfo.getValueFromKey("district"), dataInfo.getValueFromKey("province"))
        
        
        tableView.reloadData()
    }
    
    func checkForRoomType(data: NSArray, id: String) {
        for dict in data {
            if ((dict as! NSDictionary)["room_type"] as! NSDictionary).getValueFromKey("id") == id {
                (dict as! NSMutableDictionary)["active"] = (dict as! NSMutableDictionary).getValueFromKey("active") == "1" ? 0 : 1
                roomType = (dict as! NSMutableDictionary).getValueFromKey("active") == "1" ? id : ""
                if (dict as! NSMutableDictionary).getValueFromKey("active") == "1" {
                    self.dataInfo["room_type_and_name"] = ["roomName":(dict as! NSDictionary)["room_name"], "roomTypeId":(dict as! NSDictionary)["room_type_id"]]
                } else {
                    self.dataInfo.removeObject(forKey: "room_type_and_name")
                }
            } else {
                (dict as! NSMutableDictionary)["active"] = 0
            }
        }
        
        tableView.reloadSections(NSIndexSet.init(index: 1) as IndexSet, with: .none)
    }
    
    @IBAction func didPressBack() {
        self.navigationController?.popViewController(animated: true)
        
        self.detailDelegate?.detailDidNavigationBack(infor: ["isFavorite":dataInfo["isFavorite"] ?? "", "id":dataInfo["id"] ?? ""])
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension TG_Hotel_Detail_ViewController: InputDelegate {
    
    func inputDidNavigationBack(infor: NSDictionary) {
        
        dataInfo["isFavorite"] = infor["isFavorite"]
        
        tableView.reloadData()
    }
}

extension TG_Hotel_Detail_ViewController: MGLMapViewDelegate {
    
    func mapView(_ mapView: MGLMapView, imageFor annotation: MGLAnnotation) -> MGLAnnotationImage? {
        var annotationImage = mapView.dequeueReusableAnnotationImage(withIdentifier: "hotel")
        
        if annotationImage == nil {
            
            var image = UIImage(named: "maker_%@".format(parameters: dataInfo.response(forKey: "star_number") ? dataInfo.getValueFromKey("star_number") : "0"))!

            image = image.withAlignmentRectInsets(UIEdgeInsets(top: 0, left: 0, bottom: image.size.height/2, right: 0))
            
            annotationImage = MGLAnnotationImage(image: image, reuseIdentifier: "hotel")
        }
        
        return annotationImage
    }
    
    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        return true
    }
}

extension TG_Hotel_Detail_ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return titles.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? CGFloat.leastNormalMagnitude : 33
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
        return indexPath.section == 0 ? 560 : 48
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.section == 0 ? 560 : 48
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : section == 1 ? dataInfo["HotelRoomTypes"] == nil ? 0 : (dataInfo["HotelRoomTypes"] as! NSArray).count : dataInfo["HotelAdditions"] == nil ? 0 : (dataInfo["HotelAdditions"] as! NSArray).count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            
            let mapBox = self.withView(topCell, tag: 18) as! MGLMapView
            
            mapBox.logoView.isHidden = true
            
            mapBox.attributionButton.isHidden = true
            
            mapBox.delegate = self
            
            if dataInfo.response(forKey: "lat") {
                
                let hotel = MGLPointAnnotation()
                
                hotel.coordinate = CLLocationCoordinate2D(latitude: Double(dataInfo.getValueFromKey("lat"))!, longitude: Double(dataInfo.getValueFromKey("lon"))!)
                
                mapBox.addAnnotation(hotel)
                
                mapBox.setCenter(hotel.coordinate, zoomLevel: 12, animated: true)
            }

            return topCell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TG_Filter_Type_Cell", for: indexPath)
        
        let list: NSMutableDictionary = indexPath.section == 1 ? (dataInfo["HotelRoomTypes"] as! NSArray)[indexPath.row] as! NSMutableDictionary : (dataInfo["HotelAdditions"] as! NSArray)[indexPath.row] as! NSMutableDictionary
        
        
        let contentTitle = indexPath.section == 1 ? list["room_name"] : (list["addition"] as! NSDictionary)["description"]

        let title = self.withView(cell, tag: 11) as! UILabel

        title.text = "%@%@".format(parameters: indexPath.section == 1 ? "" : "           ", contentTitle as! String)

        let image = self.withView(cell, tag: 10) as! UIImageView


        let check = self.withView(cell, tag: 12) as! UIButton

        if indexPath.section == 1 {
            image.isHidden = true
            
            check.isHidden = false
            
            check.setImage(UIImage.init(named: (list["active"] as! Int) == 0 ? "check_in" : "check_ac"), for: .normal)

            check.action(forTouch: [:]) { (objc) in

                let roomTypeId = (list["room_type"] as! NSDictionary).getValueFromKey("id")
                
                self.checkForRoomType(data: (self.dataInfo["HotelRoomTypes"] as! NSArray), id: roomTypeId!)
            }
        } else {
            check.isHidden = true
            
            image.isHidden = false

            image.image = UIImage.init(named: "ic_%@_a".format(parameters: (list["addition"] as! NSDictionary).getValueFromKey("id")))
        }
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
}
