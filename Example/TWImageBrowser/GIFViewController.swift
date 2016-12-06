//
//  GIFViewController.swift
//  TWImageBrowser
//
//  Created by magicmon on 2016. 12. 6..
//  Copyright © 2016년 magicmon. All rights reserved.
//

import UIKit
import TWImageBrowser

class GIFViewController: UIViewController {
    
    var testViewer : TWImageBrowser!
    var prevButton : UIButton!
    var nextButton : UIButton!
    var label : UILabel!
    
    var imageList : [AnyObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        testViewer = TWImageBrowser(frame: self.view.bounds)
        testViewer.viewPadding = 10.0
        testViewer.browserType = .NORMAL
        testViewer.delegate = self
        testViewer.dataSource = self
        testViewer.backgroundColor = UIColor.blackColor()
        self.automaticallyAdjustsScrollViewInsets = false   // must
        view.addSubview(testViewer)
        
        setGIFList()
        
        setTopButton()
    }
    
    func setGIFList() {
        // 1
        imageList.append("http://i.giphy.com/l41YeojZ8G5G9cVZC.gif")
        imageList.append("http://i.giphy.com/l41YlQSaTWPkYQx8I.gif")
        imageList.append("http://i.giphy.com/3oEjHXHXkLmFLqRZ2U.gif")
        imageList.append("http://i.giphy.com/3otPoPmNBUk02YKdjy.gif")
        imageList.append("http://i.giphy.com/D1HxWh7uNdF4Y.gif")
        
        // 2
        imageList.append("http://i.giphy.com/3o7TKuWAyiu6tICQYU.gif")
        imageList.append("http://i.giphy.com/3oz8xJkty91GlgYEg0.gif")
        imageList.append("http://i.giphy.com/3o6Ztj26dwdx10reFi.gif")
        imageList.append("http://i.giphy.com/xT8qBay7zo6A0xOA3S.gif")
        imageList.append("http://i.giphy.com/jzVYqDzxtapFe.gif")
        
        // 3
        imageList.append("http://i.giphy.com/Ko7HuFTsEv1zW.gif")
        imageList.append("http://i.giphy.com/64HTMW9A67ROE.gif")
        imageList.append("http://i.giphy.com/12y5yZn8ZvSlHy.gif")
        imageList.append("http://i.giphy.com/11RJ3ifvNR5eDe.gif")
        imageList.append("http://i.giphy.com/xUPOqlYgyI3CQcFEe4.gif")
        
        // 4
        imageList.append("http://i.giphy.com/26BRQSNJRFAV5fsGI.gif")
        imageList.append("http://i.giphy.com/3oAt2bhPYWJl4fg4Ks.gif")
        imageList.append("http://i.giphy.com/3oD3YOxRfDh6UJpsLC.gif")
        imageList.append("http://i.giphy.com/l3E6sSkkpkEQdCjYc.gif")
        imageList.append("http://i.giphy.com/3o6ozxRrKIQgKyKdoc.gif")
    }
    
    func setTopButton() {
        let height : CGFloat = UIApplication.sharedApplication().statusBarOrientation.isPortrait ? 62.0 : 32.0
        
        prevButton = UIButton(frame: CGRectMake(0, height, 50, 50))
        prevButton.setTitle("<", forState: .Normal)
        prevButton.addTarget(self, action: #selector(NormalController.prevButtonClicked), forControlEvents: .TouchUpInside)
        view.addSubview(prevButton)
        
        label = UILabel(frame: CGRectMake(0, height, self.view.frame.width, 50))
        label.text = "1 / \(self.imageList.count)"
        label.textAlignment = NSTextAlignment.Center
        label.textColor = UIColor.whiteColor()
        view.addSubview(label)
        
        nextButton = UIButton(frame: CGRectMake(self.view.frame.width - 50, height, 50, 50))
        nextButton.setTitle(">", forState: .Normal)
        nextButton.addTarget(self, action: #selector(NormalController.nextButtonClicked), forControlEvents: .TouchUpInside)
        view.addSubview(nextButton)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func willAnimateRotationToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        
        let height : CGFloat = UIApplication.sharedApplication().statusBarOrientation.isPortrait ? 62.0 : 32.0
        
        // 화면 가로/세로 모드 전환 시 꼭 필요
        testViewer?.frame = self.view.bounds
        label.frame = CGRectMake(0, height, self.view.frame.width, 50)
        prevButton.frame = CGRectMake(0, height, 50, 50)
        nextButton.frame = CGRectMake(self.view.frame.width - 50, height, 50, 50)
    }
    
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        
    }
    
    func prevButtonClicked() {
        testViewer.prevPage(true)
    }
    
    func nextButtonClicked() {
        testViewer.nextPage(true)
    }
}

extension GIFViewController: TWImageBrowserDataSource {
    func backgroundImage(imageBrowser : TWImageBrowser) -> UIImage? {
        return nil
    }
    
    func loadObjects(imageBrowser : TWImageBrowser) -> [AnyObject]? {
        return imageList
    }
    
    func showDefaultPageIndex(imageBrowser: TWImageBrowser) -> Int {
        return 0
    }
}

extension GIFViewController: TWImageBrowserDelegate {
    func imageBrowserDidScroll(imageBrowser : TWImageBrowser) {
        label.text = "\(imageBrowser.currentPage) / \(imageBrowser.totalPage)"
    }
    
    func imageBrowserDidEndScrollingAnimation(imageBrowser : TWImageBrowser) {
        //        print("\(imageBrowser.currentPage) / \(imageBrowser.totalPage)")
    }
    
    func imageBrowserDidSingleTap(imageBrowser: TWImageBrowser, page: Int) {
        print("imageBrowserDidSingleTap \(page)")
    }
    
    func imageBrowserDidDoubleTap(imageBrowser: TWImageBrowser, page: Int) {
        print("imageBrowserDidDoubleTap \(page)")
    }
}