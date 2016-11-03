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
     * 특정 페이지로 이동
     *
     * @param page 페이지 번호
     * @param animated 페이지 이동 시 에니메이션 효과를 줄지 결정. default는 true
     * @return 이동한 페이지의 번호를 반환
     */
    public func movePage(toPage: Int, animated: Bool = true) -> Int{
        
        switch self.browserType {
        case .NORMAL :
            
            // 이미지가 아직 로드 안된 경우 로드
            loadImageFromView(toPage)
            
            // 페이지 범위를 넘어가면 offset을 이동시키지 않음
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
                // 마지막 페이지에서 첫페이지로 넘어가는 경우
                return 1
            } else if toPage < 1 {
                return self.totalPage
            } else {
                return toPage
            }
        }
    }
    
    /**
     * 다음 페이지로 이동
     *
     * @param animated 페이지 이동 시 에니메이션 효과를 줄지 결정. default는 true
     * @return 이동한 페이지의 번호를 반환
     */
    public func nextPage(animated: Bool = true)  -> Int{
        return movePage(self.currentPage + 1, animated: animated)
    }
    
    /**
     * 이전 페이지로 이동
     *
     * @param animated 페이지 이동 시 에니메이션 효과를 줄지 결정. default는 true
     * @return 이동한 페이지의 번호를 반환
     */
    public func prevPage(animated: Bool = true)  -> Int{
        return movePage(self.currentPage - 1, animated: animated)
    }
    
    /**
     * 스크롤뷰의 현재 페이지
     *
     * @return 현재 바라보고 있는 페이지 위치(1페이지부터 시작)
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
     * 스크롤뷰의 전체 페이지
     * @return 전체 페이지 개수 반환
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