echo "Cleaning up..."
rm -rf *.xcworkspace
rm -rf *.xcodeproj
rm -rf Pods
[ -e Podfile.lock ] && rm Podfile.lock
[ -e Podfile ] && rm Podfile
echo "Cleaning up done!"

echo "Generating Xcode project files..."
echo "- LoopMeUnitedSDK ..."
xcodegen generate --spec LoopMeUnitedSDK.yml
echo "- IronSource ..."
xcodegen generate --spec IronSource.yml
echo "- AppLovin ..."
xcodegen generate --spec AppLovin.yml
echo "Generating Xcode project files done!"

echo "Installing pods..."
cp Podfile.development Podfile
pod install
echo "Installing pods done!"

echo "Job is done!"
open Development.xcworkspace