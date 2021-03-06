Pod::Spec.new do |s|
    s.name             = "ZBiM-SDK-iOS"
    s.version          = "1.3"
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
    s.documentation_url = "https://github.com/zumobi/zbim-sdk-ios/blob/master/README.md"
    s.platform     = :ios, '7.0'
    s.requires_arc = true

    s.vendored_libraries = 'Pod/Libraries/libzbim.a'
    s.resource = 'Pod/Resources/zbimResources.bundle'
    s.source_files = 'Pod/Classes/*.{h,m}', 'Pod/Classes/**/*.{h,m}'
    s.public_header_files = 'Pod/Classes/*.h'
    s.frameworks = 'Accounts','AdSupport','AVFoundation','AVKit','CoreGraphics','CoreLocation','CoreMedia','EventKit','EventKitUI','Foundation','MessageUI','PassKit','QuartzCore','Security','Social','StoreKit','SystemConfiguration','Twitter','UIKit'

    s.library = 'sqlite3', 'z'

    s.dependencies = {
      "AWSCore" => [
        "~> 2.2.7"
      ],
      "AWSSQS" => [
        "~> 2.2.7"
      ],
      "AWSCognito" => [
        "~> 2.2.7"
      ],
      "FMDB" => [
        "~> 2.5"
      ]
    }
end
