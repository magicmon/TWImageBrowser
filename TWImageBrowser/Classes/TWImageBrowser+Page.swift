//
//  TWImageBrowser+Page.swift
//  TWImageBrowser
//
//  Created by magicmon on 2016. 11. 3..
//  Copyright © 2016 magicmon. All rights reserved.
//
//


// MARK: - Page
extension TWImageBrowser {
    /**
     * Go to a specific page
     *
     * @param page page number.
     * @param animated Decide to start animating when moving the page. Default is true
     * @return Returns the number of the moved page
     */
    public func movePage(toPage: Int, animated: Bool = true) -> Int{
        
        switch self.browserType {
        case .NORMAL :
            
            // Load image if it has not already been loaded.
            loadImageFromView(toPage)
            
            // Do not move offset unless page range.
            if toPage < 1 {
                return self.currentPage
            } else if toPage > self.totalPage {
                return self.currentPage
            }
            
            self.scrollView.setContentOffset(CGPointMake(self.scrollView.frame.width * CGFloat(toPage - 1), 0), animated: animated)
            
            return toPage
            
        case .BANNER:
            self.scrollView.setContentOffset(CGPointMake(self.scrollView.frame.width * CGFloat(toPage), 0), animated: animated)
            
            if toPage > self.totalPage {
                // Go to the first page from the last page.
                return 1
            } else if toPage < 1 {
                return self.totalPage
            } else {
                return toPage
            }
        }
    }
    
    /**
     * Go to a next page
     *
     * @param animated Decide to start animating when moving the page. Default is true
     * @return Returns the number of the moved page
     */
    public func nextPage(animated: Bool = true)  -> Int {
        
        lastPage = self.currentPage
        
        return movePage(self.currentPage + 1, animated: animated)
    }
    
    /**
     * Go to previous page
     *
     * @param animated Decide to start animating when moving the page. Default is true
     * @return Returns the number of the moved page
     */
    public func prevPage(animated: Bool = true)  -> Int {
        
        lastPage = self.currentPage
        
        return movePage(self.currentPage - 1, animated: animated)
    }
    
    /**
     * Current page in scroll view
     *
     */
    public var currentPage: Int {
        switch self.browserType {
        case .NORMAL:
            return self.scrollView.currentPage
        case .BANNER:
            if self.scrollView.currentPage == 1 {
                // last page
                return self.imageObjects.count - 2
            }
            else if self.scrollView.currentPage == self.imageObjects.count {
                // first page
                return  1
            } else {
                return  self.scrollView.currentPage - 1
            }
        }
    }
    
    /**
     * Total page in scroll view
     *
     */
    public var totalPage: Int {
        switch self.browserType {
        case .NORMAL:
            return self.scrollView.totalPage
        case .BANNER:
            return self.scrollView.totalPage - 2
        }
    }
}