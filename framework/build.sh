#!/bin/bash
set -e

current_branch=$(git rev-parse --abbrev-ref HEAD)
if [ "$current_branch" != "master" ]; then
    echo "Error: You are not on master branch. Please switch to master branch before running this script."
    exit 1
fi

if ! git diff-index --quiet HEAD --; then
    echo "Error: You have uncommitted changes. Please commit or stash them before running this script."
    exit 1
fi

upstream=$(git for-each-ref --format='%(upstream:short)' $(git symbolic-ref -q HEAD))

local_commits=$(git rev-list @.."$upstream")
if [ -n "$local_commits" ]; then
    echo "Error: You have unpushed commits. Please push them before running this script."
    exit 1
fi

OLD_VERSION=$(git tag --list '[0-9]*.[0-9]*.[0-9]*' | sort -V | tail -n 1)
VERSION=$(echo $OLD_VERSION | awk -F. '{print $1"."$2"."$3+1}')
echo "MARKETING_VERSION = $VERSION" > version.xcconfig

BUILD_DIR="../LoopMeUnitedSDK.embeddedframework"
ARCHIVE_IOS="$BUILD_DIR/LoopMeUnitedSDK.framework-iphoneos.xcarchive"
ARCHIVE_SIM="$BUILD_DIR/LoopMeUnitedSDK.framework-iphonesimulator.xcarchive"

echo "Cleaning up"
rm -rf $BUILD_DIR/*

echo "Try to build iOS"
xcodebuild archive \
    -scheme LoopMeUnitedSDK \
    -configuration Release \
    -destination "generic/platform=iOS" \
    -archivePath "$ARCHIVE_IOS" \
    -xcconfig "version.xcconfig" \
    SKIP_INSTALL=NO \
    EXCLUDED_ARCHS="" \
    BUILD_LIBRARIES_FOR_DISTRIBUTION=YES > ios.log

echo "Try to build iOS Simulator"
xcodebuild archive \
    -scheme LoopMeUnitedSDK \
    -configuration Release \
    -destination "generic/platform=iOS Simulator" \
    -archivePath "$ARCHIVE_SIM" \
    -xcconfig "version.xcconfig" \
    EXCLUDED_ARCHS=arm64 \
    SKIP_INSTALL=NO \
    BUILD_LIBRARIES_FOR_DISTRIBUTION=YES > sim.log

xcodebuild -create-xcframework \
    -framework "$ARCHIVE_SIM/Products/Library/Frameworks/LoopMeUnitedSDK.framework" \
    -framework "$ARCHIVE_IOS/Products/Library/Frameworks/LoopMeUnitedSDK.framework" \
    -output "$BUILD_DIR/LoopMeUnitedSDK.xcframework"

echo "Copy LoopMeResources.bundle"
cp -r ./LoopMeUnitedSDK/LoopMeResources.bundle $BUILD_DIR/LoopMeResources.bundle

echo "Cleaning up - removing archives"
rm -rf $ARCHIVE_SIM
rm -rf $ARCHIVE_IOS
# Removeing temp files
rm version.xcconfig
rm ios.log
rm sim.log

echo "Updating podspec"
sed -i '' "s/s.version      = \"$OLD_VERSION\"/s.version      = \"$VERSION\"/" ../LoopMeUnitedSDK.podspec 

echo "Update CHANGELOG.md"
CHANGE_LOG=$(git log $OLD_VERSION..master --no-merges --pretty=format:"- %s" | grep -v "^- Revert")
git log $OLD_VERSION..master --no-merges --pretty=format:"- %s" | grep -v "^- Revert" > temp_changelog
current_date=$(date "+%d.%m.%Y")
echo "## Version $VERSION ($current_date)" > new_changelog
echo "" >> new_changelog
cat temp_changelog >> new_changelog
echo "" >> new_changelog
cat ../CHANGELOG.md >> new_changelog
mv new_changelog ../CHANGELOG.md
rm temp_changelog

echo "Update README.md"
echo "You can find integration guide on [wiki](https://loopme-ltd.gitbook.io/docs-public/loopme-ios-sdk) page.

## What's new ##

**Version $VERSION**

$CHANGE_LOG

Please view the [changelog](CHANGELOG.md) for details.

## License ##

see [License](LICENSE.md)" > ../README.md

GREEN='\033[0;32m'
NO_COLOR='\033[0m' # No Color

echo -e "Build is finished.

Old version: $GREEN$OLD_VERSION$NO_COLOR, new version: $GREEN$VERSION$NO_COLOR.

$GREEN Please commit and push changes. $NO_COLOR

git add .
git commit -m \"Release Version of LoopMeUnitedSDK: $VERSION\"
git push origin master

$GREEN Crate a tag for new version. $NO_COLOR

git tag $VERSION
git push origin --tags

$GREEN Publish new version to CocoaPods. $NO_COLOR

pod trunk push LoopMeUnitedSDK.podspec
"

read -p "I can do this work for you. ARE YOU AGREE (Y/N): " answer
answer=$(echo "$answer" | tr '[:lower:]' '[:upper:]')

if [ "$answer" == "Y" ]; then
    cd ..
    git add .
    git commit -m "Release Version of LoopMeUnitedSDK: $VERSION"
    git push origin master
    git tag $VERSION
    git push origin --tags
    pod trunk push LoopMeUnitedSDK.podspec
    echo "All work is done. Thank you!"
else
    echo "You can do it by yourself. Thank you!"
fi