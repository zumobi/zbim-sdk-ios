Pod::Spec.new do |s|
    s.name             = "ZBiM-SDK-iOS"
    s.version          = "1.1.3"
    s.summary          = "The ZBiM SDK for iOS handles content marketing in your app"
    s.description      = <<-DESC
                       The ZBiM SDK for iOS handles all the issues surrounding getting content securely into your existing application. The SDK
                       and ZBiM service manages all the presentation, content management, metrics, and security for you through
                       an easy to use portal.
                       DESC
    s.homepage         = "http://www.zumobi.com"
    s.license          = 'MIT'
    s.author           = { "Zumobi" => "zbim-support@zumobi.com" }
    s.source           = { :git => "https://github.com/zumobi/zbim-sdk-ios.git", :tag => s.version.to_s }
    s.social_media_url = 'https://twitter.com/zumobi'
    s.documentation_url = "https://github.com/zumobi/zbim-sdk-ios/blob/master/ZBiM%20Documentation.pdf?raw=true"
    s.platform     = :ios, '7.0'
    s.requires_arc = true

    s.vendored_libraries = 'Pod/Libraries/libzbim.a'
    s.resource = 'Pod/Resources/zbimResources.bundle'
    s.source_files = 'Pod/Classes/*.{h,m}', 'Pod/Classes/**/*.{h,m}'
    s.public_header_files = 'Pod/Classes/*.h'

    s.frameworks = 'Accounts','AdSupport','CoreGraphics','CoreLocation','CoreTelephony','EventKit','EventKitUI','Foundation','ImageIO','MediaPlayer','MessageUI','PassKit','Security','Social','StoreKit','SystemConfiguration','Twitter','UIKit'

    s.library = 'sqlite3', 'z'

    s.dependency 'Bolts', '~> 1.1.0'
    s.dependency 'Mantle', '~> 1.4'
    s.dependency 'TMCache', '~> 1.2.1'
    s.dependency 'XMLDictionary', '~> 1.4.0'
    s.dependency 'UICKeyChainStore', '~> 1.0'
    s.dependency 'Reachability', '~> 3.1'
    s.dependency 'GZIP', '~> 1.0.3'
    s.dependency 'FMDB', '~> 2.4.0'
end
