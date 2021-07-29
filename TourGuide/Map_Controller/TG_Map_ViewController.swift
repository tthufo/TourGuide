//
//  TG_Map_ViewController.swift
//  TourGuide
//
//  Created by Mac on 7/26/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

protocol MapDelegate:class {
    func mapDidChangeData(data: NSMutableArray)
}

class TG_Map_ViewController: UIViewController {
    
    weak var mapDelegate: MapDelegate?

    @IBOutlet var bottomBar: UIView!
    
    @IBOutlet var mapBox: MGLMapView!
    
    var dataList: NSMutableArray!
    
    var markerList: NSMutableArray!
    
    var filterInfo: NSMutableDictionary!
    
    var isHide: Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        bottomBar.frame = CGRect.init(x: Int((screenWidth() - 230)/2), y: Int(screenHeight() - 50), width: 230, height: 40)
        
        self.view.addSubview(bottomBar)
        
        mapBox.logoView.isHidden = true
        
        mapBox.attributionButton.isHidden = true
        
        mapBox.showsUserLocation = true
        
        markerList = NSMutableArray()
        
        didUpdateMapData()
    }

    func didUpdateMapData() {
        
        if let annotations = mapBox.annotations {
            mapBox.removeAnnotations(annotations)
        }
        
        var coor = [CLLocationCoordinate2D]()
        
        markerList.removeAllObjects()
        
        for dict in dataList {
            let marker = MGLPointAnnotation()
            
            let hotel = dict as! NSDictionary
            
            marker.accessibilityLabel = hotel.getValueFromKey("star_number")
            
            marker.title = (dict as! NSDictionary).bv_jsonString(withPrettyPrint: true) // hotel["hotel_name"] as? String
            
            marker.subtitle = hotel["address"] as? String
            
            marker.coordinate = CLLocationCoordinate2D(latitude: Double(hotel.getValueFromKey("lat"))!, longitude: Double(hotel.getValueFromKey("lon"))!)
            
            coor.append(CLLocationCoordinate2D(latitude: Double(hotel.getValueFromKey("lat"))!, longitude: Double(hotel.getValueFromKey("lon"))!))
            
            mapBox.addAnnotation(marker)
            
            markerList.add(marker)
        }
        
        mapBox.setVisibleCoordinates(&coor, count: UInt(coor.count), edgePadding: UIEdgeInsetsMake(30, 30, 30, 30), animated: false)
    }
    
    @IBAction func didPressBack() {
        self.dismiss(animated: true) {
            
        }
    }
    
    @IBAction func didPressFilter() {
        let filter = TG_Filter_ViewController()
        
        filter.filterDelegate = self
        
        filter.isHide = self.isHide
        
        filter.modalPresentationStyle = .fullScreen

        if filterInfo.allKeys.count != 0 {
            filter.prepInfo = filterInfo
        }
        
        self.present(filter, animated: true) {
            
        }
        
        if let annotations = mapBox.annotations {
            mapBox.removeAnnotations(annotations)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension TG_Map_ViewController: FilterDelegate {
    
    func filterDidNavigationBack(infor: NSDictionary, isHide: Bool) {
        
        if infor.allKeys.count == 0 {
            return
        }

        filterInfo.removeAllObjects()

        if !infor.response(forKey: "reset") {
            filterInfo.addEntries(from: infor as! [AnyHashable : Any])
        }

        for view in (self.presentingViewController as! TG_Nav_ViewController).viewControllers {
            
            if view.isKind(of: TG_Search_Result_ViewController.self) {
                
                let searchView = (view as! TG_Search_Result_ViewController)
                
                searchView.filterInfo = self.filterInfo
                
                searchView.didRequestHotels(isShow: !infor.response(forKey: "reset"))
            }
        }
    }
}

extension TG_Map_ViewController: MGLMapViewDelegate {

    func mapView(_ mapView: MGLMapView, imageFor annotation: MGLAnnotation) -> MGLAnnotationImage? {
        
        let reuseIdentifier = reuseIdentifierForAnnotation(annotation: annotation)
        
        var annotationImage = mapView.dequeueReusableAnnotationImage(withIdentifier: reuseIdentifier)
        
        if annotationImage == nil {
            let image = imageForAnnotation(annotation: annotation)
            
            annotationImage = MGLAnnotationImage(image: image, reuseIdentifier: reuseIdentifier)
        }
        
        return annotationImage
    }
    
    func reuseIdentifierForAnnotation(annotation: MGLAnnotation) -> String {
        var reuseIdentifier = "\(annotation.coordinate.latitude),\(annotation.coordinate.longitude)"
        if let title = annotation.title, title != nil {
            reuseIdentifier += title!
        }
        if let subtitle = annotation.subtitle, subtitle != nil {
            reuseIdentifier += subtitle!
        }
        return reuseIdentifier
    }
    
    func imageForAnnotation(annotation: MGLAnnotation) -> UIImage {

        let type = (annotation as! MGLPointAnnotation).accessibilityLabel

        return UIImage(named: "maker_%@".format(parameters:type!))!
    }
    
    func mapView(_ mapView: MGLMapView, didSelect annotation: MGLAnnotation) {
                
        if !annotation.isKind(of: MGLUserLocation.self) {
            
            let hotel = (annotation.title as? String)?.dictionize().reFormat()
            
            TG_Menu_View.shareInstance.showMap(host: self, hotel: hotel!) { (hotelId, like) in
                
                if like != "" {
                    
                    for i in stride(from: 0, to: self.dataList.count, by: 1) {
                        if (self.dataList[i] as! NSMutableDictionary).getValueFromKey("id") == like {
                            
                            (self.dataList[i] as! NSMutableDictionary)["isFavorite"] = (self.dataList[i] as! NSMutableDictionary).getValueFromKey("isFavorite") == "0" ? 1 : 0
                            
                            for view in (self.presentingViewController as! TG_Nav_ViewController).viewControllers {
                                
                                if view.isKind(of: TG_Search_Result_ViewController.self) {
                                    
                                    let searchView = (view as! TG_Search_Result_ViewController)
                                    
                                    searchView.reload(hotelId: like, isLike: (self.dataList[i] as! NSMutableDictionary)["isFavorite"] as! Int)
                                }
                            }
                            
                            (self.markerList[i] as! MGLPointAnnotation).title = (self.dataList[i] as! NSDictionary).bv_jsonString(withPrettyPrint: true)
                        }
                    }
                } else {
                    for view in (self.presentingViewController as! TG_Nav_ViewController).viewControllers {
                        
                        if view.isKind(of: TG_Search_Result_ViewController.self) {
                            
                            self.dismiss(animated: true, completion: nil)
                            
                            let searchView = (view as! TG_Search_Result_ViewController)
                            
                            let detail = TG_Hotel_Detail_ViewController()
                            
                            detail.detailInfo = ["hotelId":hotelId]
                            
                            searchView.navigationController?.pushViewController(detail, animated: true)
                        }
                    }
                }
            }
        }
    }
    
//    func didLikeHotel(isLike: Bool, hotelId: String) {
//
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
//            for view in (self.presentingViewController as! TG_Nav_ViewController).viewControllers {
//
//                if view.isKind(of: TG_Search_Result_ViewController.self) {
//
//                    let searchView = (view as! TG_Search_Result_ViewController)
//
////                    searchView
//                }
//            }
//        }
//    }
    
    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        return false
    }
}
