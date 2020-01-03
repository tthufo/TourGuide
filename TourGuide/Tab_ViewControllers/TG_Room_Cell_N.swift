//
//  TG_Room_Cell_N.swift
//  TourGuide
//
//  Created by Mac on 7/13/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

class TG_Room_Cell_N: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout  {

    @IBOutlet var collectionView: UICollectionView!

    var images: NSMutableArray? = []
    
    @IBOutlet var pageControl: UIPageControl!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        collectionView.withCell("TG_Image_Cell")
        
        requestAds()
    }
    
    func requestAds() {
        LTRequest.sharedInstance().didRequestInfo(["absoluteLink":"".urlGet(postFix: "api/Ads/Top"),
                                                   "method":"GET",
                                                   "overrideAlert":1
            ], withCache: { (cache) in
                
        }) { (response, errorCode, error, isValid) in
            
            if errorCode != "200" {
                return
            }
            
            self.images?.removeAllObjects()
            
            self.images?.addObjects(from: response?.dictionize()["array"] as! [Any])
            
            self.collectionView.reloadData()
            
            self.pageControl.numberOfPages = self.images!.count
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
        
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.images!.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: Int(screenWidth()/2 - 30), height: Int(screenWidth()/2 - 30))
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TG_Image_Cell", for: indexPath as IndexPath)
        
        let image = (self.withView(cell, tag: 11) as! UIImageView)
        
        image.withBorder(["Bcorner":3, "Bwidth":0.5, "Bhex":"#147EFB"])
        
        let link = (images![indexPath.item] as! NSDictionary).getValueFromKey("image")
        
        image.imageUrl(url: link as! String)
        
//        (self.withView(cell, tag: 11) as! UIImageView).setupImageViewerWithDatasource(self, andInfo: ["done":["rect":NSStringFromCGRect(CGRectMake(screenWidth - 55, 20, 40, 40)),"img":"icon_close","round":["Bcorner":20,"Bwidth":2,"Bhex":"#30485F"]], "check":NSStringFromCGRect(CGRectMake(10, screenHeight - 55, 50, 50)), "image":[/*"delete":"close", */"in":"ic_unchecked", "ac":"ic_checked", "round":["Bcorner":0,"Bwidth":0,"Bhex":"#147EFB"]],
//                                                                                                      "indicator":["height":64/*,"bottom":1,"pager":1*/,"arrow":1,"right":"backF","left":"back"]
//            ], initialIndex: indexPath.row, onOpen:{
//
//        }) {
//
//            self.setSelected(true, animated: true)
//
//            let table: UITableView = self.superview?.superview as! UITableView
//
//            let control = (table.superview?.parentViewController as! EP_DetailView_Controller)
//
//            control.checkState()
//
//            control.performSelector(#selector(control.reloadDataAt(_:)), withObject: String(self.inDexOf(self.contentView, andTable: table)), afterDelay: 0.8)
//        }
        
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let url = (images![indexPath.item] as! NSDictionary).getValueFromKey("url")
        
        (self.parentViewController() as! TG_Room_ViewController).didGotoWebDetail(url: url!)

    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
