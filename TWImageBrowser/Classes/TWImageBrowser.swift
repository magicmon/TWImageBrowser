//
//  TWImageBrowser.swift
//  TWImageBrowser
//
//  Created by Tae Woo Kang on 2016. 5. 26..
//  Copyright © 2016 magicmon. All rights reserved.
//

import UIKit

public protocol TWImageBrowserDataSource {
    func backgroundImage(imageBrowser: TWImageBrowser) -> UIImage?
    func loadObjects(imageBrowser: TWImageBrowser) -> [AnyObject]?
}

public protocol TWImageBrowserDelegate {
    func imageBrowserDidScroll(imageBrowser: TWImageBrowser)
    func imageBrowserDidEndScrollingAnimation(imageBrowser: TWImageBrowser)
}

public enum TWImageBrowserType: Int {
    case NORMAL
    case BANNER
}

public class TWImageBrowser: UIView, UIScrollViewDelegate {
    
    private var autoScrollFunctionName: Selector = #selector(TWImageBrowser.autoScrollingView) // 자동 스크롤 시 불러올 함수이름 설정
    
    private var scrollView: UIScrollView!
    private var pageControl: UIPageControl!
    
    private var lastPage: Int = 1                           // 마지막으로 접근한 페이지 지정
    private var isOrientation: Bool = false                 // 화면 회전중인지 체크
    
    public var dataSource: TWImageBrowserDataSource?        // 브라우저 실행 시 data source 설정
    public var delegate: TWImageBrowserDelegate?            // 페이지 이동 등에 대한 delegate
    
    public var imageObjects: [AnyObject] = []               // 이미지를 보관해두는 배열
    public var browserType: TWImageBrowserType = .NORMAL    // 해당 브라우저 타입
    public var autoPlayTimeInterval: NSTimeInterval = 3.0   // 자동 스크롤링 시간 설정(0.0 이상으로 셋팅할 경우 자동으로 실행)
    
    public var hiddenPageControl: Bool = false              // 하단에 pageControl이 나올지 말지 여부 설정
    
    private var viewPadding: CGFloat = 0.0                  // 각 이미지뷰 사이의 간격
    public var viewInset: CGFloat {
        get{
            return self.viewPadding
        }
        
        set(imageInset) {
            self.viewPadding = (imageInset < 0.0) ? 0.0 : imageInset
        }
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        initializeScrollView()
        initializePageControl()
        initializeNotification()
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        
        initializeScrollView()
        initializePageControl()
        initializeNotification()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        // 배너이고 auto play가 있으면 자동 넘김 실행
        if self.browserType == .BANNER && self.autoPlayTimeInterval > 0 {
            NSObject.cancelPreviousPerformRequestsWithTarget(self, selector:autoScrollFunctionName , object: nil)
            self.performSelector(autoScrollFunctionName, withObject: nil, afterDelay:self.autoPlayTimeInterval)
        }
        
        // 데이터가 없을 때만 브라우저를 로드 한다.
        if self.imageObjects.count == 0 {
            loadBrowser()
        }
        
        self.pageControl.frame = CGRectMake(0, self.bounds.size.height - 20.0, self.bounds.size.width, 20.0)
    }
    
