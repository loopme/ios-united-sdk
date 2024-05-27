#  Be sure to run `pod spec lint LoopMeUnitedSDK.podspec'

Pod::Spec.new do |s|
  s.name         = "LoopMeUnitedSDK"
  s.version      = "7.4.18"
  s.summary      = "LoopMe is the largest mobile video DSP and Ad Network, reaching over 1 billion consumers world-wide."

  s.description  = <<-DESC
    LoopMe is the largest mobile video DSP and Ad Network, reaching over 1 billion consumers world-wide. LoopMe’s full-screen video and rich media ad formats deliver more engaging mobile advertising experiences to consumers on smartphones and tablets.
    The LoopMe SDK is distributed as source code that you must include in your application and provides facilities to retrieve, display ads in your application.
    If you have questions please contact us at support@loopmemedia.com.
    DESC

  s.homepage     = "https://loopme.com"
  s.license      = { :type => "BSD", :file => "LICENSE.md" }
  s.authors            = { "Bogdan Korda" => "bogdan@loopme.com", "Volodymyr Novikov" => "volodymyr.novikov@loopme.com", "Evgen A. Epanchin" => "evgen@loopme.com", "Valerii Roman" => "valerii.roman@loopme.com" }
  s.platform     = :ios, "12.0"
  s.source = { :git => "https://github.com/loopme/ios-united-sdk.git", :tag => "#{s.version}" }
  s.resource = 'LoopMeUnitedSDK.embeddedframework/LoopMeResources.bundle'
  s.vendored_frameworks = [
    "LoopMeUnitedSDK.embeddedframework/LoopMeUnitedSDK.xcframework",
    "framework/LoopMeUnitedSDK/Core/Viewability/OMSDK/OMSDKswift/OMSDK_Loopme.xcframework"
  ]
  s.library   = "xml2"
  s.requires_arc = true
  s.xcconfig = { "OTHER_LDFLAGS" => "-ObjC" " -lz"}
  s.pod_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
  s.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }

end
