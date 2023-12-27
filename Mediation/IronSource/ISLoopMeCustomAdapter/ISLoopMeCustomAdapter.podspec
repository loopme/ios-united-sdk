#  Be sure to run `pod spec lint ISLoopMeCustomAdapter.podspec'
Pod::Spec.new do |spec|
    spec.name         = "ISLoopMeCustomAdapter"
    spec.version      = "0.0.1"
    spec.summary      = "LoopMe IronSource Custom Adapter (ISLoopMeCustomAdapter)"
  
    spec.description  = "LoopMe IronSource Custom Adapter builded to use LoopMe SDK with IronSource SDK through IronSource Mediation."
  
    spec.homepage     = "https://github.com/loopme/ios-united-sdk"
  
    spec.author             = { "Evgen A. Epanchin" => "EpanchinE@gmail.com", "Valerii Roman" => "valeriiroman@loopme.com"  }
    spec.license            = { :type => "BSD", :file => "../../../LICENSE.md" }

    spec.platform = :ios, "12.0"
  
    spec.source       = { :git => "https://github.com/loopme/ios-united-sdk.git", :tag => "ISLoopMeCustomAdapter_#{spec.version}" }
  
    spec.source_files  = "*.{h,m}"
    spec.dependency "IronSourceSDK"
    spec.dependency "LoopMeUnitedSDK"
    spec.vendored_frameworks = "ISLoopMeCustomAdapter.embeddedframework/ISLoopMeCustomAdapter.xcframework"
  end
