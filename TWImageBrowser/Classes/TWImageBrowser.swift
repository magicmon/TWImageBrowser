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
    func backgroundImage(_ imageBrowser: TWImageBrowser) -> UIImage?        // default background image
    func loadObjects(_ imageBrowser: TWImageBrowser) -> [Any]?              // get image list
    func showDefaultPageIndex(_ imageBrowser: TWImageBrowser) -> Int        // The page number to show first.
}

public protocol TWImageBrowserDelegate: class {
    func imageBrowserDidScroll(_ imageBrowser: TWImageBrowser)
    func imageBrowserDidEndScrollingAnimation(_ imageBrowser: TWImageBrowser)
    func imageBrowserDidSingleTap(_ imageBrowser: TWImageBrowser, page: Int)
    func imageBrowserDidDoubleTap(_ imageBrowser: TWImageBrowser, page: Int, currentZoomScale: CGFloat)
}

public enum TWImageBrowserType: Int {
    case normal
    case banner
}

open class TWImageBrowser: UIView {
    
    internal var autoScrollFunctionName: Selector = #selector(TWImageBrowser.autoScrollingView) // Functions to be called when autoscrolling
    
    internal var scrollView: UIScrollView!
    internal var pageControl: UIPageControl!
    
    internal var lastPage: Int = 1                          // Specifying the last move page.
    
    public weak var dataSource: TWImageBrowserDataSource?
    public weak var delegate: TWImageBrowserDelegate?
    
    public var imageObjects: [Any] = []                       // A list of images
    public var browserType: TWImageBrowserType = .normal      // Browser Type
    public var autoPlayTimeInterval: TimeInterval = 3.0       // Set auto scrolling time (auto scrolling if higher than 0.0).
    
    public var hiddenPageControl: Bool = false                // Whether pagecontrol is visible in bottom.
    
    public var maximumScale: CGFloat = 3.0 {                  // maximum zoom scale (If you are loading a gif, set the max scale to 1.0)
        didSet {
            if maximumScale < 1.0 {
                maximumScale = 1
            }
        }
    }
    
    public var viewPadding: CGFloat = 0.0 {                   // The spacing between each image view
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
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        
        initializeScrollView()
        initializePageControl()
        initializeNotification()
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        // If you have a banner and there is an auto play, you can run it automatically.
        if self.browserType == .banner && self.autoPlayTimeInterval > 0 {
            NSObject.cancelPreviousPerformRequests(withTarget: self, selector:autoScrollFunctionName , object: nil)
            self.perform(autoScrollFunctionName, with: nil, afterDelay:self.autoPlayTimeInterval)
        }
        
        // Load the browser only when there is no data.
        if self.imageObjects.count == 0 {
            loadBrowser()
        }
        
        self.pageControl.frame = CGRect(x: 0, y: self.bounds.size.height - 20.0, width: self.bounds.size.width, height: 20.0)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        
        imageObjects.removeAll()
        scrollView?.removeFromSuperview()
    }
    
    // MARK: - Initial
    func initializeScrollView() {
        // scroll View
        self.scrollView = UIScrollView(frame:CGRect(x: -self.viewPadding, y: 0, width: self.bounds.width + (2 * self.viewPadding), height: self.bounds.height))
        self.scrollView.isPagingEnabled = true
        self.scrollView.showsHorizontalScrollIndicator = false
        self.scrollView.showsVerticalScrollIndicator = false
        self.scrollView.minimumZoomScale = 1.0
        self.scrollView.maximumZoomScale = 1.0
        self.scrollView.zoomScale = 1.0
        self.scrollView.tag = 0
        self.scrollView.delegate = self
        self.scrollView.backgroundColor = UIColor.clear
        self.scrollView.contentSize = CGSize(width: self.scrollView.frame.width, height: self.scrollView.frame.height)
        self.scrollView.contentOffset = CGPoint.zero
        self.scrollView.scrollsToTop = false
        self.scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        self.addSubview(self.scrollView)
    }
    
    func initializePageControl() {
        // page control
        self.pageControl = UIPageControl(frame: CGRect(x: 0, y: self.bounds.size.height - 20.0, width: self.bounds.size.width, height: 20.0))
        self.pageControl.isUserInteractionEnabled = false
        self.addSubview(self.pageControl)
    }
    
