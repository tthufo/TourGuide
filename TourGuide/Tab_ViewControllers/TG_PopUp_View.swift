//
//  TG_PopUp_View.swift
//  TourGuide
//
//  Created by Mac on 8/17/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

class TG_PopUp_View: CustomIOS7AlertView {
  
    func initWithContent(content: NSDictionary, finished: @escaping (_ obj: NSDictionary) -> Void) {
        let base = Bundle.main.loadNibNamed("TG_Menu_View",
                                            owner: nil,
                                            options: nil)?[2] as! UIView
        base.frame = CGRect.init(x: 0, y: 0, width: 300, height: 230)
        
        let request = self.withView(base, tag: 11) as! UIButton
        
        request.action(forTouch: [:]) { (obj) in
            self.close()
            
            finished(["1":""])
        }
        
        let carecenter = self.withView(base, tag: 12) as! UIButton
        
        carecenter.action(forTouch: [:]) { (obj) in
            self.close()
            
            finished(["2":""])
        }
        
        self.containerView = base
        
        self.useMotionEffects = true
        
        show()
    }
    
    override func close() {
        super.close()
    }
}
