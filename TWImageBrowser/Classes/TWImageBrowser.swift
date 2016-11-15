//
//  TWImageBrowser.swift
//  TWImageBrowser
//
//  Created by magicmon on 2016. 5. 26..
//  Copyright © 2016 magicmon. All rights reserved.
//

import UIKit
import AlamofireImage

public protocol TWImageBrowserDataSource: class {
    func backgroundImage(imageBrowser: TWImageBrowser) -> UIImage?      // 로드 시 사용할 백그라운드 이미지
    func loadObjects(imageBrowser: TWImageBrowser) -> [AnyObject]?      // 로드 할 이미지
    func showDefaultPageIndex(imageBrowser: TWImageBrowser) -> Int      // 제일 처음에 보여줄 이미지의 페이지 번호
}

public protocol TWImageBrowserDelegate: class {
    func imageBrowserDidScroll(imageBrowser: TWImageBrowser)
    func imageBrowserDidEndScrollingAnimation(imageBrowser: TWImageBrowser)
    func imageBrowserDidSingleTap(imageBrowser: TWImageBrowser, page: Int)
    func imageBrowserDidDoubleTap(imageBrowser: TWImageBrowser, page: Int)
}

public enum TWImageBrowserType: Int {
    case NORMAL
    case BANNER
}



public class TWImageBrowser: UIView {
    
    internal var autoScrollFunctionName: Selector = #selector(TWImageBrowser.autoScrollingView) // 자동 스크롤 시 불러올 함수이름 설정
    
    internal var scrollView: UIScrollView!
    internal var pageControl: UIPageControl!
    
    internal var lastPage: Int = 1                          // 마지막으로 접근한 페이지 지정
    internal var isOrientation: Bool = false                // 화면 회전중인지 체크
    
    public weak var dataSource: TWImageBrowserDataSource?   // 브라우저 실행 시 data source 설정
    public weak var delegate: TWImageBrowserDelegate?       // 페이지 이동 등에 대한 delegate
    
    public var imageObjects: [AnyObject] = []               // 이미지를 보관해두는 배열
    public var browserType: TWImageBrowserType = .NORMAL    // 해당 브라우저 타입
    public var autoPlayTimeInterval: NSTimeInterval = 3.0   // 자동 스크롤링 시간 설정(0.0 이상으로 셋팅할 경우 자동으로 실행)
    
    public var hiddenPageControl: Bool = false              // 하단에 pageControl이 나올지 말지 여부 설정
    
    public var maximumScale: CGFloat = 3.0 {                // 최대 zoom scale
        didSet {
            if maximumScale < 1.0 {
                maximumScale = 1
            }
        }
    }
    
