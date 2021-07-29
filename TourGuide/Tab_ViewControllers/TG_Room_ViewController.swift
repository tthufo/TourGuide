//
//  TG_Room_ViewController.swift
//  TourGuide
//
//  Created by Mac on 7/13/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

class TG_Room_ViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    
    @IBOutlet var bar: UIView!
        
    var topList: NSMutableArray!
    
    var bottomList: NSMutableArray!

    var kb: KeyBoard!
    
    var keyWord: String = ""

    var proId: String = "0"

    
    var dateRange: NSMutableDictionary!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        kb = KeyBoard.shareInstance()
        
        tableView.withCell("TG_Room_Cell")
        
        tableView.withCell("TG_Room_Cell_N")

        let today = Date()
        
        let tomorrow = Calendar.current.date(byAdding: .day, value: 6, to: today)
        
        
        Information.start = today
        
        Information.end = tomorrow
        
        dateRange = NSMutableDictionary.init(dictionary: ["start":today, "end":tomorrow])
        
        topList = NSMutableArray()
        
        bottomList = NSMutableArray()

        didRequestPermission()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        kb.keyboardOff()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        kb.keyboard(on: ["bar":bar, "host":self]) { (height, isOn) in
            
        }
    }
    
    @IBAction func disMiss() {
        self.view.endEditing(true)
    }
    
    @IBAction func didPressCalendar(isStart: Bool) {
        let dateRangePickerViewController = CalendarDateRangePickerViewController()
        dateRangePickerViewController.delegate = self
        dateRangePickerViewController.minimumDate = Date()
        dateRangePickerViewController.maximumDate = Calendar.current.date(byAdding: .year, value: 1, to: Date())
        if isStart {
            dateRangePickerViewController.selectedEndDate = dateRange["end"] as? Date
        } else {
            dateRangePickerViewController.selectedStartDate = dateRange["start"] as? Date
        }
        
        dateRangePickerViewController.modalPresentationStyle = .fullScreen
        
        self.navigationController?.present(dateRangePickerViewController, animated: true, completion: nil)
    }
    
    func didGotoWebDetail(url: String) {
        let webView = TG_Web_Detail_ViewController()
        
        webView.detailInfo = ["link":url]
        
        self.navigationController?.pushViewController(webView, animated: true)
    }
    
    func didRequestWithKeyword(keyWord: String) {
        let searchView = TG_Search_Result_ViewController()
        
        let startDate = self.dateRange["start"] as! Date
        
        let endDate = self.dateRange["end"] as! Date
        
        searchView.proId = self.proId

        searchView.searchInfo = ["best":"1", "type":keyWord, "start":startDate, "end":endDate, "keyword":keyWord, "mag":""]
        
        self.navigationController?.pushViewController(searchView, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func didRequestPermission() {
        Permission.shareInstance().initLocation(false) { (type) in
            switch(type) {
            case .lAlways, .lWhenUse:
                break
            case .lNotSure:
                break
            case .lDenied, .lRestricted, .lDisabled:
                self.showToast("Crystal Holidays cần dùng vị trí của bạn cho việc tìm khách sạn chính xác nhất.", andPos: 0)
                break
            }
        }
    }
    
    @objc func didReloadData() {
        self.tableView.reloadData()
    }
}

extension TG_Room_ViewController : CalendarDateRangePickerViewControllerDelegate {
    func didCancelPickingDateRange() {
        self.navigationController?.dismiss(animated: true, completion: nil)

    }
    
    func didPickDateRange(startDate: Date!, endDate: Date!) {
        self.navigationController?.dismiss(animated: true, completion: nil)

        dateRange["start"] = startDate
        
        dateRange["end"] = endDate
        
        Information.start = startDate
        
        Information.end = endDate
        
        tableView.reloadData()
    }
}

extension TG_Room_ViewController: SearchDelegate {
    func searchDidNavigationBack(infor: NSDictionary) {
        
        if infor.response(forKey: "province") {
            self.proId = infor.getValueFromKey("province")
        }
        
        self.keyWord = infor["keyword"] as! String
        
        if infor.response(forKey: "random") {
            //self.didRequestWithKeyword(keyWord: self.keyWord)
        } else if infor.response(forKey: "dismiss") {
            
        } else {
            let searchView = TG_Search_Result_ViewController()
            
            let startDate = self.dateRange["start"] as! Date
            
            let endDate = self.dateRange["end"] as! Date
            
            searchView.proId = self.proId

            searchView.searchInfo = ["province":infor["province"] as! String, "type":self.keyWord, "start":startDate, "end":endDate, "keyword":self.keyWord]
            
            //self.navigationController?.pushViewController(searchView, animated: true)
        }
        
        self.perform(#selector(didReloadData), with: nil, afterDelay: 0.5)
    }
}

extension TG_Room_ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.row == 0 ? 515 : CGFloat(Int(screenWidth()/2 - 30 + 37))
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: indexPath.row == 0 ? "TG_Room_Cell" : "TG_Room_Cell_N", for: indexPath)
        
        if(indexPath.row == 0) {

            let startDate = dateRange["start"] as! Date
            
            let start = self.withView(cell, tag: 10) as! UIView
            
            
            let sDay = self.withView(cell, tag: 200) as! UILabel
            
            sDay.text = startDate.dateComp(type: 0)// self.dateComp(date: startDate, type: 0)
            
            let sWeekDay = self.withView(cell, tag: 201) as! UILabel
            
            sWeekDay.text = "Thứ %@".format(parameters: startDate.dateComp(type: 1))//self.dateComp(date: startDate, type: 1))
            
            let sMonth = self.withView(cell, tag: 202) as! UILabel
            
            sMonth.text = "Tháng %@".format(parameters: startDate.dateComp(type: 2))//self.dateComp(date: startDate, type: 2))
            
            
            start.action(forTouch: [:]) { (obj) in
                self.didPressCalendar(isStart: true)
            }
            
            
            
            
            
            
            let endDate = dateRange["end"] as! Date

            let end = self.withView(cell, tag: 11) as! UIView
            
            
            let eDay = self.withView(cell, tag: 300) as! UILabel
            
            eDay.text = endDate.dateComp(type: 0)//self.dateComp(date: endDate, type: 0)
            
            let eWeekDay = self.withView(cell, tag: 301) as! UILabel
            
            eWeekDay.text = "Thứ %@".format(parameters: endDate.dateComp(type: 1))//self.dateComp(date: endDate, type: 1))

            let eMonth = self.withView(cell, tag: 302) as! UILabel
            
            eMonth.text = "Tháng %@".format(parameters: endDate.dateComp(type: 2))//self.dateComp(date: endDate, type: 1))

            
            end.action(forTouch: [:]) { (obj) in
                self.didPressCalendar(isStart: false)
            }
            
            
            
            
            
            
            let pick = self.withView(cell, tag: 12) as! UIView
            
            
            let r = self.withView(cell, tag: 999) as! UILabel
            
            let g = self.withView(cell, tag: 1000) as! UILabel

            
            pick.action(forTouch: [:]) { (obj) in
                TG_Menu_View.shareInstance.showWith(room: Int(r.text!)!, guest: Int(g.text!)!, finished: { (room, guest) in
                    
                    r.text = "%@%i".format(parameters: room >= 10 ? "" : "0" , room)
                    
                    g.text = "%@%i".format(parameters: guest >= 10 ? "" : "0" , guest)
                    
                    Information.room = "%i".format(parameters: room)
                                        
                    Information.guest = "%i".format(parameters: guest)
                    
                })
            }
            
            
            
            
            let chooseBest = self.withView(cell, tag: 99) as! UIButton
            
            chooseBest.action(forTouch: [:]) { (obj) in
                
                let keyWord = (self.withView(cell, tag: 10000) as! UITextField).text
                
                let searchView = TG_Search_Result_ViewController()

                let startDate = self.dateRange["start"] as! Date

                let endDate = self.dateRange["end"] as! Date

                searchView.proId = self.proId
                
                searchView.searchInfo = ["best":"1", "type":"Tìm phòng tốt nhất", "start":startDate, "end":endDate, "keyword":keyWord, "isHide":"1"]

                self.navigationController?.pushViewController(searchView, animated: true)
            }
            
            
        
            
            let chooseAll = self.withView(cell, tag: 9999) as! UIButton
            
//            chooseAll.isEnabled = self.keyWord != ""
//
//            chooseAll.alpha = self.keyWord != "" ? 1 : 0.5

            
            chooseAll.action(forTouch: [:]) { (obj) in
                
                if self.keyWord == "" {
                    self.showToast("Hãy nhập nơi bạn cần tìm khách sạn", andPos: 0)
                    
                    return
                }
                
                let keyWord = (self.withView(cell, tag: 10000) as! UITextField).text

                let searchView = TG_Search_Result_ViewController()
                
                let startDate = self.dateRange["start"] as! Date
                
                let endDate = self.dateRange["end"] as! Date
                
                searchView.proId = self.proId

                searchView.searchInfo = ["best":"1", "type":"Tìm KS theo điểm đến", "start":startDate, "end":endDate, "all":0, "keyword":keyWord]
                
                self.navigationController?.pushViewController(searchView, animated: true)
            }
            
            
            
            
            let mag = self.withView(cell, tag: 1989) as! UIImageView
            
            mag.action(forTouch: [:]) { (obj) in
                
                let keyWord = (self.withView(cell, tag: 10000) as! UITextField).text
                
                if keyWord?.count == 0 {
                    self.showToast("Hãy nhập nơi bạn cần tìm khách sạn", andPos: 0)
                    
                    return
                }
                
                let searchView = TG_Search_Result_ViewController()
                
                let startDate = self.dateRange["start"] as! Date
                
                let endDate = self.dateRange["end"] as! Date
                
                searchView.proId = self.proId

                searchView.searchInfo = ["best":"1", "type":keyWord, "start":startDate, "end":endDate, "keyword":keyWord, "mag":""]
                
                self.navigationController?.pushViewController(searchView, animated: true)
            }
            
            
            
            
            let location = self.withView(cell, tag: 500) as! UIImageView
            
            location.action(forTouch: [:]) { (obj) in
                
                let keyWord = (self.withView(cell, tag: 10000) as! UITextField).text
                
                let searchView = TG_Search_Result_ViewController()
                
                let startDate = self.dateRange["start"] as! Date
                
                let endDate = self.dateRange["end"] as! Date
                
                searchView.proId = self.proId

                searchView.searchInfo = [/*"best":"1", */"type":"Tìm quanh đây", "start":startDate, "end":endDate, "keyword":keyWord]
                
                self.navigationController?.pushViewController(searchView, animated: true)
            }
            
            
            
            
            let searhView = self.withView(cell, tag: 20000) as! UIView
            
            searhView.action(forTouch: [:]) { (obj) in
                
                let keyWord = (self.withView(cell, tag: 10000) as! UITextField).text
                
                let searchView = TG_Search_ViewController()
                
                searchView.searchDelegate = self
                
                searchView.keyWord = keyWord
                
                searchView.modalPresentationStyle = .fullScreen
                
                self.present(searchView, animated: true, completion: {
                    
                })
            }
            
            let searchText = (self.withView(cell, tag: 10000) as! UITextField)
            
            searchText.text = self.keyWord
        
            //(CustomField.shareText() as! CustomField).didDeploytext({ (index, texting) in
                
                //print(texting)
                
            //}, with: searchText)
            
        } else {

        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
}
