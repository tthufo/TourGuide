//
//  TG_User_ViewController.swift
//  TourGuide
//
//  Created by Mac on 7/13/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

class TG_User_ViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    
    weak var dataList: NSMutableArray!
    
    @IBOutlet var topCell: UITableViewCell!
    
    
    
    
    
    
    @IBOutlet var imageView: UIImageView!
    
    @IBOutlet var titleNotLog: UILabel!
    
    @IBOutlet var titleLoggedAccount: UILabel!

    @IBOutlet var titleLoggedPoint: UILabel!

    @IBOutlet var titleLoggedUserName: UILabel!

    @IBOutlet var titleLoggedUserPoint: UILabel!

    
    
    
    @IBOutlet var imageNotLogLogin: UIImageView!

    @IBOutlet var imageNotLogRegister: UIImageView!

    @IBOutlet var titleNotLogLogin: UILabel!

    @IBOutlet var titleNotLogRegister: UILabel!

    

    
    
//    var titles: NSArray = ["Thông báo", "Về Crystal Holiday Hotel", "Đăng xuất"]
    
    var titles: NSArray = ["Về Crystal Holidays", "Đăng xuất"]

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.withCell("TG_User_Cell_N")
        
        tableView.withHeaderOrFooter("TG_Filter_Header")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.rowHeight = UITableViewAutomaticDimension
        
        didChangeState(isLogIn: logged())
    }
    
    func didChangeState(isLogIn: Bool) {
        
        imageNotLogLogin.image = UIImage.init(named: isLogIn ? "account" : "login")
        
        imageNotLogRegister.image = UIImage.init(named: isLogIn ? "points-1" : "points-1")
        
        titleNotLogLogin.text = isLogIn ? "Quản lý tài khoản" : "Đăng nhập"
        
        titleNotLogRegister.text = isLogIn ? "CHR point" : "CHR point"
        
        titleNotLog.alpha = isLogIn ? 0 : 1
        
        titleLoggedAccount.alpha = isLogIn ? 1 : 0
        
        titleLoggedPoint.alpha = isLogIn ? 1 : 0
        
        titleLoggedUserName.alpha = isLogIn ? 1 : 0
        
        titleLoggedUserPoint.alpha = isLogIn ? 1 : 0
        
        titleLoggedUserPoint.text = Information.userInfo?.getValueFromKey("remain_nights")
        
        if logged() {
            let userInfo = INFO()["CustomerBasicInfo"] as! NSDictionary
            
            titleLoggedUserName.text = userInfo["Email"] as! String
        } else {
            titleLoggedUserName.text = ""
        }

        tableView.reloadData(withAnimation: logged())
    }
    
    func call(phoneNumber: String) {
        if let url = URL(string: phoneNumber) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url, options: [:],
                                          completionHandler: {
                                            (success) in
                                            print("Open \(phoneNumber): \(success)")
                })
            } else {
                let success = UIApplication.shared.openURL(url)
                print("Open \(phoneNumber): \(success)")
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension TG_User_ViewController: NavigationDelegate {
    
    func didNavigationBack(infor: NSDictionary) {
        didChangeState(isLogIn: logged())
    }
}

extension TG_User_ViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 33
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        let header = Bundle.main.loadNibNamed("TG_Filter_Header", owner: self, options: nil)?.first
        
        let appInfo = self.appInfor()
        
        let head = (self.withView(header, tag: 22) as! UILabel)
        
        head.text = "Phiên bản %@  ".format(parameters: appInfo!["majorVersion"] as! CVarArg)
        
//        head.text = "Phiên bản 1.0"

        head.font = UIFont.italicSystemFont(ofSize: 14)
        
        head.textColor = UIColor.darkText
        
        head.textAlignment = .right
        
        head.backgroundColor = UIColor.clear
        
        let view = (self.withView(header, tag: 15) as! UIView)
        
        view.alpha = 0
        
        return header as? UIView
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.row == 0 ? 495 : 55
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.row == 0 ? 495 : 55
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return logged() ? 3 : 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = indexPath.row == 0 ? topCell : tableView.dequeueReusableCell(withIdentifier: "TG_User_Cell_N", for: indexPath)
        
        if indexPath.row > 0 {
            let title = self.withView(cell, tag: 11) as! UIButton
            
            title.setTitle(titles[indexPath.row - 1] as? String, for: .normal)

        } else {
            let login = self.withView(cell, tag: 100) as! UIView
            
                login.action(forTouch: [:]) { (obj) in
                    
                    if !logged() {
                        
                        let nav = TG_Nav_ViewController.init(rootViewController: TG_Login_ViewController())
                        
                        nav.isNavigationBarHidden = true
                        
                        nav.navigationDelegate = self
                        
                        nav.modalPresentationStyle = .fullScreen

                        self.present(nav, animated: true, completion: {
                            
                        })
                    } else {
                        
                        let nav = TG_Nav_ViewController.init(rootViewController: TG_UserInfo_ViewController())
    
                        nav.isNavigationBarHidden = true
    
                        nav.modalPresentationStyle = .fullScreen

                        self.present(nav, animated: true) {
    
                        }
                    }
                }
            
            let reg = self.withView(cell, tag: 101) as! UIView
            
            reg.action(forTouch: [:]) { (obj) in
//                let nav = UINavigationController.init()
//
//                let reg = TG_Register_ViewController()
//
//                reg.isPresent = true
//
//                nav.viewControllers = [TG_Login_ViewController(), reg]
//
//                nav.isNavigationBarHidden = true
//
//                self.present(nav, animated: true, completion: {
//
//                })
                
//                self.present(TG_Point_ViewController(), animated: true) {
//
//                }
                
                TG_PopUp_View.init().initWithContent(content: [:], finished: { (object) in
                    print(object)
                })
            }
            
            
            let rate = self.withView(cell, tag: 104) as! UIView
            
            rate.action(forTouch: [:]) { (obj) in
//                let nav = TG_Nav_ViewController.init(rootViewController: TG_UserInfo_ViewController())
//
//                nav.isNavigationBarHidden = true
//
//                self.present(nav, animated: true) {
//
//                }
                
                let webDetail = TG_Web_Detail_ViewController()
                
                webDetail.detailInfo = ["title":"Đánh giá phản hồi", "link":"http://crystalholidays.vn/lien-he/"]
                
                self.navigationController?.pushViewController(webDetail, animated: true)
            }
            
            
            let phone = self.withView(cell, tag: 105) as! UIView
            
            phone.action(forTouch: [:]) { (obj) in

//                self.present(TG_Point_ViewController(), animated: true) {
//
//                }
                
                self.call(phoneNumber: "tel://1900292992")
            }
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row == 1 {
            let webDetail = TG_Web_Detail_ViewController()
            
            webDetail.detailInfo = ["title":"Về Crystal Holidays", "link":"http://crystalholidays.vn/ve-chung-toi/"]
            
            self.navigationController?.pushViewController(webDetail, animated: true)
        }
        
        if indexPath.row == 2 {            
            Information.removeInfo()
            
            didChangeState(isLogIn: logged())
            
            tableView.didScrolltoTop(true)
            
            if Information.check == "1" {
                let login = TG_Login_ViewController()

                let nav = TG_Nav_ViewController.init(rootViewController: login)
                
                login.disable = true

                nav.isNavigationBarHidden = true
                
                nav.navigationDelegate = self
                
                nav.modalPresentationStyle = .fullScreen

                self.present(nav, animated: true, completion: {
                    
                })
            }
        }
    }
}