    public var viewPadding: CGFloat = 0.0 {                 // 각 이미지뷰 사이의 간격
        didSet {
            if viewPadding < 0.0 {
                viewPadding = 0
            }
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
            
            // 제일 처음 보여줄 화면 번호
            var defaultPageIndex = 0
            if let mainPageIndex = self.dataSource?.showDefaultPageIndex(self) {
                if mainPageIndex < 0 {
                    defaultPageIndex = 0
                } else if mainPageIndex >= objectList.count {
                    defaultPageIndex = objectList.count - 1
                } else {
                    defaultPageIndex = mainPageIndex
                }
            }
            
            var offset: CGPoint = CGPointZero
            
            switch self.browserType {
            case .NORMAL:
                self.imageObjects = objectList
                self.pageControl.hidden = true
                
                offset = CGPointMake((self.scrollView.frame.width * CGFloat(defaultPageIndex)) + ((2 * self.viewPadding) * CGFloat(defaultPageIndex)), 0)
            case .BANNER:
                // make image list
                // 형태는 다음과 같다
                // 이미지1, 이미지2, 이미지3 이라면 ->>> 이미지3 | 이미지1 | 이미지2 | 이미지3 | 이미지1
                // 과 같은 형태로 이미지가 구성된다
                
                // 마지막 이미지를 제일 첫번째에 위치하도록 한다
                if let lastObject = objectList.last {
                    if objectList.last is UIView {
                        if let lastView = lastObject as? UIView, let copyView = lastView.copyView() {
                            objectList.insert(copyView, atIndex: 0)
                        }
                    } else {
                        objectList.insert(lastObject, atIndex: 0)
                    }
                }
                
                // 첫번째 이미지를 제일 뒤에 위치하도록 한다.
                if objectList[1] is UIView {
                    if let firstView = objectList[1] as? UIView, let copyView = firstView.copyView() {
                        objectList.append(copyView)
                    }
                } else {
                    objectList.append(objectList[1])
                }
                
                self.imageObjects = objectList
                
                // offset 지정(두번째 페이지가 1번이 된다)
                offset = CGPointMake((self.scrollView.frame.width * CGFloat(defaultPageIndex + 1)) + ((2 * self.viewPadding) * CGFloat(defaultPageIndex + 1)), 0)
                
                // bounces 처리 제거(페이지 이동 시 튀는 현상)
                self.scrollView.bounces = false
                
                // page control 화면에 보이게 설정
                if hiddenPageControl == true {
                    self.pageControl.hidden = true
                } else {
                    self.pageControl.hidden = objectList.count > 3 ? false : true
                }
            }
            
            
            self.scrollView.frame = CGRectMake(-self.viewPadding, 0, self.bounds.width + (2 * self.viewPadding), self.bounds.height)
            self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.width * CGFloat(self.imageObjects.count), self.scrollView.frame.height)
            
            self.scrollView.setContentOffset(offset, animated: false)
            
            // set image View
            for (index, object) in self.imageObjects.enumerate() {
                
                // 일반 뷰 일 경우
                if let view = object as? UIView {
                    view.frame = frameForView(index)
                    view.layoutSubviews()
                    view.tag = browserType == .NORMAL ? index + 1 : index
                    
                    self.scrollView.addSubview(object as! UIView)
                } else {
                    // 이미지나 URL이 넘어왔을 경우
                    let imageView = TWImageView(frame: frameForView(index), browserType: browserType)
                    imageView.imageDelegate = self
                    
                    switch self.browserType {
                    case .NORMAL:
                        // 처음 로드 시 해당 페이지의 이미지만 로드
                        if index == defaultPageIndex || defaultPageIndex - 1 == index || defaultPageIndex + 1 == index {
                            imageView.setupImage(object)
                        }
                        
                        imageView.tag = index + 1
                        imageView.maximumZoomScale = self.maximumScale
                        imageView.imageContentMode = .ScaleAspectFit
                        imageView.imageView.contentMode = .ScaleAspectFit
                    case .BANNER:
                        imageView.setupImage(object)
                        
                        imageView.tag = index
                        imageView.maximumZoomScale = 1.0
                        imageView.minimumZoomScale = 1.0
                        imageView.imageContentMode = .ScaleToFill
                        imageView.imageView.contentMode = .ScaleToFill
                    }
                    
                    self.scrollView.addSubview(imageView)
                }
            }
            
            // 화면에 보여줄 페이지 번호 설정
            self.pageControl.numberOfPages = self.totalPage
            self.pageControl.currentPage = defaultPageIndex
        } else {
            // 이미지를 하나도 받지 못하면 대표 백그라운드 이미지 하나만 보여준다
            
            self.scrollView.frame = CGRectMake(0, 0, self.bounds.width, self.bounds.height)
            self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.width, self.scrollView.frame.height)
            
            // 외부로부터 백그라운드에 쓰일 이미지를 얻어온다
            guard let backgroundImage = self.dataSource?.backgroundImage(self) else {
                return
            }
            
            self.imageObjects = [backgroundImage]
            
            let imageView = TWImageView(frame: frameForView(0), browserType: browserType)
            imageView.tag = 1
            imageView.setupImage(backgroundImage)
            imageView.imageDelegate = self
            
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
    
    
    func autoScrollingView() {
        NSObject.cancelPreviousPerformRequestsWithTarget(self, selector: autoScrollFunctionName , object: nil)
        
        nextPage()
        
        self.performSelector(autoScrollFunctionName, withObject: nil, afterDelay: self.autoPlayTimeInterval)
    }
    
}

extension TWImageBrowser: TWImageViewDelegate {
    func singleTapGesture(view: TWImageView) {
        delegate?.imageBrowserDidSingleTap(self, page: view.tag)
    }
    
    func doubleTapGesture(view: TWImageView) {
        delegate?.imageBrowserDidDoubleTap(self, page: view.tag)
    }
}
