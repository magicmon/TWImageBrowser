//
//  TWImageCache.swift
//  TWImageCache
//
//  Created by Tae Woo Kang on 2016. 11. 3..
//  Copyright © 2016 magicmon. All rights reserved.
//
//
import AlamofireImage

internal class TWImageCache {
    
    private static var sInstance: TWImageCache? = nil
    static func sharedInstance() -> TWImageCache! {
        if sInstance == nil {
            sInstance = TWImageCache()
        }
        return sInstance
    }
    
    init() {
        
    }
    
    private let kCommonDummyIdentifier = "kCommonDummyIdentifier"
    private let kCommonDummyCircleIdentifier = "kCommonDummyCircleIdentifier"
    
    let downloader = UIImageView.af_sharedImageDownloader
    internal var imageCache = AutoPurgingImageCache(memoryCapacity: 50_000_000, preferredMemoryUsageAfterPurge: 30_000_000)
    var globalImageCache: AutoPurgingImageCache {
        return imageCache
    }
    
    func cacheImageWithURL(imageURLString: String?, completion: ((UIImage?) -> Void)? = nil) {
        
        guard let imageURLString = imageURLString else {
            return
        }
        
        guard let imageURL = NSURL(string: imageURLString) else {
            return
        }
        
        let request = NSURLRequest(URL: imageURL)
        
        if let image = imageCache.imageWithIdentifier(imageURLString) {
            completion?(image)
        } else {
            downloader.downloadImage(URLRequest: request, filter: nil) { response in
                if let image = response.result.value {
                    self.imageCache.addImage(image, withIdentifier: imageURLString)
                    completion?(image)
                } else {
                    completion?(nil)
                }
            }
        }
    }
}



