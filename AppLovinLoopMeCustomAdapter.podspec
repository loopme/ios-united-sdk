#  Be sure to run `pod spec lint AppLovinLoopMeCustomAdapter.podspec'
Pod::Spec.new do |spec|
    spec.name         = "AppLovinLoopMeCustomAdapter"
    spec.version      = "0.0.10"
    spec.summary      = "LoopMe AppLovin Custom Adapter (ApplovinLoopMeCustomAdapter)"

    spec.description  = "LoopMe AppLovin Custom Adapter builded to use LoopMe SDK with AppLovin SDK through AppLovin Mediation."

    spec.homepage     = "https://github.com/loopme/ios-united-sdk"

    spec.author             = { "Evgen A. Epanchin" => "EpanchinE@gmail.com", "Valerii Roman" => "valerii.roman@loopme.com"  }
    spec.license            = { :type => "BSD", :file => "./LICENSE.md" }

    spec.platform = :ios, "12.0"

    spec.source       = { :git => "https://github.com/loopme/ios-united-sdk.git", :tag => "AppLovinLoopMeCustomAdapter_#{spec.version}" }

    spec.static_framework = true
    spec.source_files  = "Mediation/AppLovin/AppLovinLoopMeCustomAdapter/*.{h,m}"
    spec.dependency "AppLovinSDK"
    spec.dependency "LoopMeUnitedSDK", "7.4.22"
    spec.requires_arc = true
    spec.pod_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
    spec.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }

  end
