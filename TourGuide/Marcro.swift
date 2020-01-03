//
//  Marcro.swift
//  InformationCollector
//
//  Created by thanhhaitran on 5/10/16.
//  Copyright © 2016 thanhhaitran. All rights reserved.
//

import Foundation

import SDWebImage

import JSONKit_NoWarning

let screenWidth = UIScreen.main.bounds.size.width

let screenHeight = UIScreen.main.bounds.size.height

let IS_IPHONE_4 = screenHeight < 568.0

let IS_IPHONE_5 = screenHeight == 568.0

let IS_IPHONE_6 = screenHeight == 667.0

let IS_IPHONE_6P = screenHeight == 736.0

let IS_IPAD = UIDevice.current.userInterfaceIdiom == .pad

func IS_IPHONE_X () -> Bool {
    var iphoneX = false
    if #available(iOS 11.0, *) {
        if ((UIApplication.shared.keyWindow?.safeAreaInsets.top)! > CGFloat(0.0)) {
            iphoneX = true
        }
    }
    return iphoneX
}

func iOS_VERSION_EQUAL_TO(version: String) -> Bool {
    return UIDevice.current.systemVersion.compare(version, options: NSString.CompareOptions.numeric) == ComparisonResult.orderedSame
}

func iOS_VERSION_GREATER_THAN(version: String) -> Bool {
    return UIDevice.current.systemVersion.compare(version, options: NSString.CompareOptions.numeric) == ComparisonResult.orderedDescending
}

func iOS_VERSION_GREATER_THAN_OR_EQUAL_TO(version: String) -> Bool {
    return UIDevice.current.systemVersion.compare(version, options: NSString.CompareOptions.numeric) != ComparisonResult.orderedAscending
}

func iOS_VERSION_LESS_THAN(version: String) -> Bool {
    return UIDevice.current.systemVersion.compare(version, options: NSString.CompareOptions.numeric) == ComparisonResult.orderedAscending
}

func iOS_VERSION_LESS_THAN_OR_EQUAL_TO(version: String) -> Bool {
    return UIDevice.current.systemVersion.compare(version, options: NSString.CompareOptions.numeric) != ComparisonResult.orderedDescending
}

func root() -> UIViewController {
    let root: AppDelegate = UIApplication.shared.delegate as! AppDelegate

    return (root.window?.rootViewController)!
}

func tabbar() -> TG_Root_ViewController {
    return (root() as! UINavigationController).viewControllers.first as! TG_Root_ViewController
}

func user() -> TG_User_ViewController {
    return ((root() as! UINavigationController).viewControllers.first as! TG_Root_ViewController).viewControllers?.last as! TG_User_ViewController
}

func logged() -> Bool {
    return Information.token != nil
}

func INFO() -> NSDictionary {
    return Information.userInfo!
}

extension String {
    func replace(target: String, withString: String) -> String {
        return self.replace(target:target, withString:withString)
    }
}

extension String {
    
    func format(parameters: CVarArg...) -> String {
        return String(format: self, arguments: parameters)
    }
    
    func stringImage() -> UIImage {
        let dataDecoded:NSData = NSData(base64Encoded: self, options: NSData.Base64DecodingOptions(rawValue: 0))!
        let decodedimage:UIImage = UIImage(data: dataDecoded as Data)!
        return decodedimage
    }
    
    func urlGet(postFix: String) -> String {
        let host = root().infoPlist()["host"]
        return "%@/%@".format(parameters:host as! String, postFix)
    }
    
    func dictionize() -> NSDictionary {
        return (self as NSString).objectFromJSONString() as! NSDictionary
    }
}

extension UIImage {
    func imageString() -> String {
        return (UIImageJPEGRepresentation(self,0.1)?.base64EncodedString(options: .endLineWithLineFeed))!
    }
    
    func fullImageString() -> String {
        return (UIImageJPEGRepresentation(self,0.7)?.base64EncodedString(options: .endLineWithLineFeed))!
    }
}

extension UIImageView {
    func imageUrl (url: String) {
        self.sd_setImage(with: NSURL.init(string: (url as NSString).encodeUrl())! as URL, placeholderImage: UIImage.init(named: "demo_bg")) { (image, error, cacheType, url) in
            if error != nil {
                return
            }
            
            if ((image != nil) && cacheType == .none)
            {
                UIView.transition(with: self, duration: 0.3, options: .transitionCrossDissolve, animations: {
                    self.image = image
                }, completion: nil)
            }
        }
    }
}

extension Date {
    func dateComp(type: Int) -> String {
        let calendar = Calendar.current
        let time = calendar.dateComponents([.month, .weekday, .day], from: self)
        return "%i".format(parameters: (type == 0 ? time.day : type == 1 ? time.weekday : time.month)!)
    }
}

extension UIView {
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
}

extension UITapGestureRecognizer {
    
    func didTapAttributedTextInLabel(label: UILabel, inRange targetRange: NSRange) -> Bool {
        // Create instances of NSLayoutManager, NSTextContainer and NSTextStorage
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: CGSize.zero)
        let textStorage = NSTextStorage(attributedString: label.attributedText!)
        
        // Configure layoutManager and textStorage
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        
        // Configure textContainer
        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = label.lineBreakMode
        textContainer.maximumNumberOfLines = label.numberOfLines
        let labelSize = label.bounds.size
        textContainer.size = labelSize
        
        // Find the tapped character location and compare it to the specified range
        let locationOfTouchInLabel = self.location(in: label)
        let textBoundingBox = layoutManager.usedRect(for: textContainer)
        let textContainerOffset = CGPoint.init(x:(labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x,
                                               y:(labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y);
        let locationOfTouchInTextContainer = CGPoint.init(x:locationOfTouchInLabel.x - textContainerOffset.x,
                                                          y:locationOfTouchInLabel.y - textContainerOffset.y);
        let indexOfCharacter = layoutManager.characterIndex(for: locationOfTouchInTextContainer, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        
        return NSLocationInRange(indexOfCharacter, targetRange)
    }
    
}

extension String {
    func index(from: Int) -> Index {
        return self.index(startIndex, offsetBy: from)
    }
    
    func substring(from: Int) -> String {
        let fromIndex = index(from: from)
        return substring(from: fromIndex)
    }
    
    func substring(to: Int) -> String {
        let toIndex = index(from: to)
        return substring(to: toIndex)
    }
    
    func substring(with r: Range<Int>) -> String {
        let startIndex = index(from: r.lowerBound)
        let endIndex = index(from: r.upperBound)
        return substring(with: startIndex..<endIndex)
    }
}
