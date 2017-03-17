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
    func singleTapGesture(_ view: TWImageView)
    func doubleTapGesture(_ view: TWImageView, currentZoomScale: CGFloat)
}

class TWImageView: UIScrollView {
    
    var containerView : UIView!
    var imageView : UIImageView!
    var imageContentMode: UIViewContentMode = .scaleAspectFit
    
    var indicator: UIActivityIndicatorView!
    var minSize: CGSize = CGSize.zero
    
    var browserType: TWImageBrowserType = .normal
    
    var maximumScale: CGFloat = 3.0
    
    var isGif: Bool = false
    
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
        containerView.backgroundColor = UIColor.clear
        addSubview(containerView)
        
        // image view
        imageView = UIImageView(frame: self.containerView.bounds)
        containerView.addSubview(imageView)
        
        // indicator view
        indicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        indicator.center = self.containerView.center
        indicator.activityIndicatorViewStyle = .white
        indicator.hidesWhenStopped = true
        containerView.addSubview(indicator)
        
        // gesture recognizer
        let singleTapRecognizer = UITapGestureRecognizer(target: self, action:#selector(scrollViewDidSingleTapped))
        singleTapRecognizer.numberOfTapsRequired = 1
        containerView.addGestureRecognizer(singleTapRecognizer)
        
        let doubleTapRecognizer = UITapGestureRecognizer(target: self, action:#selector(scrollViewDidDoubleTapped))
        doubleTapRecognizer.numberOfTapsRequired = 2
        containerView.addGestureRecognizer(doubleTapRecognizer)
        
        singleTapRecognizer.require(toFail: doubleTapRecognizer)
    }
    
    func setupScrollViewOption() {
        self.delegate = self
        self.showsHorizontalScrollIndicator = false
        self.showsVerticalScrollIndicator = false
        self.maximumZoomScale = maximumScale
        self.minimumZoomScale = 1.0
        self.backgroundColor = UIColor.clear
        self.scrollsToTop = false
    }
    
    func setupImage(_ image : Any?) {
        if let loadImage = image as? UIImage {
            
            // append image
            self.imageView.image = loadImage
            
            self.refreshLayout()
        } else if let urlString = image as? String {
            
            if urlString.hasPrefix("http://") || urlString.hasPrefix("https://") {
                
                self.indicator.startAnimating()
                
                TWImageCache.sharedInstance().cacheImage(withURL: urlString, completion: { (image) in
                    
                    self.indicator.stopAnimating()
                    
                    self.maximumZoomScale = 1.0
                    self.minimumZoomScale = 1.0
                    
                    if let image = image {
                        if let rawData = image.rawData {
                            var c = [UInt8](repeating: 0, count: 1)
                            (rawData as NSData).getBytes(&c, length: 1)
                            
                            if c[0] == 0x47 {       // gif
                                self.imageView.image = UIImage.gifImage(withData: rawData)
                                self.maximumZoomScale = 1.0
                                
                                self.isGif = true
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
                let components = urlString.components(separatedBy: "/")
                
                if components.count > 1 {
                    // check for full path
                    self.imageView.image = UIImage(contentsOfFile: urlString)
                } else {
                    // only have the file name
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
        
        let imageSize = self.imageView.contentSize
        
        self.containerView.frame = CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height)
        self.imageView.center = CGPoint(x: imageSize.width / 2, y: imageSize.height / 2)
        self.imageView.contentMode = imageContentMode
        
        self.contentSize = imageSize
        self.minSize = imageSize
        self.indicator.center = self.containerView.center
        
        
        // Center containerView by set insets
        centerContent()
    }
    
    
    // MARK: - Helper
    func getMaxZoomScale() -> CGFloat{
        
        if self.browserType == .banner {
            return 1.0
        }
        
        guard let imageSize = self.imageView.image?.size else {
            return 1.0
        }
        
        let imagePresentationSize: CGSize = self.imageView.contentSize
        
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
    func scrollViewDidSingleTapped(_ recognizer: UITapGestureRecognizer) {
        imageDelegate?.singleTapGesture(self)
    }
    
    func scrollViewDidDoubleTapped(_ recognizer: UITapGestureRecognizer) {
        if self.zoomScale > self.minimumZoomScale {
            self.setZoomScale(self.minimumZoomScale, animated: true)
        } else if (self.zoomScale < self.maximumZoomScale) {
            
            if isGif { return }
            
            let location = recognizer.location(in: recognizer.view)
            var zoomToRect = CGRect(x: 0, y: 0, width: 50, height: 50)
            zoomToRect.origin = CGPoint(x: location.x - zoomToRect.width / 2, y: location.y - zoomToRect.height / 2)
            self.zoom(to: zoomToRect, animated: true)
        }
        
        imageDelegate?.doubleTapGesture(self, currentZoomScale: self.zoomScale)
    }
}

// MARK: - UIScrollViewDelegate
extension TWImageView: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.containerView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerContent()
    }
}

// MARK: - UIImageView extension
extension UIImageView {
    var contentSize: CGSize {
        if let image = self.image {
            return image.sizeThatFits(self.bounds.size)
        }
        
        return CGSize.zero
    }
}
