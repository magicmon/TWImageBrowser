//
//  TWImageBrowser+UIImage.swift
//  TWImageBrowser
//
//  Created by magicmon on 2016. 12. 6..
//

import UIKit

private var imageRawDataKey: Void?

extension UIImage {
    // MARK: RAW DATA
    var rawData: NSData? {
        get {
            return objc_getAssociatedObject(self, &imageRawDataKey) as? NSData
        }
        set(newValue) {
            objc_setAssociatedObject(self, &imageRawDataKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    public convenience init?(rawData: NSData) {
        self.init(rawData:rawData)
        self.rawData = rawData
    }
    
    override public class func initialize() {
        var onceToken : dispatch_once_t = 0
        dispatch_once(&onceToken) {
            let originalSelector = #selector(UIImage.init(data:))
            let swizzledSelector = #selector(UIImage.init(rawData:))
            
            let originalMethod = class_getInstanceMethod(self, originalSelector)
            let swizzledMethod = class_getInstanceMethod(self, swizzledSelector)
            
            let didAddMethod = class_addMethod(self, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))
            if didAddMethod {
                class_replaceMethod(self, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod))
            } else {
                method_exchangeImplementations(originalMethod, swizzledMethod)
            }
        }
    }
    
    func sizeThatFits(size:CGSize) -> CGSize {
        var imageSize = CGSizeMake(self.size.width / self.scale, self.size.height / self.scale)
        
        let widthRatio = imageSize.width / size.width
        let heightRatio = imageSize.height / size.height
        
        if widthRatio > heightRatio {
            imageSize = CGSizeMake(imageSize.width / widthRatio, imageSize.height / widthRatio)
        } else {
            imageSize = CGSizeMake(imageSize.width / heightRatio, imageSize.height / heightRatio)
        }
        
        return imageSize
    }
}