//
//  TWImageBrowser+Data.swift
//  TWImageBrowser
//
//  Created by magicmon on 2016. 11. 3..
//  Copyright © 2016 magicmon. All rights reserved.
//
//

import UIKit

extension TWImageBrowser {
    
    // MARK: - Data Set
    public func pageControlColor(_ currentTintColor: UIColor, pageIndicatorTintColor: UIColor) {
        self.pageControl.currentPageIndicatorTintColor = currentTintColor
        self.pageControl.pageIndicatorTintColor = pageIndicatorTintColor
    }
    
    // MARK: Data Get
    /**
     * Retrieves the image object of the requested page.
     * @param page Request page
     * @return Return the UIImage of the page
     */
    public func imageView(from page: Int) -> UIImage? {
        
        if self.imageObjects.count < 1 {
            return nil
        }
        
        // TODO: page번호하고 view의 index하고 맞춰야함(배너가 있을때는 다르게 동작 할 가능성이 많음)
        if page > 0 && page <= self.totalPage {
            for subview in imageViews {
                if let imageView = subview as? TWImageView {
                    return imageView.imageView.image
                } else {
                    for image in subview.subviews {
                        if let imageView = image as? UIImageView {
                            return imageView.image
                        }
                    }
                }
            }
        }
        
        return nil
    }
    
    /**
     *  The View object for the entire page.
     *
     *  @return Return page list.
     */
    public var imageViews: [UIView] {
        return self.scrollView.subviews
    }
}
