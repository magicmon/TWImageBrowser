# TWImageBrowser


## Demo
![Demo](https://raw.githubusercontent.com/magicmon/TWImageBrowser/master/normal.gif)

![Demo](https://raw.githubusercontent.com/magicmon/TWImageBrowser/master/banner.gif)


## Usage
```
let viewer = TWImageBrowser(frame: self.view.bounds)
viewer.viewInset = 10.0
viewer.browserType = .NORMAL    // or .BANNER
viewer.delegate = self
viewer.dataSource = self
viewer.backgroundColor = UIColor.blackColor()
self.automaticallyAdjustsScrollViewInsets = false   // precondition
view.addSubview(viewer)
```

DataSource
```
func backgroundImage(imageBrowser : TWImageBrowser) -> UIImage? {
    return nil
}

func loadObjects(imageBrowser : TWImageBrowser) -> [AnyObject]? {
    let imageList: [AnyObject] = []
    imageList.append("image0.jpg")
    imageList.append("image1.jpg")

    return imageList
}
```

Delegate
```
func imageBrowserDidScroll(imageBrowser: TWImageBrowser) {

}

func imageBrowserDidEndScrollingAnimation(imageBrowser: TWImageBrowser) {

}
```


## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

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

Tae Woo Kang, http://magicmon.tistory.com

## License

**TWImageBrowser** is available under the MIT license. See the LICENSE file for more info.
