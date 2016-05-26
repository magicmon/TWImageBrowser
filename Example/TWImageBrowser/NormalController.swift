//
//  NormalController.swift
//  TWImageBrowser
//
//  Created by Tae Woo Kang on 2016. 5. 26..
//  Copyright © 2016년 magicmon. All rights reserved.
//

import UIKit
import TWImageBrowser

class NormalController: UIViewController, TWImageBrowserDelegate, TWImageBrowserDataSource {

    var testViewer : TWImageBrowser!
    var prevButton : UIButton!
    var nextButton : UIButton!
    var label : UILabel!
    
     var imageList : [AnyObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        testViewer = TWImageBrowser(frame: self.view.bounds)
        testViewer.viewInset = 10.0
        testViewer.browserType = .NORMAL
        testViewer.delegate = self
        testViewer.dataSource = self
        testViewer.backgroundColor = UIColor.blackColor()
        self.automaticallyAdjustsScrollViewInsets = false   // 필수 지정
        view.addSubview(testViewer)
        
        setImageList()
        
        setTopButton()
    }
    
    func setImageList() {
        imageList.append("https://pixabay.com/static/uploads/photo/2015/11/23/11/57/hot-chocolate-1058197_960_720.jpg")
        imageList.append("https://pixabay.com/static/uploads/photo/2015/09/17/14/24/guitar-944261_960_720.jpg")
        imageList.append("https://pixabay.com/static/uploads/photo/2016/01/19/14/25/octagonal-pavilion-1148883_960_720.jpg")
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
    
    
    // MARK: - DataSource
    func backgroundImage(imageBrowser : TWImageBrowser) -> UIImage? {
        return nil
    }
    
    func loadObjects(imageBrowser : TWImageBrowser) -> [AnyObject]? {
        return imageList
    }
    
    
    // MARK: - Delegate
    func imageBrowserDidScroll(imageBrowser : TWImageBrowser) {
        label.text = "\(imageBrowser.currentPage) / \(imageBrowser.totalPage)"
    }
    
    func imageBrowserDidEndScrollingAnimation(imageBrowser : TWImageBrowser) {
        //        log("\(imageBrowser.currentPage) / \(imageBrowser.totalPage)")
    }
}