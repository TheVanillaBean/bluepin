platform :ios, ’9.0’

target ‘Bluepin’ do

  use_frameworks!

  pod 'DeviceKit', '~> 1.0’
  pod 'Toast-Swift', 
	:git => "https://github.com/scalessec/Toast-Swift.git",
	:branch => ‘feature/swift-3.0’
  pod 'PhoneNumberKit',
	:git => "https://github.com/marmelroy/PhoneNumberKit.git", 
	:branch => ‘master’
  pod 'SinchVerification-Swift'
  pod 'ALCameraViewController'
  pod 'AlamofireImage', '~> 3.0'
  pod 'TTTAttributedLabel'
  pod 'AFNetworking', '~> 3.0'
  pod 'JSQMessagesViewController'
  pod ‘Firebase’
  pod 'Firebase/Core'
  pod 'Firebase/Auth'
  pod 'Firebase/Database'
  pod 'Firebase/Storage'
  pod 'Firebase/Messaging'
  pod 'HotlineSDK'
  pod 'BRYXBanner'
  pod 'Firebase/Crash'
  pod 'Kingfisher', '~> 3.0'
  pod 'ImagePicker'

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '3.0'
    end
  end
end

end
