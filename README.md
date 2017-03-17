# TWImageBrowser
[![Version](https://img.shields.io/cocoapods/v/WCLShineButton.svg?style=flat)](http://cocoapods.org/pods/WCLShineButton)
[![License](https://img.shields.io/cocoapods/l/WCLShineButton.svg?style=flat)](http://cocoapods.org/pods/WCLShineButton)
[![Platform](https://img.shields.io/cocoapods/p/WCLShineButton.svg?style=flat)](http://cocoapods.org/pods/WCLShineButton)
[![Support](https://img.shields.io/badge/support-iOS%208%2B%20-blue.svg?style=flat)](https://www.apple.com/nl/ios/) 
![Language](https://img.shields.io/badge/Language-%20swift%20%20-blue.svg)

A simple image browser.
Add UIImage, URL, GIF type.

## Demo
![Demo](https://raw.githubusercontent.com/magicmon/TWImageBrowser/master/normal.gif)

![Demo](https://raw.githubusercontent.com/magicmon/TWImageBrowser/master/banner.gif)


## Usage
```
let viewer = TWImageBrowser(frame: self.view.bounds)
viewer.viewPadding = 10.0
viewer.browserType = .normal    // or .banner
viewer.delegate = self
viewer.dataSource = self
viewer.backgroundColor = UIColor.black
self.automaticallyAdjustsScrollViewInsets = false   // precondition
view.addSubview(viewer)
```

DataSource
```
func backgroundImage(_ imageBrowser : TWImageBrowser) -> UIImage? {
    return nil
}

func loadObjects(_ imageBrowser : TWImageBrowser) -> [Any]? {
    let imageList: [Any] = []
    imageList.append("image0.jpg")
    imageList.append("image1.jpg")

    return imageList
}
```

Delegate
```
func imageBrowserDidScroll(_ imageBrowser : TWImageBrowser) {

}

func imageBrowserDidEndScrollingAnimation(_ imageBrowser : TWImageBrowser) {

}

func imageBrowserDidSingleTap(_ imageBrowser: TWImageBrowser, page: Int) {

}

func imageBrowserDidDoubleTap(_ imageBrowser: TWImageBrowser, page: Int, currentZoomScale: CGFloat) {

}

```


## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.


## Installation

TWImageBrowser is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'TWImageBrowser'
```

If you are using swift2.x version, install it below.

```ruby
pod 'TWImageBrowser', :branch => 'swift2.3'
```

## Author

magicmon, http://magicmon.tistory.com

## License

**TWImageBrowser** is available under the MIT license. See the LICENSE file for more info.
