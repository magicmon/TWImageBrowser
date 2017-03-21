//
//  TWImageBrowser+UIImage.swift
//  Pods
//
//  Created by magicmon on 2017. 3. 14..
//
//

import UIKit
import ImageIO

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

private var imageRawDataKey: Void?

extension UIImage {
    // MARK: RAW DATA
    public var rawData: Data? {
        get {
            return objc_getAssociatedObject(self, &imageRawDataKey) as? Data
        }
        set(newValue) {
            objc_setAssociatedObject(self, &imageRawDataKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    public convenience init?(rawData: Data) {
        self.init(rawData:rawData)
        self.rawData = rawData
    }
    
    override open class func initialize() {
        
        let justAOneTimeThing: () = {
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
        }()
        
        justAOneTimeThing
    }
    
    func sizeThatFits(_ size: CGSize) -> CGSize {
        var imageSize = CGSize(width: self.size.width / self.scale, height: self.size.height / self.scale)
        
        let widthRatio = imageSize.width / size.width
        let heightRatio = imageSize.height / size.height
        
        if widthRatio > heightRatio {
            imageSize = CGSize(width: imageSize.width / widthRatio, height: imageSize.height / widthRatio)
        } else {
            imageSize = CGSize(width: imageSize.width / heightRatio, height: imageSize.height / heightRatio)
        }
        
        return imageSize
    }
}
