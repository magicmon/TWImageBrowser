//
//  TWImageBrowser+GIF.swift
//  TWImageBrowser
//
//  Created by magicmon on 2016. 12. 6..
//
//  https://github.com/kiritmodi2702/GIF-Swift/blob/master/GIF-Swift/iOSDevCenters%2BGIF.swift

import UIKit
import ImageIO


private var imageRawDataKey: Void?

extension UIImage {
    // MARK: RAW DATA
    public var rawData: NSData? {
        get {
            return objc_getAssociatedObject(self, &imageRawDataKey) as? NSData
        }
        set(newValue) {
            objc_setAssociatedObject(self, &imageRawDataKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    public convenience init?(rawData: NSData){
        self.init(rawData:rawData)
        self.rawData = rawData
    }
    
    override public class func initialize() {
        var onceToken : dispatch_once_t = 0;
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
    
    // MARK: GIF
    public class func gifImageWithData(data: NSData) -> UIImage? {
        guard let source = CGImageSourceCreateWithData(data, nil) else {
            return nil
        }
        
        return UIImage.animatedImageWithSource(source)
    }
    
    public class func gifImageWithURL(gifUrl:String) -> UIImage? {
        guard let bundleURL:NSURL? = NSURL(string: gifUrl) else {
            return nil
        }
        
        guard let imageData = NSData(contentsOfURL: bundleURL!) else {
            return nil
        }
        
        return gifImageWithData(imageData)
    }
    
    public class func gifImageWithName(name: String) -> UIImage? {
        guard let bundleURL = NSBundle.mainBundle().URLForResource(name, withExtension: "gif") else {
                return nil
        }
        
        guard let imageData = NSData(contentsOfURL: bundleURL) else {
            return nil
        }
        
        return gifImageWithData(imageData)
    }
    
    class func delayForImageAtIndex(index: Int, source: CGImageSource!) -> Double {
        var delay = 0.01
        
        let cfProperties = CGImageSourceCopyPropertiesAtIndex(source, index, nil)
        let gifProperties: CFDictionaryRef = unsafeBitCast(CFDictionaryGetValue(cfProperties, unsafeAddressOf(kCGImagePropertyGIFDictionary)), CFDictionary.self)
        var delayObject: AnyObject = unsafeBitCast(CFDictionaryGetValue(gifProperties, unsafeAddressOf(kCGImagePropertyGIFUnclampedDelayTime)), AnyObject.self)
        
        if delayObject.doubleValue == 0 {
            delayObject = unsafeBitCast(CFDictionaryGetValue(gifProperties, unsafeAddressOf(kCGImagePropertyGIFDelayTime)), AnyObject.self)
        }
        
        if let delayObject = delayObject as? Double {
            delay = delayObject
        }
        
        if delay < 0.01 {
            delay = 0.01
        }
        
        return delay
    }
    
    class func gcdForPair(a: Int?, _ b: Int?) -> Int {
        var a = a
        var b = b
        
        if b == nil || a == nil {
            if b != nil {
                return b!
            } else if a != nil {
                return a!
            } else {
                return 0
            }
        }
        
        if a < b {
            let c = a
            a = b
            b = c
        }
        
        var rest: Int
        while true {
            rest = a! % b!
            
            if rest == 0 {
                return b!
            } else {
                a = b
                b = rest
            }
        }
    }
    
    class func gcdForArray(array: Array<Int>) -> Int {
        if array.isEmpty {
            return 1
        }
        
        var gcd = array[0]
        
        for val in array {
            gcd = UIImage.gcdForPair(val, gcd)
        }
        
        return gcd
    }
    
    class func animatedImageWithSource(source: CGImageSource) -> UIImage? {
        let count = CGImageSourceGetCount(source)
        var images = [CGImageRef]()
        var delays = [Int]()
        
        for i in 0..<count {
            if let image = CGImageSourceCreateImageAtIndex(source, i, nil) {
                images.append(image)
            }
            
            let delaySeconds = UIImage.delayForImageAtIndex(Int(i),source: source)
            delays.append(Int(delaySeconds * 1000.0)) // Seconds to ms
        }
        
        let duration: Int = {
            var sum = 0
            
            for val: Int in delays {
                sum += val
            }
            
            return sum
        }()
        
        let gcd = gcdForArray(delays)
        var frames = [UIImage]()
        
        var frame: UIImage
        var frameCount: Int
        for i in 0..<count {
            frame = UIImage(CGImage: images[Int(i)])
            frameCount = Int(delays[Int(i)] / gcd)
            
            for _ in 0..<frameCount {
                frames.append(frame)
            }
        }
        
        let animation = UIImage.animatedImageWithImages(frames, duration: Double(duration) / 1000.0)
        
        return animation
    }
}