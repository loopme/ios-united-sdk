#!/bin/bash
set -e
echo "try to build iOS"
xcodebuild archive \
-scheme LoopMeUnitedSDK \
-configuration Release \
-destination 'generic/platform=iOS' \
-archivePath './build/LoopMeUnitedSDK.framework-iphoneos.xcarchive' \
SKIP_INSTALL=NO \
EXCLUDED_ARCHS=“” \
BUILD_LIBRARIES_FOR_DISTRIBUTION=YES > /dev/null
echo "try to build iOS Simulator"
xcodebuild archive \
-scheme LoopMeUnitedSDK \
-configuration Release \
-destination 'generic/platform=iOS Simulator' \
-archivePath './build/LoopMeUnitedSDK.framework-iphonesimulator.xcarchive' \
EXCLUDED_ARCHS=arm64 \
SKIP_INSTALL=NO \
BUILD_LIBRARIES_FOR_DISTRIBUTION=YES > /dev/null

xcodebuild -create-xcframework \
-framework './build/LoopMeUnitedSDK.framework-iphonesimulator.xcarchive/Products/Library/Frameworks/LoopMeUnitedSDK.framework' \
-framework './build/LoopMeUnitedSDK.framework-iphoneos.xcarchive/Products/Library/Frameworks/LoopMeUnitedSDK.framework' \
-output './build/LoopMeUnitedSDK.xcframework' > /dev/null
echo "build is finished"
