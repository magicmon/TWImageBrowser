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
    public func setPageControlColor(currentTintColor: UIColor, pageIndicatorTintColor: UIColor) {
        self.pageControl.currentPageIndicatorTintColor = currentTintColor
        self.pageControl.pageIndicatorTintColor = pageIndicatorTintColor
    }
    
    // MARK: Data Get
    /**
     * 원하는 페이지의 이미지 객체를 얻어온다
     * @param page 페이지 번호
     * @return 해당 페이지의 UIImage 반환
     */
    public func getImage(page: Int) -> UIImage?{
        
        if self.imageObjects.count < 1 {
            return nil
        }
        
        // TODO: page번호하고 view의 index하고 맞춰야함(배너가 있을때는 다르게 동작 할 가능성이 많음)
        if page > 0 && page <= self.totalPage {
            for subview in self.scrollView.subviews {
                if subview is TWImageView {
                    let imageView = subview as! TWImageView
                    return imageView.imageView.image
                } else {
                    for image in subview.subviews {
                        if image is UIImageView {
                            let imageView = image as! UIImageView
                            return imageView.image
                        }
                    }
                }
            }
        }
        
        return nil
    }
    
    /**
     *  전체 페이지의 View 객체를 가져온다
     *
     *  @return 해당 페이지의 UIImage 반환
     */
    public func getBrowserViewList() -> [UIView] {
        return self.scrollView.subviews
    }
}
