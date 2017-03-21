#
# Be sure to run `pod lib lint TWImageBrowser.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'TWImageBrowser'
  s.version          = '2.0.4'
  s.summary          = 'Simple image browser or banner.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
                       Simple image browser or banner. written in swift.
                       DESC

  s.homepage         = 'https://github.com/magicmon/TWImageBrowser'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'magicmon' => 'sagun25si@gmail.com' }
  s.source           = { :git => 'https://github.com/magicmon/TWImageBrowser.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'

  s.source_files = 'TWImageBrowser/Classes/**/*'

  s.dependency 'AlamofireImage'
  s.dependency 'FLAnimatedImage'
end
