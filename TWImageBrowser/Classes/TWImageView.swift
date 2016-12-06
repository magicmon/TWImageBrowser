//
//  TWImageView.swift
//  TWImageBrowser
//
//  Created by magicmon on 2016. 5. 26..
//  Copyright © 2016 magicmon. All rights reserved.
//

import UIKit
import AlamofireImage

protocol TWImageViewDelegate: class {
    func singleTapGesture(view: TWImageView)
    func doubleTapGesture(view: TWImageView)
}

class TWImageView: UIScrollView {
    
    var containerView : UIView!
    var imageView : UIImageView!
    var imageContentMode: UIViewContentMode = .ScaleAspectFit
    
    var indicator: UIActivityIndicatorView!
    var minSize: CGSize = CGSizeZero
    
    var browserType: TWImageBrowserType = .NORMAL
    
    var maximumScale: CGFloat = 3.0
    
    weak var imageDelegate: TWImageViewDelegate?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // view 구성
        setupSubviews()
        
        // scroll view에 대한 조건 설정
        setupScrollViewOption()
        
        // 화면 갱신
        refreshLayout()
    }
    
    init(frame: CGRect, browserType: TWImageBrowserType) {
        super.init(frame: frame)
        
        self.browserType = browserType
        
        // view 구성
        setupSubviews()
        
        // scroll view에 대한 조건 설정
        setupScrollViewOption()
        
        // 화면 갱신
        refreshLayout()
    }
    
    deinit {
        imageView?.image = nil
        imageView?.removeFromSuperview()
        imageView = nil
    }
    
    func setupSubviews() {
        // container view
        containerView = UIView(frame: self.bounds)
        containerView.backgroundColor = UIColor.clearColor()
        addSubview(self.containerView)
        
        // image view
        imageView = UIImageView(frame: self.containerView.bounds)
        containerView.addSubview(self.imageView)
        
        // indicator view
        indicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50))
        indicator.center = self.containerView.center
        indicator.activityIndicatorViewStyle = .White
        indicator.hidesWhenStopped = true
        containerView.addSubview(self.indicator)
        
        // gesture recognizer
        let singleTapRecognizer = UITapGestureRecognizer(target: self, action:#selector(scrollViewDidSingleTapped))
        singleTapRecognizer.numberOfTapsRequired = 1
        containerView.addGestureRecognizer(singleTapRecognizer)
        
        let doubleTapRecognizer = UITapGestureRecognizer(target: self, action:#selector(scrollViewDidDoubleTapped))
        doubleTapRecognizer.numberOfTapsRequired = 2
        containerView.addGestureRecognizer(doubleTapRecognizer)
        
        singleTapRecognizer.requireGestureRecognizerToFail(doubleTapRecognizer)
    }
    
    func setupScrollViewOption() {
        self.delegate = self
        self.showsHorizontalScrollIndicator = false
        self.showsVerticalScrollIndicator = false
        self.maximumZoomScale = maximumScale
        self.minimumZoomScale = 1.0
        self.backgroundColor = UIColor.clearColor()
        self.scrollsToTop = false
    }
    
    func setupImage(image : AnyObject?) {
        if let loadImage = image as? UIImage {
            
            // append image
            self.imageView.image = loadImage
            
            self.refreshLayout()
        } else if let urlString = image as? String {
            
            if urlString.hasPrefix("http://") || urlString.hasPrefix("https://") {
                // url

                self.indicator.startAnimating()
                
                TWImageCache.sharedInstance().cacheImageWithURL(urlString, completion: { (image) in
                    
                    self.indicator.stopAnimating()
                    
                    self.maximumZoomScale = 1.0
                    self.minimumZoomScale = 1.0
                    
                    if let image = image {
                        if let rawData = image.rawData {
                            var c = [UInt8](count: 1, repeatedValue: 0)
                            rawData.getBytes(&c, length: 1)
                            
                            if c[0] == 0x47 {       // gif
                                self.imageView.image = UIImage.gifImageWithData(rawData)
                            } else {
                                self.imageView.image = image
                                self.maximumZoomScale = self.maximumScale
                            }
                        } else {
                            self.imageView.image = image
                            self.maximumZoomScale = self.maximumScale
                        }
                    } else {
                        self.imageView.image = nil
                    }
                    
                    self.refreshLayout()
                })
                
            } else {
                let components = urlString.componentsSeparatedByString("/")
                
                if components.count > 1 {
                    // fullpath가 넘어왔는지 체크
                    self.imageView.image = UIImage(contentsOfFile: urlString)
                }
                else {
                    // 파일 이름만 넘어온 경우
                    self.imageView.image = UIImage(named: urlString)
                }
                
                self.refreshLayout()
            }
        }
    }
    
    func refreshLayout() {
        
        self.setZoomScale(self.minimumZoomScale, animated: false)
        
        self.containerView.frame = self.bounds
        self.imageView.frame = self.containerView.bounds
        
        let imageSize = self.imageView.contentSize()
        
        self.containerView.frame = CGRectMake(0, 0, imageSize.width, imageSize.height)
        self.imageView.center = CGPointMake(imageSize.width / 2, imageSize.height / 2)
        self.imageView.contentMode = imageContentMode
        
        self.contentSize = imageSize
        self.minSize = imageSize
        self.indicator.center = self.containerView.center
        
        
        // Center containerView by set insets
        centerContent()
    }
    
    
    // MARK: - Helper
    func getMaxZoomScale() -> CGFloat{
        
        if self.browserType == .BANNER {
            return 1.0
        }
        
        guard let imageSize = self.imageView.image?.size else {
            return 1.0
        }
        
        let imagePresentationSize: CGSize = self.imageView.contentSize()
        
        return max(imageSize.height / imagePresentationSize.height, imageSize.width / imagePresentationSize.width)
    }
    
    func centerContent() {
        
        let frame = self.containerView!.frame
        
        var top: CGFloat = 0
        var left: CGFloat = 0
        
        if (self.contentSize.width < self.bounds.size.width) {
            left = (self.bounds.size.width - self.contentSize.width) * 0.5
        }
        if (self.contentSize.height < self.bounds.size.height) {
            top = (self.bounds.size.height - self.contentSize.height) * 0.5
        }
        
        top -= frame.origin.y;
        left -= frame.origin.x;
        
        self.contentInset = UIEdgeInsetsMake(top, left, top, left);
    }
}

