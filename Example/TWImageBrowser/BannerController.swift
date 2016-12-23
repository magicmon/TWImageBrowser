//
//  BannerController.swift
//  TWImageBrowser
//
//  Created by Tae Woo Kang on 2016. 5. 26..
//  Copyright © 2016년 magicmon. All rights reserved.
//

import UIKit
import TWImageBrowser

class BannerController: UIViewController, TWImageBrowserDelegate, TWImageBrowserDataSource {
    
    var testViewer: TWImageBrowser!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let height : CGFloat = UIApplication.sharedApplication().statusBarOrientation.isPortrait ? 0.0 : 32.0
        
        testViewer = TWImageBrowser(frame: CGRectMake(0, height + 64.0, self.view.frame.size.width, 150))
        testViewer.browserType = .BANNER
        testViewer.delegate = self
        testViewer.dataSource = self
        testViewer.autoPlayTimeInterval = 3.0
        
        testViewer.backgroundColor = UIColor.blackColor()
        self.automaticallyAdjustsScrollViewInsets = false   // 필수 지정
        view.addSubview(testViewer)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func willAnimateRotationToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        
        let height : CGFloat = UIApplication.sharedApplication().statusBarOrientation.isPortrait ? 62.0 : 32.0
        
        // 화면 가로/세로 모드 전환 시 꼭 필요
        testViewer?.frame = CGRectMake(0, height, self.view.frame.size.width, 150)
    }
    
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        
    }
    
    // MARK: - DataSource
    func backgroundImage(imageBrowser: TWImageBrowser) -> UIImage? {
        return nil
    }
    
    func loadObjects(imageBrowser: TWImageBrowser) -> [AnyObject]? {
        var imageList : [AnyObject] = []
        imageList.append("image0.jpg")
        imageList.append("https://pixabay.com/static/uploads/photo/2015/11/23/11/57/hot-chocolate-1058197_960_720.jpg")
        imageList.append("https://pixabay.com/static/uploads/photo/2015/09/17/14/24/guitar-944261_960_720.jpg")
        
        return imageList
    }
    
    func showDefaultPageIndex(imageBrowser: TWImageBrowser) -> Int {
        return 0
    }
    
    
    // MARK: - Delegate
    func imageBrowserDidScroll(imageBrowser: TWImageBrowser) {
//        log("\(imageBrowser.currentPage) / \(imageBrowser.totalPage)")
    }
    
    func imageBrowserDidEndScrollingAnimation(imageBrowser : TWImageBrowser) {
//        log("\(imageBrowser.currentPage) / \(imageBrowser.totalPage)")
    }
    
    func imageBrowserDidSingleTap(imageBrowser: TWImageBrowser, page: Int) {
        print("imageBrowserDidSingleTap \(page)")
    }
    
    func imageBrowserDidDoubleTap(imageBrowser: TWImageBrowser, page: Int, currentZoomScale: CGFloat) {
        print("imageBrowserDidDoubleTap \(page) \(currentZoomScale)")
    }
}