    /**
     * Show image view on screen
     */
    func loadBrowser() {
        
        if var objectList = self.dataSource?.loadObjects(self) {
            
            if objectList.count == 0 {
                // TODO: 빈 이미지를 보여주도록 수정
                self.scrollView.frame = self.bounds
                self.scrollView.contentSize = self.scrollView.frame.size
                self.scrollView.setContentOffset(CGPoint.zero, animated: false)
                
                return
            }
            
            // Screen number to show first
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
            
            var offset: CGPoint = CGPoint.zero
            
            switch self.browserType {
            case .normal:
                self.imageObjects = objectList
                self.pageControl.isHidden = true
                
                offset = CGPoint(x: (self.scrollView.frame.width * CGFloat(defaultPageIndex)) + ((2 * self.viewPadding) * CGFloat(defaultPageIndex)), y: 0)
            case .banner:
                // make image list
                // 형태는 다음과 같다
                // image1, image2, image3 이라면 ->>> image3 | image1 | image2 | image3 | image1
                // 과 같은 형태로 이미지가 구성된다
                
                // 마지막 이미지를 제일 첫번째에 위치하도록 한다
                if let lastObject = objectList.last {
                    if objectList.last is UIView {
                        if let lastView = lastObject as? UIView, let copyView = lastView.copyView() {
                            objectList.insert(copyView, at: 0)
                            
                        }
                    } else {
                        objectList.insert(lastObject, at: 0)
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
                
                // Specify offset (second page is 1).
                offset = CGPoint(x: (self.scrollView.frame.width * CGFloat(defaultPageIndex + 1)) + ((2 * self.viewPadding) * CGFloat(defaultPageIndex + 1)), y: 0)
                
                // bounces 처리 제거(페이지 이동 시 튀는 현상)
                self.scrollView.bounces = false
                
                // page control 화면에 보이게 설정
                if hiddenPageControl == true {
                    self.pageControl.isHidden = true
                } else {
                    self.pageControl.isHidden = objectList.count > 3 ? false : true
                }
            }
            
            
            self.scrollView.frame = CGRect(x: -self.viewPadding, y: 0, width: self.bounds.width + (2 * self.viewPadding), height: self.bounds.height)
            self.scrollView.contentSize = CGSize(width: self.scrollView.frame.width * CGFloat(self.imageObjects.count), height: self.scrollView.frame.height)
            
            self.scrollView.setContentOffset(offset, animated: false)
            
            // set image View
            for (index, object) in self.imageObjects.enumerated() {
                
                if let view = object as? UIView {
                    view.frame = frameForView(index)
                    view.layoutSubviews()
                    view.tag = browserType == .normal ? index + 1 : index
                    
                    self.scrollView.addSubview(object as! UIView)
                } else {
                    // If the image or URL is passed
                    let imageView = TWImageView(frame: frameForView(index), browserType: browserType)
                    imageView.imageDelegate = self
                    
                    switch self.browserType {
                    case .normal:
                        // Load only images from this page on first load
                        if index == defaultPageIndex || defaultPageIndex - 1 == index || defaultPageIndex + 1 == index {
                            imageView.setupImage(object)
                        }
                        
                        imageView.tag = index + 1
                        imageView.maximumZoomScale = self.maximumScale
                        imageView.imageContentMode = .scaleAspectFit
                        imageView.imageView.contentMode = .scaleAspectFit
                    case .banner:
                        imageView.setupImage(object)
                        
                        imageView.tag = index
                        imageView.maximumZoomScale = 1.0
                        imageView.minimumZoomScale = 1.0
                        imageView.imageContentMode = .scaleToFill
                        imageView.imageView.contentMode = .scaleToFill
                    }
                    
                    self.scrollView.addSubview(imageView)
                }
            }
            
            // Set page number to display on screen
            self.pageControl.numberOfPages = self.totalPage
            self.pageControl.currentPage = defaultPageIndex
            
            lastPage = defaultPageIndex + 1
        } else {
            // If no images are received, only one representative background image is displayed.
            
            self.scrollView.frame = CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height)
            self.scrollView.contentSize = CGSize(width: self.scrollView.frame.width, height: self.scrollView.frame.height)
            
            guard let backgroundImage = self.dataSource?.backgroundImage(self) else {
                return
            }
            
            self.imageObjects = [backgroundImage]
            
            let imageView = TWImageView(frame: frameForView(0), browserType: browserType)
            imageView.tag = 1
            imageView.setupImage(backgroundImage)
            imageView.imageDelegate = self
            
            self.scrollView.addSubview(imageView)
            
            self.pageControl.isHidden = true
        }
    }
    
    // MARK: Frame
    func frameForView(_ index: Int) -> CGRect {
        var viewFrame : CGRect = self.scrollView.bounds
        viewFrame.origin.x = viewFrame.size.width * CGFloat(index)
        viewFrame.origin.y = 0.0
        viewFrame = viewFrame.insetBy(dx: self.viewPadding, dy: 0.0)
        
        return viewFrame
    }
    
    
    func autoScrollingView() {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: autoScrollFunctionName , object: nil)
        
        nextPage()
        
        self.perform(autoScrollFunctionName, with: nil, afterDelay: self.autoPlayTimeInterval)
    }
}

// MARK: - Orientation
extension TWImageBrowser {
    func initializeNotification() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(TWImageBrowser.orientationDidChangeNotification),
            name: NSNotification.Name.UIDeviceOrientationDidChange,
            object: nil)
    }
    
    public func orientationDidChangeNotification()
    {
        self.scrollView.contentSize = CGSize(width: self.scrollView.frame.width * CGFloat(self.imageObjects.count), height: self.scrollView.frame.height)
        
        for (index, subview) in self.scrollView.subviews.enumerated() {
            
            subview.frame = frameForView(index)
            
            if let imageView = subview as? TWImageView {
                imageView.refreshLayout()
            }
        }
        
        // When the screen change is completed, go to the original page
        move(to: lastPage, animated: false)
    }
}

// MARK: - TWImageViewDelegate
extension TWImageBrowser: TWImageViewDelegate {
    func singleTapGesture(_ view: TWImageView) {
        delegate?.imageBrowserDidSingleTap(self, page: view.tag)
    }
    
    func doubleTapGesture(_ view: TWImageView, currentZoomScale: CGFloat) {
        delegate?.imageBrowserDidDoubleTap(self, page: view.tag, currentZoomScale: currentZoomScale)
    }
}
