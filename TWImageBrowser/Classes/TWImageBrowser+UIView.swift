//
//  TWImageBrowser+UIView.swift
//  TWImageBrowser
//
//  Created by magicmon on 2016. 11. 3..
//  Copyright © 2016 magicmon. All rights reserved.
//
//

extension UIView {
    public func copyView() -> Any? {
        return NSKeyedUnarchiver.unarchiveObject(with: NSKeyedArchiver.archivedData(withRootObject: self))
    }
}

extension TWImageBrowser {
    
    func loadImageFromView(_ toPage: Int) {
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
