#!/bin/bash
set -e

BUILD_DIR="../LoopMeUnitedSDK.embeddedframework"
ARCHIVE_IOS="$BUILD_DIR/LoopMeUnitedSDK.framework-iphoneos.xcarchive"
ARCHIVE_SIM="$BUILD_DIR/LoopMeUnitedSDK.framework-iphonesimulator.xcarchive"

echo "cleaning up"
rm -rf $BUILD_DIR/*

echo "try to build iOS"
xcodebuild archive \
    -scheme LoopMeUnitedSDK \
    -configuration Release \
    -destination "generic/platform=iOS" \
    -archivePath "$ARCHIVE_IOS" \
    SKIP_INSTALL=NO \
    EXCLUDED_ARCHS="" \
    BUILD_LIBRARIES_FOR_DISTRIBUTION=YES

echo "try to build iOS Simulator"
xcodebuild archive \
    -scheme LoopMeUnitedSDK \
    -configuration Release \
    -destination "generic/platform=iOS Simulator" \
    -archivePath "$ARCHIVE_SIM" \
    EXCLUDED_ARCHS=arm64 \
    SKIP_INSTALL=NO \
    BUILD_LIBRARIES_FOR_DISTRIBUTION=YES

xcodebuild -create-xcframework \
    -framework "$ARCHIVE_SIM/Products/Library/Frameworks/LoopMeUnitedSDK.framework" \
    -framework "$ARCHIVE_IOS/Products/Library/Frameworks/LoopMeUnitedSDK.framework" \
    -output "$BUILD_DIR/LoopMeUnitedSDK.xcframework"

echo "copy LoopMeResources.bundle"
cp -r ./LoopMeUnitedSDK/LoopMeResources.bundle $BUILD_DIR/LoopMeResources.bundle

echo "cleaning up - removing archives"
rm -rf $ARCHIVE_SIM
rm -rf $ARCHIVE_IOS

echo "build is finished"
