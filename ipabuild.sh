WORKING_LOCATION="$(pwd)"
APPLICATION_NAME=TrollTools
HELPER_EXEC_NAME=RootHelper
CONFIGURATION=Debug

# If the folder 'build' does not exist, create it
if [ ! -d "build" ]; then
    mkdir build
fi

cd build

# remove already built tipa if present
if [ -e "$APPLICATION_NAME.tipa" ]; then
rm $APPLICATION_NAME.tipa
fi


DD_BUILD_PATH=$WORKING_LOCATION/build/DerivedData/Build/Products/$CONFIGURATION-iphoneos
TARGET_APP="build/$APPLICATION_NAME.app"

# Build .app
xcodebuild -project $WORKING_LOCATION/$APPLICATION_NAME.xcodeproj \
    -scheme $APPLICATION_NAME \
    -configuration $CONFIGURATION \
    -derivedDataPath $WORKING_LOCATION/build/DerivedData \
    -destination 'generic/platform=iOS' \
    ONLY_ACTIVE_ARCH="NO" \
    CODE_SIGNING_ALLOWED="NO" 
    
cp -r $DD_BUILD_PATH/$APPLICATION_NAME.app $WORKING_LOCATION/$TARGET_APP

cd $WORKING_LOCATION/$HELPER_EXEC_NAME
make clean
make
cp $WORKING_LOCATION/RootHelper/.theos/obj/debug/trolltoolsroothelper $WORKING_LOCATION/$TARGET_APP/$HELPER_EXEC_NAME
cd -


# Remove signature
codesign --remove "$TARGET_APP"
if [ -e "$TARGET_APP/_CodeSignature" ]; then
    rm -rf "$TARGET_APP/_CodeSignature"
fi
if [ -e "$TARGET_APP/embedded.mobileprovision" ]; then
    rm -rf "$TARGET_APP/embedded.mobileprovision"
fi


# Add entitlements
echo Adding entitlements $WORKING_LOCATION/$TARGET_APP/$APPLICATION_NAME
ldid -S$WORKING_LOCATION/entitlements.plist $WORKING_LOCATION/$TARGET_APP/$APPLICATION_NAME
echo Adding entitlements $WORKING_LOCATION/$TARGET_APP/$HELPER_EXEC_NAME
ldid -S$WORKING_LOCATION/entitlements.plist $WORKING_LOCATION/$TARGET_APP/$HELPER_EXEC_NAME

# Package .ipa
rm -rf Payload
mkdir Payload
cp -r $APPLICATION_NAME.app Payload/$APPLICATION_NAME.app

# Zip the Payload and rename
zip -vr $APPLICATION_NAME.tipa Payload

# Cleanup
rm -rf $APPLICATION_NAME.app
rm -rf $HELPER_EXEC_NAME
rm -rf Payload