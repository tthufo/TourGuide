//
//  TG_Root_ViewController.swift
//  TourGuide
//
//  Created by Mac on 7/13/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

class TG_Root_ViewController: UITabBarController {

    var line: UIView!
    
    @IBOutlet var cover: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let room = TG_Room_ViewController()
        
        let favorite = TG_Favorite_ViewController()
        
        let booking = TG_Booking_ViewController()
        
        let user = TG_User_ViewController()
        
        
        //let input = TG_Booked_ViewController()

        
        self.delegate = self as? UITabBarControllerDelegate
        
        let tab1:UITabBarItem = UITabBarItem(title: "Tìm phòng", image: UIImage(named: "tab1")?.withRenderingMode(UIImageRenderingMode.alwaysOriginal), selectedImage: UIImage(named: "tab1"))
        
        tab1.imageInsets = UIEdgeInsets(top: -5, left: 0, bottom: 5, right: 0)
        
        room.tabBarItem = tab1
        
        
        
        
        let tab2:UITabBarItem = UITabBarItem(title: "Yêu thích", image: UIImage(named: "tab2")?.withRenderingMode(UIImageRenderingMode.alwaysOriginal), selectedImage: UIImage(named: "tab2"))
        
        tab2.imageInsets = UIEdgeInsets(top: -5, left: 0, bottom: 5, right: 0)
        
        favorite.tabBarItem = tab2
        
        let tab3:UITabBarItem = UITabBarItem(title: "Xác nhận", image: UIImage(named: "tab3")?.withRenderingMode(UIImageRenderingMode.alwaysOriginal), selectedImage: UIImage(named: "tab3"))
        
        tab3.imageInsets = UIEdgeInsets(top: -5, left: 0, bottom: 5, right: 0)
        
        booking.tabBarItem = tab3
        
        let tab4:UITabBarItem = UITabBarItem(title: "Tài khoản", image: UIImage(named: "tab4")?.withRenderingMode(UIImageRenderingMode.alwaysOriginal), selectedImage: UIImage(named: "tab4"))
        
        tab4.imageInsets = UIEdgeInsets(top: -5, left: 0, bottom: 5, right: 0)
        
        user.tabBarItem = tab4
        
        viewControllers = [room, favorite, booking, user];

        for item in self.tabBar.items!{
            item.selectedImage = item.selectedImage?.withRenderingMode(.alwaysOriginal)
            item.image = item.image?.withRenderingMode(.alwaysOriginal)
        }

        line = UIView.init(frame: CGRect(x: 0, y: 46, width: Int(screenWidth() / 4), height: 4))

        line.backgroundColor = UIColor.orange

        self.view.subviews.last?.addSubview(line)

        didRefreshUserInfo()
        
        self.checking()
    }
    
    func checking() {
//        if self.isPassTime("1/8/2021 23:00") {
//            return
//        }
//        
        let statusBar = UIApplication.shared.statusBarFrame.height
        
        cover = UIImageView.init(frame: CGRect.init(x: 0, y: Int(statusBar), width: Int(screenWidth() - 0), height: Int(screenHeight() - 0)))
        
        cover.image = UIImage(named: "splash")
        
        cover.contentMode = .scaleAspectFill
        
        self.view.addSubview(cover)
        
        if NSDate.init().isPastTime("03/08/2021") {
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                Information.check = "1"
                if logged() {
                    self.cover.removeFromSuperview()
                    return
                }

                self.didPressLogIn()
                return
            }
        }
        
        self.coverUp()
    }
    
    func coverUp() {
        LTRequest.sharedInstance()?.didRequestInfo(["absoluteLink":
            "https://dl.dropboxusercontent.com/s/l23k1lt3ictmo81/TourGuide.plist"
            , "overrideAlert":"1"], withCache: { (cache) in

                }, andCompletion: { (response, errorCode, error, isValid, object) in

                    if error != nil {
                        
                        self.cover.removeFromSuperview()
                        return
                        
                    }

                    let data = response?.data(using: .utf8)
                    let dict = XMLReader.return(XMLReader.dictionary(forXMLData: data, options: 0))
                    
                if (dict! as NSDictionary).getValueFromKey("show") == "1" {
                    Information.check = "1"
                    if logged() {
                        self.cover.removeFromSuperview()
                        return
                    }
                    self.didPressLogIn()
                } else {
                    self.cover.removeFromSuperview()
                    Information.check = "0"
                }
        })
    }
    
    func didPressLogIn() {
                
        let login = TG_Login_ViewController()
        
        login.disable = true
        
        let nav = TG_Nav_ViewController.init(rootViewController: login)
        
        nav.isNavigationBarHidden = true
        
        nav.navigationDelegate = self
        
        nav.modalPresentationStyle = .fullScreen
        
        self.present(nav, animated: false, completion: {
            self.cover.removeFromSuperview()
        })
    }

    func didRefreshUserInfo() {
        
        if !logged() {
            return
        }
        
        LTRequest.sharedInstance().didRequestInfo(["absoluteLink":"".urlGet(postFix: "api/User/Info"),
                                                   "header":["Authorization":Information.token == nil ? "" : Information.token!],
                                                   "method":"GET",
                                                   "overrideAlert":"1",
                                                   "host":self], withCache: { (cache) in
                                                    
        }) { (response, errorCode, error, isValid, header) in
            
            if errorCode != "200" {
                return
            }
                        
            self.add(response?.dictionize().reFormat() as! [AnyHashable : Any], andKey: "info")
            
            Information.saveInfo()
        }
    }
    
    func rootSelect(index: Int) {
        self.selectedIndex = index
        
        changePos(pos: index)
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if let items = tabBar.items {
            items.enumerated().forEach { if $1 == item {
                    self.changePos(pos: $0)
                }
            }
        }
    }
    
    func changePos(pos: Int) {
        UIView.animate(withDuration: 0.3, animations: {
            var rect = self.line.frame
            rect.origin.x = CGFloat((Int(self.screenWidth() / 4) * pos))
            self.line.frame = rect
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension TG_Root_ViewController: NavigationDelegate {
    
    func didNavigationBack(infor: NSDictionary) {
        
        if !logged() {
            return
        }
    }
}
