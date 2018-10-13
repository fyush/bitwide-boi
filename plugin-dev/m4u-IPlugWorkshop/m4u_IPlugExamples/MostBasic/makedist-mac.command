#! /bin/sh

BASEDIR=$(dirname $0)

cd $BASEDIR

VERSION=`echo | grep PLUG_VER resource.h`
VERSION=${VERSION//\#define PLUG_VER }
VERSION=${VERSION//\'}
MAJOR_VERSION=$(($VERSION & 0xFFFF0000))
MAJOR_VERSION=$(($MAJOR_VERSION >> 16)) 
MINOR_VERSION=$(($VERSION & 0x0000FF00))
MINOR_VERSION=$(($MINOR_VERSION >> 8)) 
BUG_FIX=$(($VERSION & 0x000000FF))

FULL_VERSION=$MAJOR_VERSION"."$MINOR_VERSION"."$BUG_FIX

VST2="/Library/Audio/Plug-Ins/VST/MostBasic.vst"
VST3="/Library/Audio/Plug-Ins/VST3/MostBasic.vst3"
APP="/Applications/MostBasic.app"
AUDIOUNIT="/Library/Audio/Plug-Ins/Components/MostBasic.component"
RTAS="/Library/Application Support/Digidesign/Plug-Ins/MostBasic.dpm"

echo "making MostBasic version $FULL_VERSION mac distribution..."
echo ""

./update_version.py

#could use touch to force a rebuild
#touch blah.h

#remove existing dist folder
#if [ -d installer/dist ] 
#then
#  rm -R installer/dist
#fi

#mkdir installer/dist

#remove existing App
if [ -d $APP ] 
then
  sudo rm -R -f $APP
fi

#remove existing AU
if [ -d $AUDIOUNIT ] 
then
  sudo rm -R $AUDIOUNIT
fi

#remove existing VST2
if [ -d $VST2 ] 
then
  sudo rm -R $VST2
fi

#remove existing VST3
if [ -d $VST3 ] 
then
  rm -R $VST3
fi


#remove existing RTAS
if [ -d "${RTAS}" ] 
then
  sudo rm -R "${RTAS}"
fi

xcodebuild -project MostBasic.xcodeproj -xcconfig MostBasic.xcconfig -target "All" -configuration Release
#xcodebuild -project MostBasic-ios.xcodeproj -xcconfig MostBasic.xcconfig -target "IOSAPP" -configuration Release

#icon stuff - http://maxao.free.fr/telechargements/setfileicon.gz
echo "setting icons"
echo ""
setfileicon resources/MostBasic.icns $AUDIOUNIT
setfileicon resources/MostBasic.icns $VST2
setfileicon resources/MostBasic.icns $VST3
setfileicon resources/MostBasic.icns "${RTAS}"

#appstore stuff

# echo "code signing app"
# echo ""
# codesign -f -s "3rd Party Mac Developer Application: Oliver Larkin" $APP
#  
# echo "building pkg for app store"
# productbuild \
#      --component $APP /Applications \
#      --sign "3rd Party Mac Developer Installer: Oliver Larkin" \
#      --product "/Applications/MostBasic.app/Contents/Info.plist" installer/MostBasic.pkg

# installer, uses iceberg http://s.sudre.free.fr/Software/Iceberg.html

sudo sudo rm -R -f installer/MostBasic-mac.dmg

echo "building installer"
echo ""
freeze installer/MostBasic.packproj

# dmg, uses dmgcanvas http://www.araelium.com/dmgcanvas/

echo "building dmg"
echo ""

if [ -d installer/MostBasic.dmgCanvas ]
then
  dmgcanvas installer/MostBasic.dmgCanvas installer/MostBasic-mac.dmg
else
  hdiutil create installer/MostBasic.dmg -srcfolder installer/build-mac/ -ov -anyowners -volname MostBasic
  
  if [ -f installer/MostBasic-mac.dmg ]
  then
   rm -f installer/MostBasic-mac.dmg
  fi
  
  hdiutil convert installer/MostBasic.dmg -format UDZO -o installer/MostBasic-mac.dmg
  sudo sudo rm -R -f installer/MostBasic.dmg
fi

sudo sudo rm -R -f installer/build-mac/

# echo "copying binaries..."
# echo ""
# cp -R $AUDIOUNIT installer/dist/MostBasic.component
# cp -R $VST2 installer/dist/MostBasic.vst
# cp -R $VST3 installer/dist/MostBasic.vst3
# cp -R $RTAS installer/dist/MostBasic.dpm
# cp -R $APP installer/dist/MostBasic.app
# 
# echo "zipping binaries..."
# echo ""
# ditto -c -k installer/dist installer/MostBasic-mac.zip
# rm -R installer/dist

echo "done"