# Uncomment the next line to define a global platform for your project
 platform :ios, '9.0'

target 'Shopify' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Shopify
    pod 'RealmSwift', '~> 10.20.0'
    pod 'Alamofire'
    pod 'ReachabilitySwift'
    pod 'Cosmos'
    pod 'JJFloatingActionButton'
    pod 'BadgeSwift'
    pod 'Kingfisher'
    pod 'Firebase/Auth'
    pod 'Firebase/Database'
    pod 'Firebase/Firestore'
    pod 'GoogleSignIn', '~> 5.0.2'

  target 'ShopifyTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'ShopifyUITests' do
    # Pods for testing
  end

end
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13'
    end
  end
end