# StaffMonitor

A Flutter application.

## Project organisation
* Set default line length for dart files to 100
* Preferably use [FVM](https://fvm.app/) or match your used Flutter SDK with selected version in .fvm/fvm_config.json


## Development
* Run code generator watcher
`fvm flutter pub run build_runner watch`   
* Run code generator once   
`fvm flutter pub run build_runner build --delete-conflicting-outputs`   

You can prefill sing in form by adding run arguments
`--dart-define=user="[user name]" --dart-define=password="[password]"` 

You can always use gps tracking on active session with this run argument
`--dart-define=always_track_gps=true`

## Build commands

### Production
* AppBundle   
`fvm flutter build appbundle --no-shrink --obfuscate --split-debug-info="..."`

* Apk   
`fvm flutter build apk --obfuscate --split-debug-info="..."`

Run in "../build/app/intermediates/stripped_native_libs/prodRelease/out/lib"
`zip -r symbols.zip .`

### Dev Debug

* Apk   
`fvm flutter build apk --debug -t lib/main.dart`
