#  Be sure to run `pod spec lint ISLoopMeCustomAdapter.podspec'
Pod::Spec.new do |spec|
    spec.name         = "ISLoopMeCustomAdapter"
    spec.version      = "0.0.10"
    spec.summary      = "LoopMe IronSource Custom Adapter (ISLoopMeCustomAdapter)"

    spec.description  = "LoopMe IronSource Custom Adapter builded to use LoopMe SDK with IronSource SDK through IronSource Mediation."

    spec.homepage     = "https://github.com/loopme/ios-united-sdk"

    spec.author             = { "Evgen A. Epanchin" => "EpanchinE@gmail.com", "Valerii Roman" => "valerii.roman@loopme.com"  }
    spec.license            = { :type => "BSD", :file => "./LICENSE.md" }

    spec.platform = :ios, "12.0"
    spec.swift_versions = "5.0"

    spec.source       = { :git => "https://github.com/loopme/ios-united-sdk.git", :tag => "ISLoopMeCustomAdapter_#{spec.version}" }

    spec.static_framework = true
    spec.source_files  = "Mediation/IronSource/ISLoopMeCustomAdapter/*.{h,m}"
    spec.dependency "IronSourceSDK", "~> 8.0"
    spec.dependency "LoopMeUnitedSDK", "7.4.19"
    spec.requires_arc = true
    spec.pod_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
    spec.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }

  end