// MARK: - GestureRecognizer
extension TWImageView {
    func scrollViewDidSingleTapped(recognizer: UITapGestureRecognizer) {
        imageDelegate?.singleTapGesture(self)
    }
    
    func scrollViewDidDoubleTapped(recognizer: UITapGestureRecognizer) {
        if self.zoomScale > self.minimumZoomScale {
            self.setZoomScale(self.minimumZoomScale, animated: true)
        } else if (self.zoomScale < self.maximumZoomScale) {
            
            let location = recognizer.locationInView(recognizer.view)
            var zoomToRect = CGRectMake(0, 0, 50, 50)
            zoomToRect.origin = CGPointMake(location.x - CGRectGetWidth(zoomToRect) / 2, location.y - CGRectGetHeight(zoomToRect) / 2)
            self.zoomToRect(zoomToRect, animated: true)
        }
        
        imageDelegate?.doubleTapGesture(self)
    }
}

// MARK: - UIScrollViewDelegate
extension TWImageView: UIScrollViewDelegate {
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return self.containerView
    }
    
    func scrollViewDidZoom(scrollView: UIScrollView) {
        centerContent()
    }
}

extension UIImageView {
    func contentSize() -> CGSize {
        if let image = self.image {
            return image.sizeThatFits(self.bounds.size)
        }
        
        return CGSizeZero
    }
}

extension UIImage {
    func sizeThatFits(size:CGSize) -> CGSize {
        var imageSize = CGSizeMake(self.size.width / self.scale, self.size.height / self.scale)
        
        let widthRatio = imageSize.width / size.width
        let heightRatio = imageSize.height / size.height
        
        if widthRatio > heightRatio {
            imageSize = CGSizeMake(imageSize.width / widthRatio, imageSize.height / widthRatio)
        } else {
            imageSize = CGSizeMake(imageSize.width / heightRatio, imageSize.height / heightRatio)
        }
        
        return imageSize
    }
}