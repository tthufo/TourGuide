//
//  TG_Room_Cell.swift
//  TourGuide
//
//  Created by Mac on 7/13/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

import FSPagerView

class TG_Room_Cell: UITableViewCell, FSPagerViewDataSource,FSPagerViewDelegate, UITextFieldDelegate {

    var images: NSMutableArray? = []
    
    @IBOutlet var searchField: TextFieldTint!
    
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
        return self.images!.count
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        (self.parentViewController() as! TG_Room_ViewController).didRequestWithKeyword(keyWord: textField.text!)
        
        return true
    }
    
    public func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "cell", at: index)
        let image = (images![index] as! NSDictionary).getValueFromKey("image")
        cell.imageView?.imageUrl(url: image as! String)
        cell.imageView?.contentMode = .scaleAspectFill
        return cell
    }
    
    func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
        pagerView.deselectItem(at: index, animated: true)
        let url = (images![index] as! NSDictionary).getValueFromKey("url")
        (self.parentViewController() as! TG_Room_ViewController).didGotoWebDetail(url: url!)
    }
    
    func pagerViewDidScroll(_ pagerView: FSPagerView) {
        guard self.pageControl.currentPage != pagerView.currentIndex else {
            return
        }
        self.pageControl.currentPage = pagerView.currentIndex 
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.searchField.delegate = self
        
        self.pageControl.numberOfPages = self.images!.count
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()

        if let clearButton = searchField.value(forKeyPath: "_clearButton") as? UIButton {
            clearButton.setImage(UIImage(named:"x"), for: .normal)
            clearButton.setImage(UIImage(named:"x"), for: .highlighted)
        }
        
        requestAds()
    }

    func requestAds() {
        LTRequest.sharedInstance().didRequestInfo(["absoluteLink":"".urlGet(postFix: "api/Ads/Bottom"),
                                                   "method":"GET",
                                                   "overrideAlert":1
            ], withCache: { (cache) in
                
        }) { (response, errorCode, error, isValid, header) in
            
            if errorCode != "200" {
                return
            }
            
            self.images?.removeAllObjects()
            
            self.images?.addObjects(from: response?.dictionize()["array"] as! [Any])
            
            self.pagerView.reloadData()
            
            self.pageControl.numberOfPages = self.images!.count
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
