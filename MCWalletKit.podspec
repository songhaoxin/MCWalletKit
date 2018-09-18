#
# Be sure to run `pod lib lint MCWalletKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'MCWalletKit'
  s.version          = '0.1.1'
  s.summary          = 'A chanin-block wallet kit for Etherem and Bitcoin platform'
  s.swift_version    = '4.1'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  A chanin-block wallet kit for Etherem and Bitcoin platform.Services provided contain private key,public key,and address generate.
                       DESC

  s.homepage         = 'https://github.com/songhaoxin/MCWalletKit'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'songhaoxin' => 'songmjian@gmail.com' }
  s.source           = { :git => 'https://github.com/songhaoxin/MCWalletKit.git', :tag => s.version.to_s }

  s.ios.deployment_target = '9.0'

  s.source_files = 'MCWalletKit/Classes/**/*'
  s.dependency 'RealmSwift'
  s.vendored_frameworks = "MCWalletKit/Dependency/*.{framework}"
  
end
