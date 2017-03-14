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
    public func movePage(to page: Int, animated: Bool = true) -> Int{
        
        switch self.browserType {
        case .normal :
            
            // Load image if it has not already been loaded.
            loadImageFromView(page)
            
            // Do not move offset unless page range.
            if page < 1 {
                return self.currentPage
            } else if page > self.totalPage {
                return self.currentPage
            }
            
            self.scrollView.setContentOffset(CGPoint(x: self.scrollView.frame.width * CGFloat(page - 1), y: 0), animated: animated)
            
            return page
            
        case .banner:
            self.scrollView.setContentOffset(CGPoint(x: self.scrollView.frame.width * CGFloat(page), y: 0), animated: animated)
            
            if page > self.totalPage {
                // Go to the first page from the last page.
                lastPage = 1
                return 1
            } else if page < 1 {
                return self.totalPage
            } else {
                return page
            }
        }
    }
    
    /**
     * Go to a next page
     *
     * @param animated Decide to start animating when moving the page. Default is true
     * @return Returns the number of the moved page
     */
    public func nextPage(_ animated: Bool = true)  -> Int {
        if self.browserType == .banner {
            lastPage = self.currentPage + 1
            return movePage(to: lastPage, animated: animated)
        } else {
            lastPage = self.currentPage + 1 >= totalPage ? totalPage : currentPage + 1
            return movePage(to: lastPage, animated: animated)
        }
    }
    
    /**
     * Go to previous page
     *
     * @param animated Decide to start animating when moving the page. Default is true
     * @return Returns the number of the moved page
     */
    public func prevPage(_ animated: Bool = true) -> Int {
        
        lastPage = self.currentPage - 1 <= 1 ? 1 : self.currentPage - 1
        
        return movePage(to: lastPage, animated: animated)
    }
    
    /**
     * Current page in scroll view
     *
     */
    public var currentPage: Int {
        switch self.browserType {
        case .normal:
            return self.scrollView.currentPage
        case .banner:
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
        case .normal:
            return self.scrollView.totalPage
        case .banner:
            return self.scrollView.totalPage - 2
        }
    }
}
