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
    
    @IBOutlet weak var testViewer : TWImageBrowser!
    var prevButton : UIButton!
    var nextButton : UIButton!
    var label : UILabel!
    
    var imageList : [Any] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        testViewer.viewPadding = 10.0
        testViewer.browserType = .normal
        testViewer.delegate = self
        testViewer.dataSource = self
        testViewer.backgroundColor = UIColor.black
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
        let height : CGFloat = UIApplication.shared.statusBarOrientation.isPortrait ? 62.0 : 32.0
        
        prevButton = UIButton(frame: CGRect(x: 0, y: height, width: 50, height: 50))
        prevButton.setTitle("<", for: UIControlState())
        prevButton.addTarget(self, action: #selector(prevButtonClicked), for: .touchUpInside)
        view.addSubview(prevButton)
        
        label = UILabel(frame: CGRect(x: 0, y: height, width: self.view.frame.width, height: 50))
        label.text = "1 / \(self.imageList.count)"
        label.textAlignment = NSTextAlignment.center
        label.textColor = UIColor.white
        view.addSubview(label)
        
        nextButton = UIButton(frame: CGRect(x: self.view.frame.width - 50, y: height, width: 50, height: 50))
        nextButton.setTitle(">", for: UIControlState())
        nextButton.addTarget(self, action: #selector(nextButtonClicked), for: .touchUpInside)
        view.addSubview(nextButton)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { (context) in
            // Code here will execute before the rotation begins.
            
            let height: CGFloat = UIApplication.shared.statusBarOrientation.isPortrait ? 62.0 : 32.0
            
            self.testViewer.orientationDidChangeNotification()
            
            self.label.frame = CGRect(x: 0, y: height, width: self.view.frame.width, height: 50)
            self.prevButton.frame = CGRect(x: 0, y: height, width: 50, height: 50)
            self.nextButton.frame = CGRect(x: self.view.frame.width - 50, y: height, width: 50, height: 50)
            
        }) { (context) in
            
        }
    }
    
    func prevButtonClicked() {
        let _ = testViewer.prevPage(true)
    }
    
    func nextButtonClicked() {
        let _ = testViewer.nextPage(true)
    }
}

extension GIFViewController: TWImageBrowserDataSource {
    func loadObjects(_ imageBrowser: TWImageBrowser) -> [Any]? {
        return imageList
    }

    func backgroundImage(_ imageBrowser : TWImageBrowser) -> UIImage? {
        return nil
    }
    
    func showDefaultPageIndex(_ imageBrowser: TWImageBrowser) -> Int {
        return 0
    }
}

extension GIFViewController: TWImageBrowserDelegate {
    func imageBrowserDidScroll(_ imageBrowser : TWImageBrowser) {
        label.text = "\(imageBrowser.currentPage) / \(imageBrowser.totalPage)"
    }
    
    func imageBrowserDidEndScrollingAnimation(_ imageBrowser : TWImageBrowser) {
        //        print("\(imageBrowser.currentPage) / \(imageBrowser.totalPage)")
    }
    
    func imageBrowserDidSingleTap(_ imageBrowser: TWImageBrowser, page: Int) {
        print("imageBrowserDidSingleTap \(page)")
    }
    
    func imageBrowserDidDoubleTap(_ imageBrowser: TWImageBrowser, page: Int, currentZoomScale: CGFloat) {
        print("imageBrowserDidDoubleTap \(page) \(currentZoomScale)")
    }
}
