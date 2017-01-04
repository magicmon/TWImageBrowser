//
//  NormalController.swift
//  TWImageBrowser
//
//  Created by Tae Woo Kang on 2016. 5. 26..
//  Copyright © 2016년 magicmon. All rights reserved.
//

import UIKit
import TWImageBrowser

class NormalController: UIViewController {

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
        testViewer.browserType = .normal
        testViewer.delegate = self
        testViewer.dataSource = self
        testViewer.backgroundColor = UIColor.black
        self.automaticallyAdjustsScrollViewInsets = false   // // must
        view.addSubview(testViewer)
        
        setImageList()
        
        setTopButton()
    }
    
    func setImageList() {
        // 1
        imageList.append("https://pixabay.com/static/uploads/photo/2015/11/23/11/57/hot-chocolate-1058197_960_720.jpg" as AnyObject)
        imageList.append("https://pixabay.com/static/uploads/photo/2015/09/17/14/24/guitar-944261_960_720.jpg" as AnyObject)
        imageList.append("https://pixabay.com/static/uploads/photo/2016/01/19/14/25/octagonal-pavilion-1148883_960_720.jpg" as AnyObject)
        imageList.append("https://pixabay.com/static/uploads/photo/2016/10/10/16/48/dragonfly-1729157_1280.jpg" as AnyObject)
        imageList.append("https://pixabay.com/static/uploads/photo/2013/06/09/14/02/white-legged-damselfly-darter-123741_1280.jpg" as AnyObject)
        imageList.append("https://pixabay.com/static/uploads/photo/2016/10/06/05/19/engagement-1718244_1280.jpg" as AnyObject)
        imageList.append("https://pixabay.com/static/uploads/photo/2016/08/07/15/01/blueberries-1576405_1280.jpg" as AnyObject)
        imageList.append("https://pixabay.com/static/uploads/photo/2014/12/16/23/45/soup-570922_1280.jpg" as AnyObject)
        imageList.append("https://pixabay.com/static/uploads/photo/2015/03/07/20/11/dinner-table-663435_1280.jpg" as AnyObject)
        imageList.append("https://pixabay.com/static/uploads/photo/2014/09/13/21/30/dinner-table-444434_1280.jpg" as AnyObject)
        
        // 2
        imageList.append("https://pixabay.com/static/uploads/photo/2016/10/12/23/23/mining-excavator-1736293_1280.jpg" as AnyObject)
        imageList.append("https://pixabay.com/static/uploads/photo/2016/02/20/17/43/excavators-1212472_1280.jpg" as AnyObject)
        imageList.append("https://pixabay.com/static/uploads/photo/2015/09/25/23/54/boy-958457_1280.jpg" as AnyObject)
        imageList.append("https://pixabay.com/static/uploads/photo/2016/10/05/14/13/bag-gypsofilia-seeds-1716747_1280.jpg" as AnyObject)
        imageList.append("https://pixabay.com/static/uploads/photo/2016/10/12/02/56/girl-1733352_1280.jpg" as AnyObject)
        imageList.append("https://pixabay.com/static/uploads/photo/2016/10/18/21/22/california-1751455_1280.jpg" as AnyObject)
        imageList.append("https://pixabay.com/static/uploads/photo/2014/07/10/10/20/golden-gate-bridge-388917_1280.jpg" as AnyObject)
        imageList.append("https://pixabay.com/static/uploads/photo/2016/10/14/19/21/river-1740973_1280.jpg" as AnyObject)
        imageList.append("https://pixabay.com/static/uploads/photo/2013/05/26/05/20/glen-canyon-113688_1280.jpg" as AnyObject)
        imageList.append("https://pixabay.com/static/uploads/photo/2014/09/23/11/29/antelope-canyon-457495_1280.jpg" as AnyObject)
        
        // 3
        imageList.append("https://pixabay.com/static/uploads/photo/2016/01/08/18/00/antelope-canyon-1128815_1280.jpg" as AnyObject)
        imageList.append("https://pixabay.com/static/uploads/photo/2016/09/27/16/01/chestnut-1698730_1280.jpg" as AnyObject)
        imageList.append("https://pixabay.com/static/uploads/photo/2016/08/29/23/19/zingst-1629451_1280.jpg" as AnyObject)
        imageList.append("https://pixabay.com/static/uploads/photo/2016/10/20/18/51/sun-1756322_1280.jpg" as AnyObject)
        imageList.append("https://pixabay.com/static/uploads/photo/2013/02/12/23/50/sunset-81161_1280.jpg" as AnyObject)
        imageList.append("https://pixabay.com/static/uploads/photo/2016/10/01/14/27/dom-1707664_1280.jpg" as AnyObject)
        imageList.append("https://pixabay.com/static/uploads/photo/2011/08/03/01/54/ulm-cathedral-8456_1280.jpg" as AnyObject)
        imageList.append("https://pixabay.com/static/uploads/photo/2016/07/28/22/30/munster-1549950_1280.jpg" as AnyObject)
        imageList.append("https://pixabay.com/static/uploads/photo/2015/03/30/18/59/christ-window-699872_1280.jpg" as AnyObject)
        imageList.append("https://pixabay.com/static/uploads/photo/2016/09/21/04/46/barley-field-1684052_1280.jpg" as AnyObject)
        
        // 4
        imageList.append("https://pixabay.com/static/uploads/photo/2016/10/06/22/05/wine-leaf-1720133_1280.jpg" as AnyObject)
        imageList.append("https://pixabay.com/static/uploads/photo/2016/10/22/17/10/bread-1761197_1280.jpg" as AnyObject)
        imageList.append("https://pixabay.com/static/uploads/photo/2016/09/26/21/01/columnar-1697064_1280.jpg" as AnyObject)
        imageList.append("https://pixabay.com/static/uploads/photo/2016/10/10/06/45/architecture-1727807_1280.jpg" as AnyObject)
        imageList.append("https://pixabay.com/static/uploads/photo/2016/10/01/14/12/dom-1707634_1280.jpg" as AnyObject)
        imageList.append("https://pixabay.com/static/uploads/photo/2016/07/22/16/29/fog-1535201_1280.jpg" as AnyObject)
        imageList.append("https://pixabay.com/static/uploads/photo/2016/08/04/09/19/marigold-1568646_1280.jpg" as AnyObject)
        imageList.append("https://pixabay.com/static/uploads/photo/2016/08/13/12/11/lifts-1590608_1280.jpg" as AnyObject)
        imageList.append("https://pixabay.com/static/uploads/photo/2016/07/11/14/30/volkswagen-1509784_1280.jpg" as AnyObject)
        imageList.append("https://pixabay.com/static/uploads/photo/2016/07/26/10/30/horse-1542480_1280.jpg" as AnyObject)
        
        // 5
        imageList.append("https://pixabay.com/static/uploads/photo/2016/09/19/07/01/lake-irene-1679708_1280.jpg" as AnyObject)
        imageList.append("https://pixabay.com/static/uploads/photo/2015/11/18/17/38/hurricane-1049612_1280.jpg" as AnyObject)
        imageList.append("https://pixabay.com/static/uploads/photo/2016/03/09/04/46/hurricane-1245322_1280.jpg" as AnyObject)
        imageList.append("https://pixabay.com/static/uploads/photo/2013/10/08/20/57/gull-192909_1280.jpg" as AnyObject)
        imageList.append("https://pixabay.com/static/uploads/photo/2016/08/05/14/48/fishing-1572408_1280.jpg" as AnyObject)
        imageList.append("https://pixabay.com/static/uploads/photo/2016/08/18/20/05/light-1603766_1280.jpg" as AnyObject)
        imageList.append("https://pixabay.com/static/uploads/photo/2016/06/08/19/46/cereal-1444495_1280.jpg" as AnyObject)
        imageList.append("https://pixabay.com/static/uploads/photo/2016/08/15/14/36/lavender-field-1595587_1280.jpg" as AnyObject)
        imageList.append("https://pixabay.com/static/uploads/photo/2015/11/26/22/28/girl-1064667_1280.jpg" as AnyObject)
        imageList.append("https://pixabay.com/static/uploads/photo/2016/07/14/13/35/matterhorn-1516734_1280.jpg" as AnyObject)
    }
    
    func setTopButton() {
        let height : CGFloat = UIApplication.shared.statusBarOrientation.isPortrait ? 62.0 : 32.0
        
        prevButton = UIButton(frame: CGRect(x: 0, y: height, width: 50, height: 50))
        prevButton.setTitle("<", for: UIControlState())
        prevButton.addTarget(self, action: #selector(NormalController.prevButtonClicked), for: .touchUpInside)
        view.addSubview(prevButton)
        
        label = UILabel(frame: CGRect(x: 0, y: height, width: self.view.frame.width, height: 50))
        label.text = "1 / \(self.imageList.count)"
        label.textAlignment = NSTextAlignment.center
        label.textColor = UIColor.white
        view.addSubview(label)
        
        nextButton = UIButton(frame: CGRect(x: self.view.frame.width - 50, y: height, width: 50, height: 50))
        nextButton.setTitle(">", for: UIControlState())
        nextButton.addTarget(self, action: #selector(NormalController.nextButtonClicked), for: .touchUpInside)
        view.addSubview(nextButton)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func willAnimateRotation(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        
        let height : CGFloat = UIApplication.shared.statusBarOrientation.isPortrait ? 62.0 : 32.0
        
        // 화면 가로/세로 모드 전환 시 꼭 필요
        testViewer?.frame = self.view.bounds
        label.frame = CGRect(x: 0, y: height, width: self.view.frame.width, height: 50)
        prevButton.frame = CGRect(x: 0, y: height, width: 50, height: 50)
        nextButton.frame = CGRect(x: self.view.frame.width - 50, y: height, width: 50, height: 50)
    }
    
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        
    }
    
    func prevButtonClicked() {
        let _ = testViewer.prevPage(true)
    }
    
    func nextButtonClicked() {
        let _ = testViewer.nextPage(true)
    }
}

extension NormalController: TWImageBrowserDataSource {
    func backgroundImage(_ imageBrowser : TWImageBrowser) -> UIImage? {
        return nil
    }
    
    func loadObjects(_ imageBrowser : TWImageBrowser) -> [Any]? {
        return imageList
    }
    
    func showDefaultPageIndex(_ imageBrowser: TWImageBrowser) -> Int {
        return 3
    }
}

extension NormalController: TWImageBrowserDelegate {
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