    // MARK: - Initial
    func initializeScrollView() {
        // scroll View
        self.scrollView = UIScrollView(frame:CGRectMake(-self.viewPadding, 0, self.bounds.width + (2 * self.viewPadding), self.bounds.height))
        self.scrollView.pagingEnabled = true
        self.scrollView.showsHorizontalScrollIndicator = false
        self.scrollView.showsVerticalScrollIndicator = false
        self.scrollView.minimumZoomScale = 1.0
        self.scrollView.maximumZoomScale = 1.0
        self.scrollView.zoomScale = 1.0
        self.scrollView.tag = 0
        self.scrollView.delegate = self
        self.scrollView.backgroundColor = UIColor.clearColor()
        self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.width, self.scrollView.frame.height)
        self.scrollView.contentOffset = CGPointZero
        self.scrollView.scrollsToTop = false
        self.scrollView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        
        self.addSubview(self.scrollView)
    }
    
    func initializePageControl() {
        // page control
        self.pageControl = UIPageControl(frame: CGRectMake(0, self.bounds.size.height - 20.0, self.bounds.size.width, 20.0))
        self.pageControl.userInteractionEnabled = false
        self.addSubview(self.pageControl)
    }
    
    /**
     * 이미지뷰를 화면에 보여준다
     */
    func loadBrowser() {
        
        if var objectList = self.dataSource?.loadObjects(self) {
            
            if objectList.count == 0 {
                // TODO: 빈 이미지를 보여주도록 수정
                return
            }
            
            var offsetWidth: CGFloat = 0.0
            
            switch self.browserType {
            case .NORMAL:
                self.imageObjects = objectList
                self.pageControl.hidden = true
                break
            case .BANNER:
                
                // make image list
                // 형태는 다음과 같다
                // 이미지1, 이미지2, 이미지3 이라면 ->>> 이미지3 | 이미지1 | 이미지2 | 이미지3 | 이미지1
                // 과 같은 형태로 이미지가 구성된다
                
                // 마지막 이미지를 제일 첫번째에 위치하도록 한다
                if let lastObject = objectList.last {
                    if objectList.last is UIView {
                        let lastView = lastObject as! UIView
                        objectList.insert(lastView.copyView(), atIndex: 0)
                    } else {
                        objectList.insert(lastObject, atIndex: 0)
                    }
                }
                
                // 첫번째 이미지를 제일 뒤에 위치하도록 한다.
                if objectList[1] is UIView {
                    let firstView = objectList[1] as! UIView
                    objectList.append(firstView.copyView())
                } else {
                    objectList.append(objectList[1])
                }
                
                self.imageObjects = objectList
                
                // offset 지정(두번째 페이지가 1번이 된다)
                offsetWidth = CGFloat(self.bounds.width + (2 * self.viewPadding))
                
                // bounces 처리 제거(페이지 이동 시 튀는 현상)
                self.scrollView.bounces = false
                
                // page control 화면에 보이게 설정
                if hiddenPageControl == true {
                    self.pageControl.hidden = true
                } else {
                    self.pageControl.hidden = objectList.count > 3 ? false : true
                }
                break
            }
            
            self.scrollView.frame = CGRectMake(-self.viewPadding, 0, self.bounds.width + (2 * self.viewPadding), self.bounds.height)
            self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.width * CGFloat(self.imageObjects.count), self.scrollView.frame.height)
            self.scrollView.setContentOffset(CGPointMake(offsetWidth, 0), animated: false)
            
            // set image View
            for (index, object) in self.imageObjects.enumerate() {
                
                if object is UIView {
                    let view = object as! UIView
                    view.frame = frameForView(index)
                    view.layoutSubviews()
                    view.tag = self.browserType == .NORMAL ? index + 1 : index
                    
                    self.scrollView.addSubview(object as! UIView)
                }
                else {
                    let imageView: TWImageView = TWImageView(frame: frameForView(index), image: object)
                    imageView.browserType = self.browserType
                    imageView.refreshLayout()
                    
                    switch self.browserType {
                    case .NORMAL:
                        imageView.tag = index + 1
                        imageView.maximumZoomScale = imageView.getMaxZoomScale()
                        imageView.imageView.contentMode = .ScaleAspectFit
                        break
                    case .BANNER:
                        imageView.tag = index
                        imageView.maximumZoomScale = 1.0
                        imageView.minimumZoomScale = 1.0
                        imageView.imageView.contentMode = .ScaleToFill
                        break
                    }
                    
                    self.scrollView.addSubview(imageView)
                }
            }
            
            // 화면에 보여줄 페이지 번호 설정
            self.pageControl.numberOfPages = self.totalPage
            self.pageControl.currentPage = 0
        } else {
            // 이미지를 하나도 받지 못하면 대표 백그라운드 이미지 하나만 보여준다
            
            self.scrollView.frame = CGRectMake(0, 0, self.bounds.width, self.bounds.height)
            self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.width, self.scrollView.frame.height)
            
            // 외부로부터 백그라운드에 쓰일 이미지를 얻어온다
            guard let backgroundImage = self.dataSource?.backgroundImage(self) else {
                return
            }
            
            self.imageObjects = [backgroundImage]
            
            let imageView: TWImageView = TWImageView(frame: frameForView(0), image: backgroundImage)
            imageView.tag = 1
            imageView.refreshLayout()
            
            self.scrollView.addSubview(imageView)
            
            // page control도 화면에 안나오게 설정
            self.pageControl.hidden = true
        }
    }
    
    // MARK: - Orientation
    func initializeNotification() {
        NSNotificationCenter.defaultCenter().addObserver(
            self, selector: #selector(TWImageBrowser.orientationDidChange),
            name: UIDeviceOrientationDidChangeNotification,
            object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(TWImageBrowser.statusBarOrientationWillChange),
            name: UIApplicationWillChangeStatusBarOrientationNotification,
            object: nil
        )
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIDeviceOrientationDidChangeNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIApplicationWillChangeStatusBarOrientationNotification, object: nil)
    }
    
    func statusBarOrientationWillChange()
    {
        lastPage = self.currentPage
        self.isOrientation = true
    }
    
    func orientationDidChange()
    {
        if self.isOrientation  {
            self.isOrientation = false
            
            self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.width * CGFloat(self.imageObjects.count), self.scrollView.frame.height)
            
            for (index, subview) in self.scrollView.subviews.enumerate() {
                
                subview.frame = frameForView(index)
                
                if let imageView = subview as? TWImageView {
                    imageView.refreshLayout()
                }
            }
            
            // 화면 변경이 완료되면 원래의 페이지로 이동
            movePage(lastPage, animated: false)
        }
    }
    
    // MARK: Frame
    func frameForView(index: Int) -> CGRect{
        var viewFrame : CGRect = self.scrollView.bounds
        viewFrame.origin.x = viewFrame.size.width * CGFloat(index)
        viewFrame.origin.y = 0.0
        viewFrame = CGRectInset(viewFrame, self.viewPadding, 0.0)
        
        return viewFrame
    }
    
    // MARK: - Page
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
    
    func autoScrollingView() {
        NSObject.cancelPreviousPerformRequestsWithTarget(self, selector: autoScrollFunctionName , object: nil)
        
        nextPage()
        
        self.performSelector(autoScrollFunctionName, withObject: nil, afterDelay: self.autoPlayTimeInterval)
    }
    
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
    
    // MARK: - UIScrollView Delegate
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

extension UIScrollView {
    var currentPage:Int{
        return Int((self.contentOffset.x + (0.5 * self.frame.size.width)) / self.frame.width) + 1
    }
    
    var totalPage:Int {
        return Int(self.contentSize.width / self.frame.width)
    }
}

extension UIView {
    public func copyView() -> AnyObject
    {
        return NSKeyedUnarchiver.unarchiveObjectWithData(NSKeyedArchiver.archivedDataWithRootObject(self))!
    }
}