#!/bin/bash

# идём в директорию скрипта
CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "${CURRENT_DIR}"

# вводим то же имя, которое в настройах проекта выбрано в Build Settings в разделе Code Signing Identity
CODE_SIGN_IDENTITY="iPhone Distribution: Anatoly Mityaev (635Y86FJPH)"
#CODE_SIGN_IDENTITY="Automatic"

# имя provision profile, которое в настройках проекта
PROVISION="16267b4d-93d3-4ae4-ab27-2c39e379367d"
#PROVISION="Automatic"

# схема, которую собираем
SCHEME="click"
WORKSPACE="$PWD/../Click.xcworkspace"
PBXPROJ="$PWD/../click.xcodeproj"
PLIST="$PWD/../Info.plist"
CRASHLITICS=${CURRENT_DIR}/"../Pods/Crashlytics/submit"
IPA="$PWD/${SCHEME}_$(date +"%d.%m.%Y").ipa"

echo "`basename "$0"`:"
echo "	SCHEME="${SCHEME}
echo "	WORKSPACE="${WORKSPACE}
echo "	XCODEPROJ="${PBXPROJ}
echo "	CRASHLITICS"=${CRASHLITICS}
echo "	IPA"=${IPA}

echo "Building..."

BUILDDIR="$PWD/build"
DSYMDIR="$PWD/dSYM"

if [ ! -d "$BUILDDIR" ]; then
    mkdir -p "$BUILDDIR"
fi

if [ ! -d "$DSYMDIR" ]; then
    mkdir -p "$DSYMDIR"
fi

xcodebuild -workspace "${WORKSPACE}" -scheme "${SCHEME}" -sdk iphoneos -configuration Release CODE_SIGN_IDENTITY="${CODE_SIGN_IDENTITY}" PROVISIONING_PROFILE="${PROVISION}"  OBJROOT=$BUILDDIR SYMROOT=$BUILDDIR clean build
if [ $? != 0 ]; then
    echo "Build failed"
    exit 1
fi

#xcrun -sdk iphoneos PackageApplication -v "${BUILDDIR}/Release-iphoneos/${SCHEME}.app" -o ${IPA}
mkdir ./Payload
cp -R "${BUILDDIR}/Release-iphoneos/${SCHEME}.app" ./Payload
zip -qyr ${IPA} ./Payload
rm -r ./Payload
if [ $? != 0 ]; then
    echo "Packaging failed"
    exit 2
fi

now=$(date +"%d_%m_%Y_%H_%M_%S")
mv "${BUILDDIR}/Release-iphoneos/${SCHEME}.app.dSYM" "${DSYMDIR}/${SCHEME}_$now.app.dSYM"

echo "Build succeeded."
echo

echo "Upload crashlitics..."
#~/Desktop/Crashlytics.framework/submit c9bd20c314c289d97a53b9958f791b63aa2f4b7d 63b2f94f76f4a065ae5d25888c0583e7a5de612d798b8afd2e8598302f7b5a7b -ipaPath ${IPA} -notifications YES
${CRASHLITICS} c9bd20c314c289d97a53b9958f791b63aa2f4b7d 63b2f94f76f4a065ae5d25888c0583e7a5de612d798b8afd2e8598302f7b5a7b -ipaPath ${IPA} -notifications YES

echo "Upload succeeded."
echo