//
//  TWImageCache.swift
//  TWImageCache
//
//  Created by magicmon on 2016. 11. 3..
//  Copyright © 2016 magicmon. All rights reserved.
//
//
import AlamofireImage

internal class TWImageCache {
    
    fileprivate static var sInstance: TWImageCache? = nil
    static func sharedInstance() -> TWImageCache! {
        if sInstance == nil {
            sInstance = TWImageCache()
        }
        return sInstance
    }
    
    init() {
        
    }
    
    fileprivate let kCommonDummyIdentifier = "kCommonDummyIdentifier"
    fileprivate let kCommonDummyCircleIdentifier = "kCommonDummyCircleIdentifier"
    
    let downloader = UIImageView.af_sharedImageDownloader
    internal var imageCache = AutoPurgingImageCache(memoryCapacity: 50_000_000, preferredMemoryUsageAfterPurge: 30_000_000)
    var globalImageCache: AutoPurgingImageCache {
        return imageCache
    }
    
    func cacheImageWithURL(_ imageURLString: String?, completion: ((UIImage?) -> Void)? = nil) {
        
        guard let imageURLString = imageURLString else {
            return
        }
        
        guard let imageURL = URL(string: imageURLString) else {
            return
        }
        
        let request = URLRequest(url: imageURL)
        
        
        if let image = imageCache.image(withIdentifier: imageURLString) {
            completion?(image)
        } else {
            downloader.download(request) { response in
                if let image = response.result.value {
                    self.imageCache.add(image, withIdentifier: imageURLString)
                    completion?(image)
                } else {
                    completion?(nil)
                }
            }
        }
    }
}



