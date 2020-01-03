//
//  Information.swift
//  TourGuide
//
//  Created by Mac on 8/18/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

class Information: NSObject {
    @objc static var token: String?
    
    static var userInfo: NSDictionary?
    
    static var start: Date!
    
    static var end: Date!
    
    static var room: String = "1"
    
    static var guest: String = "1"

    
    static func saveToken() {
        
        if self.getValue("token") != nil {
            token = "Bearer %@".format(parameters: self.getValue("token"))
        } else {
            token = nil
        }
    }
    
    static func saveInfo() {
        if self.getObject("info") != nil {
            userInfo = self.getObject("info")! as NSDictionary
        } else {
            userInfo = nil
        }
    }
    
    static func removeInfo() {
        
        self.removeValue("token")

        token = nil
        
        self.remove("info")

        userInfo = nil
    }
    
    static func cardType() -> NSDictionary {
        
        if userInfo == nil {
            return ["star_level":0]
        }
                
        let cardType = userInfo!["CardType"]
        
        return cardType as! NSDictionary
    }
}
