//
//  TWImageView.swift
//  TWImageBrowser
//
//  Created by Tae Woo Kang on 2016. 5. 26..
//  Copyright © 2016 magicmon. All rights reserved.
//

import UIKit
import AlamofireImage

class TWImageView: UIScrollView {
    
    var containerView : UIView!
    var imageView : UIImageView!
    var indicator : UIActivityIndicatorView!
    var minSize : CGSize = CGSizeZero
    var browserType : TWImageBrowserType = .NORMAL
    
    var maximumScale: CGFloat = 3.0
    
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
    
    func setupSubviews() {
        // container view
        self.containerView = UIView(frame: self.bounds)
        self.containerView.backgroundColor = UIColor.clearColor()
        self.addSubview(self.containerView)
        
        // image view
        self.imageView = UIImageView(frame: self.containerView.bounds)
        self.containerView.addSubview(self.imageView)
        
        // indicator view
        self.indicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50))
        self.indicator.center = self.containerView.center
        self.indicator.activityIndicatorViewStyle = .White
        self.indicator.hidesWhenStopped = true
        self.containerView.addSubview(self.indicator)
        
        // gesture recognizer
        let doubleTapRecognizer = UITapGestureRecognizer(target: self, action:#selector(TWImageView.scrollViewDoubleTapped(_:)))
        doubleTapRecognizer.numberOfTapsRequired = 2
        self.containerView.addGestureRecognizer(doubleTapRecognizer)
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
            
            // 이미지 삽입
            self.imageView.image = loadImage
            
        } else if let urlString = image as? String {
            
            if urlString.hasPrefix("http://") || urlString.hasPrefix("https://") {
                // url 링크가 넘어온 경우

//                let imageQueue = dispatch_queue_create("TWImageLoader", nil)
//                
//                dispatch_async(imageQueue, { () -> Void in
//                    self.indicator.startAnimating()
//                    
//                    guard let imageURL = NSURL(string: urlString) else {
//                        return
//                    }
//                    
//                    guard let imageData = NSData(contentsOfURL: imageURL) else {
//                        return
//                    }
//                    
//                    let image = UIImage(data: imageData)
//                    
//                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
//                        
//                        self.indicator.stopAnimating()
//                        
//                        // 다운로드 받은 이미지 추가
//                        self.imageView.image = image
//                        
//                        // 이미지 크기에 따라 maxZomm 재 설정
//                        self.maximumZoomScale = max(1.0, self.getMaxZoomScale())
//                        self.minimumZoomScale = 1.0
//
//                        // 화면 갱신
//                        self.refreshLayout()
//                    })
//                })
                
                guard let imageURL = NSURL(string: urlString) else {
                    return
                }
                
                self.indicator.startAnimating()
                
                self.imageView.af_setImageWithURL(imageURL, runImageTransitionIfCached: false, completion: { (response) in
                    
                    self.indicator.stopAnimating()
                    
                    self.imageView.image = response.result.value
                    
                    self.maximumZoomScale = self.maximumScale
                    self.minimumZoomScale = 1.0

                    self.refreshLayout()
                })
            } else {
                let components = urlString.componentsSeparatedByString("/")
                
                if components.count > 1 {
                    // fullpath가 넘어왔는지 체크
                    self.imageView.image = UIImage(contentsOfFile:urlString)
                }
                else {
                    // 파일 이름만 넘어온 경우
                    self.imageView.image = UIImage(named: urlString)
                }
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
        
        self.contentSize = imageSize
        self.minSize = imageSize
        self.indicator.center = self.containerView.center
        
        // Center containerView by set insets
        centerContent()
    }
    
    // MARK: - GestureRecognizer
    func scrollViewDoubleTapped(recognizer: UITapGestureRecognizer) {
        if self.zoomScale > self.minimumZoomScale {
            self.setZoomScale(self.minimumZoomScale, animated: true)
        } else if (self.zoomScale < self.maximumZoomScale) {
            
            let location = recognizer.locationInView(recognizer.view)
            var zoomToRect = CGRectMake(0, 0, 50, 50)
            zoomToRect.origin = CGPointMake(location.x - CGRectGetWidth(zoomToRect) / 2, location.y - CGRectGetHeight(zoomToRect) / 2)
            self.zoomToRect(zoomToRect, animated: true)
        }
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