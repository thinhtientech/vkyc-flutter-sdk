# call_video

## Getting Started

* Get some basic and advanced examples from the [example](example/lib) folder.

### Privacy Permission

Call Video SDK requires `Camera` and `Microphone` permission to start a video call.

#### Android

See the required device permissions from
the [AndroidManifest.xml](android/src/main/AndroidManifest.xml) file.

```xml

<manifest>
  ...
  <uses-permission android:name="android.permission.READ_PHONE_STATE" />
    <uses-permission android:name="android.permission.NFC" />
  <uses-permission android:name="android.permission.INTERNET" />
  <uses-permission android:name="android.permission.RECORD_AUDIO" />
  <uses-permission android:name="android.permission.CAMERA" />
  <uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS" />
  <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
  <uses-permission android:name="android.permission.BLUETOOTH" />
  <uses-permission android:name="android.permission.ACCESS_WIFI_STATE" />
  <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
  <uses-permission android:name="android.permission.WAKE_LOCK" />
  <uses-permission android:name="android.permission.READ_PRIVILEGED_PHONE_STATE"
    tools:ignore="ProtectedPermissions" />
  ...
</manifest>
```

Change the minimum Android sdk version to 26 (or higher) in your `android/app/build.gradle` file.

```groovy
minSdkVersion 26
```

#### iOS

Open the `Info.plist` and add:

- `Privacy - Microphone Usage Description`，and add some description into the `Value` column.
- `Privacy - Camera Usage Description`, and add some description into the `Value` column.
- `Privacy - NFCReaderUsageDescription`, and add some description into the `Value` column.

- Add [com.apple.developer.nfc.readersession.iso7816.select-identifiers](https://developer.apple.com/documentation/bundleresources/information_property_list/select-identifiers) and value key:

```xml
    <array>
    <string>A0000002471001</string>
    <string>A0000002472001</string>
    <string>00000000000000</string>
    </array>
```

## How to contribute

To help work on this sdk, please refer to [CONTRIBUTING.md](CONTRIBUTING.md).

## License

The project is under the MIT license.