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