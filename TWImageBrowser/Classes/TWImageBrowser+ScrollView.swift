//
//  TWImageBrowser+ScrollView.swift
//  TWImageBrowser
//
//  Created by Tae Woo Kang on 2016. 11. 3..
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
        
        // pageControl의 위치 이동
        self.pageControl.currentPage = self.currentPage - 1
        
        // 스크롤 발생
        self.delegate?.imageBrowserDidScroll(self)
    }
    
    public func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        // 스크롤 시작 전 마지막으로 보고 있던 페이지 저장
        lastPage = self.currentPage
        
        // 자동 스크롤 중이던 항목을 멈춤
        NSObject.cancelPreviousPerformRequestsWithTarget(self, selector:autoScrollFunctionName , object: nil)
    }
    
    public func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        // 사용자에 의한 스크롤 종료
    }
    
    public func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
    }
    
    public func scrollViewWillBeginDecelerating(scrollView: UIScrollView) {
        // 스크롤 멈추기 시작
    }
    
    public func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        
        // stop scroll
        
        // 자동 스크롤 재 실행
        if self.browserType == .BANNER && self.autoPlayTimeInterval > 0 {
            self.performSelector(autoScrollFunctionName, withObject: nil, afterDelay:self.autoPlayTimeInterval)
        }
        
        scrollViewDidEndScrollingAnimation(scrollView)
    }
    
    public func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        switch self.browserType {
        case .NORMAL:
            break
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