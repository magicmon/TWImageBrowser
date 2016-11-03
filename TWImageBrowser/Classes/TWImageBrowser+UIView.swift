//
//  TWImageBrowser+UIView.swift
//  TWImageBrowser
//
//  Created by Tae Woo Kang on 2016. 11. 3..
//  Copyright © 2016 magicmon. All rights reserved.
//
//

extension UIView {
    public func copyView() -> AnyObject?
    {
        return NSKeyedUnarchiver.unarchiveObjectWithData(NSKeyedArchiver.archivedDataWithRootObject(self))
    }
}

extension TWImageBrowser {
    
    func loadImageFromView(toPage: Int) {
        if toPage - 1 >= 0 && toPage <= self.imageObjects.count {
            if let imageView = self.scrollView.subviews[toPage - 1] as? TWImageView {
                if imageView.imageView.image == nil {
                    let obj = self.imageObjects[toPage - 1]
                    imageView.setupImage(obj)
                }
            }
        }
    }
}