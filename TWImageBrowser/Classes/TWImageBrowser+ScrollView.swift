//
//  TWImageBrowser+ScrollView.swift
//  TWImageBrowser
//
//  Created by magicmon on 2016. 11. 3..
//  Copyright © 2016 magicmon. All rights reserved.
//
//

extension UIScrollView {
    var currentPage: Int {
        return Int((self.contentOffset.x + (0.5 * self.frame.size.width)) / self.frame.width) + 1
    }
    
    var totalPage: Int {
        return Int(self.contentSize.width / self.frame.width)
    }
}

extension TWImageBrowser: UIScrollViewDelegate {
    public func scrollViewDidScroll(scrollView: UIScrollView) {
        
        self.pageControl.currentPage = self.currentPage - 1
        
        self.delegate?.imageBrowserDidScroll(self)
    }
    
    public func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        // Save last viewed page before scrolling
        lastPage = self.currentPage
        
        // Stops what was being scrolled
        NSObject.cancelPreviousPerformRequestsWithTarget(self, selector:autoScrollFunctionName , object: nil)
    }
    
    public func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        // Save last viewed page after scrolling
        lastPage = self.currentPage
        
        // stop scroll
        
        // Restart to auto scrolling
        if self.browserType == .BANNER && self.autoPlayTimeInterval > 0 {
            self.performSelector(autoScrollFunctionName, withObject: nil, afterDelay:self.autoPlayTimeInterval)
        }
        
        scrollViewDidEndScrollingAnimation(scrollView)
    }
    
    public func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        
        
        switch self.browserType {
        case .NORMAL:
            // Load image if it has not already been loaded.
            loadImageFromView(self.scrollView.currentPage)
            
            // Initialize zoomScale when you go to another page.
            for index in 0...self.imageObjects.count - 1 {
                if index + 1 == self.scrollView.currentPage { continue }
                
                if let imageView = self.scrollView.subviews[index] as? TWImageView where imageView.imageView.image != nil && imageView.zoomScale > 1.0 {
                    imageView.setZoomScale(imageView.minimumZoomScale, animated: false)
                }
            }
        case .BANNER:
            if self.scrollView.currentPage == 1 {
                self.scrollView.setContentOffset(CGPointMake(self.scrollView.frame.width * CGFloat(self.totalPage), 0), animated: false)
            }
            else if self.scrollView.currentPage == self.imageObjects.count {
                self.scrollView.setContentOffset(CGPointMake(self.scrollView.frame.width, 0), animated: false)
            }
            break
        }
        
        self.delegate?.imageBrowserDidEndScrollingAnimation(self)
    }
}