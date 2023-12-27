#!/bin/bash
export CONFIGURATION=Release
export SCHEME=ISLoopMeCustomAdapter
export BUILD_DIR=./${SCHEME}.embeddedframework
export ARCHIVE_SIM=${BUILD_DIR}/${SCHEME}.framework-iphonesimulator.xcarchive
export ARCHIVE_IOS=${BUILD_DIR}/${SCHEME}.framework-iphoneos.xcarchive

echo "Clear build dir"
rm -rf $BUILD_DIR

set -e
echo "try to build iOS"

xcodebuild archive \
    -scheme $SCHEME \
    -configuration $CONFIGURATION \
    -destination 'generic/platform=iOS' \
    -archivePath $ARCHIVE_IOS \
    SKIP_INSTALL=NO \
    EXCLUDED_ARCHS="" \
    BUILD_LIBRARIES_FOR_DISTRIBUTION=YES

echo "try to build iOS Simulator"
xcodebuild archive \
    -scheme $SCHEME \
    -configuration $CONFIGURATION \
    -destination 'generic/platform=iOS Simulator' \
    -archivePath $ARCHIVE_SIM \
    EXCLUDED_ARCHS=arm64 \
    SKIP_INSTALL=NO \
    BUILD_LIBRARIES_FOR_DISTRIBUTION=YES

xcodebuild -create-xcframework \
    -framework "${ARCHIVE_SIM}/Products/Library/Frameworks/${SCHEME}.framework" \
    -framework "${ARCHIVE_IOS}/Products/Library/Frameworks/${SCHEME}.framework" \
    -output "${BUILD_DIR}/${SCHEME}.xcframework"

echo "build is finished"
