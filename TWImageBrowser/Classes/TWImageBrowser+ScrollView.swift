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
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        self.pageControl.currentPage = self.currentPage - 1
        
        self.delegate?.imageBrowserDidScroll(self)
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        // Save last viewed page before scrolling
        lastPage = self.currentPage
        
        // Stops what was being scrolled
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector:autoScrollFunctionName , object: nil)
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        // Save list viewed page after scrolling
        lastPage = self.currentPage
        
        // stop scroll
        
        // Restart to auto scrolling
        if self.browserType == .banner && self.autoPlayTimeInterval > 0 {
            self.perform(autoScrollFunctionName, with: nil, afterDelay:self.autoPlayTimeInterval)
        }
        
        scrollViewDidEndScrollingAnimation(scrollView)
    }
    
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        switch self.browserType {
        case .normal:
            // Load image if it has not already been loaded.
            setupImage(from: self.scrollView.currentPage)
            
            // Initialize zoomScale when you go to another page.
            for index in 0...self.imageObjects.count - 1 {
                if index + 1 == self.scrollView.currentPage { continue }
                
                if let imageView = self.scrollView.subviews[index] as? TWImageView, imageView.imageView.image != nil && imageView.zoomScale > 1.0 {
                    imageView.setZoomScale(imageView.minimumZoomScale, animated: false)
                }
            }
        case .banner:
            if self.scrollView.currentPage == 1 {
                self.scrollView.setContentOffset(CGPoint(x: self.scrollView.frame.width * CGFloat(self.totalPage), y: 0), animated: false)
            }
            else if self.scrollView.currentPage == self.imageObjects.count {
                self.scrollView.setContentOffset(CGPoint(x: self.scrollView.frame.width, y: 0), animated: false)
            }
            break
        }
        
        self.delegate?.imageBrowserDidEndScrollingAnimation(self)
    }
}
