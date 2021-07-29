//
//  TG_Search_ViewController.swift
//  TourGuide
//
//  Created by Thanh Hai Tran on 9/4/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

protocol SearchDelegate:class {
    func searchDidNavigationBack(infor: NSDictionary)
}

class TG_Search_ViewController: UIViewController, UITextFieldDelegate {

    weak var searchDelegate: SearchDelegate?
    
    var keyWord: String!
    
    var countryId: String = "229"
    
    var dataList: NSMutableArray!
    
    var listCountry: NSMutableArray!
    
    @IBOutlet var tableView: UITableView!
    
    @IBOutlet var searchText: UITextField!
    
    @IBOutlet var mag: UIImageView!
    
    @IBOutlet var country: DropButton!
    
    var refreshHeader: UIRefreshControl!

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.withCell("TG_Filter_Type_Cell")
        
        tableView.withCell("TG_Empty_Cell")
        
        searchText.text = keyWord
        
        dataList = NSMutableArray()
        
        listCountry = NSMutableArray()

        requestArea()
        
        requestCountry()
        
        mag.action(forTouch: [:]) { (objc) in
            if self.searchText.text?.count == 0 {
                return
            }
            
            self.view.endEditing(true)
            
            self.searchDelegate?.searchDidNavigationBack(infor: ["keyword":self.searchText.text, "random":1, "province":"0"])
            
            self.dismiss(animated: true) {
                
            }
        }
        
        refreshHeader = UIRefreshControl.init()
        
        refreshHeader.addTarget(self, action: #selector(requestArea), for: UIControlEvents.valueChanged)
        
        tableView.addSubview(refreshHeader)
        
        self.country.action(forTouch: [:]) { (objc) in
            
            self.view.endEditing(true)
            
            self.country.didDropDown(withData: self.listCountry as! [Any]?, andCompletion: { (result) in
                if result != nil {
                    
                    let selecting = ((result as! NSDictionary)["data"] as! NSDictionary)["province_name"]
                    
                    self.country.setTitle(selecting as? String, for: .normal)
                    
                    let proId = ((result as! NSDictionary)["data"] as! NSDictionary).getValueFromKey("province_id")

                    self.countryId = proId!
                    
                    self.requestArea()
                }
            })
        }
    }
    
    @objc func requestCountry() {
        LTRequest.sharedInstance().didRequestInfo(["absoluteLink":"".urlGet(postFix: "api/Hotels/CountByCountry"),
                                                   "method":"GET",
                                                   "overrideLoading":1,
                                                   "host":self,
                                                   "overrideAlert":1
            ], withCache: { (cache) in
                
        }) { (response, errorCode, error, isValid, header) in
            
            if errorCode != "200" {
                return
            }
            
            let result = response?.dictionize().reFormat()
            
            self.listCountry.removeAllObjects()
            
            self.listCountry.addObjects(from: result!["array"] as! [Any])
        }
    }
    
    @objc func requestArea() {
        LTRequest.sharedInstance().didRequestInfo(["absoluteLink":"".urlGet(postFix: "api/Hotels/CountByProvinceOfCountry"),
                                                   "method":"GET",
                                                   "Getparam":["country_id": self.countryId],
                                                   "overrideLoading":1,
                                                   "host":self,
                                                   "overrideAlert":1
            ], withCache: { (cache) in
                
        }) { (response, errorCode, error, isValid, header) in
            
            if errorCode != "200" {
                return
            }
            
            let result = response?.dictionize().reFormat()
            
            self.dataList.removeAllObjects()
            
            self.dataList.addObjects(from: result!["array"] as! [Any])

            self.tableView.cellVisible()
        }
    }
    
    @IBAction func didPressBack() {
        self.dismiss(animated: true) {
            
        }
        
        let keyCountry = self.country.title(for: .normal)
        
        searchDelegate?.searchDidNavigationBack(infor: ["keyword": keyCountry != "Chọn quốc gia" ? keyCountry : searchText.text, "dismiss":1])
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        searchDelegate?.searchDidNavigationBack(infor: ["keyword":searchText.text, "random":1,"province":"0"])
        
        self.dismiss(animated: true) {
            
        }
        
        return true
    }
    
    @IBAction func didPressDelete() {
        searchText.text = ""
        
        keyWord = ""
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension TG_Search_ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return dataList.count == 0 ? tableView.frame.size.height : UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataList.count == 0 ? 1 : dataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: dataList.count == 0 ? "TG_Empty_Cell" : "TG_Filter_Type_Cell", for: indexPath)
        
        if dataList.count == 0 {
            
            let reTry = (self.withView(cell, tag: 12) as! UIButton)
            
            reTry.action(forTouch: nil) { (obj) in
                
                self.requestArea()
            }
            
            return cell
        }
        
        let hotel = dataList[indexPath.row] as! NSDictionary
        
        (self.withView(cell, tag: 12) as! UIButton).isHidden = true
     
        (self.withView(cell, tag: 11) as! UILabel).text = "%@ (%@)".format(parameters: hotel["province_name"] as! String, hotel.getValueFromKey("total_hotel"))
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if dataList.count == 0 {
            return
        }
        
        let hotel = dataList[indexPath.row] as! NSDictionary
        
        searchDelegate?.searchDidNavigationBack(infor: ["keyword":hotel["province_name"] as! String, "province":hotel.getValueFromKey("province_id")])
        
        self.dismiss(animated: true) {
            
        }
    }
}
