#官方Cocoapods的源
source 'https://github.com/CocoaPods/Specs.git'
#长连接Cocoapods的源
source 'https://chcts.iask.in/MSH/ios-repos.git'
platform :ios, '9.0'
project 'Bank/Bank.xcodeproj'
use_frameworks!
inhibit_all_warnings!

def using_pods
    #pod 'JSQMessagesViewController'
    pod 'KeychainAccess'
    pod 'Fabric'
    pod 'Crashlytics'
    pod 'Eureka', :git => 'https://github.com/laurivers/Eureka.git', :branch => 'swift-3.0'
    pod 'CHPushSocket'
    pod 'R.swift'
end

target 'Bank' do
    using_pods
end
