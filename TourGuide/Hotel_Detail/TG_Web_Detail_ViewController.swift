//
//  TG_Web_Detail_ViewController.swift
//  TourGuide
//
//  Created by Thanh Hai Tran on 8/21/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

class TG_Web_Detail_ViewController: UIViewController {

    @IBOutlet var webView: UIWebView!
    
    @IBOutlet var titleLabel: UILabel!

    var detailInfo: NSDictionary!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel.text = detailInfo.response(forKey: "title") ? detailInfo.getValueFromKey("title") : "Crystal Holidays"
        
        webView.loadRequest(URLRequest.init(url: URL.init(string: detailInfo.getValueFromKey("link"))!))
    }

    @IBAction func didPressBack() {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension TG_Web_Detail_ViewController: UIWebViewDelegate {
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        self.showSVHUD("Đang tải", andOption: 0)
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        self.hideSVHUD()
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        self.hideSVHUD()
    }
}
