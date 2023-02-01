#!/bin/bash
while getopts ":r:f:" option
do
    case ${option} in
        r) release=${OPTARG};;
        f) flavor=${OPTARG};;
    esac
done

# processing the commands for flutter run
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter pub run flutter_launcher_icons:main -f flutter_launcher_icons*
flutter pub run build_runner build --delete-conflicting-outputs
# flutter analyze
flutter run --$release --flavor $flavor -t lib/flavors/$flavor.dart