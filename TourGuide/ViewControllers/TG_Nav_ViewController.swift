//
//  TG_Nav_ViewController.swift
//  TourGuide
//
//  Created by Mac on 7/23/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

protocol NavigationDelegate:class {
    func didNavigationBack(infor: NSDictionary)
}

class TG_Nav_ViewController: UINavigationController {

    weak var navigationDelegate: NavigationDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
