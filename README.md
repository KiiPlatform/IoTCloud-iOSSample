iOS SampleProject for the [IoTCloudSDK](https://github.com/KiiPlatform/IoTCloud-iOSSDK)

# Requirements

- iOS 9.0+
- Xcode 7.0+
- swift 2.0+

# Import IoTCloudSDK.framework

You can use one of the following ways to get an IoTCloudSDK.framework:

## Use Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that automates the process of adding frameworks to your Cocoa application.

- Install Carthage with [Homebrew](http://brew.sh/) using the following command:

  ```bash
  $ brew update
  $ brew install carthage
  ```

- Specify IoTCloudSDK it in your `Cartfile`:

  ```ogdl
  github "KiiPlatform/IoTCloud-iOSSDK" >= 0.8
  ```
- Then generate IoTCloudSDK framework by the following command:
  ```bash
  $ carthage update
  ```
- After successfully generated IoTCloudSDK framework, import it to SampleProject.

## Download from Kii Developer Portal

- Download IoTCloudSDK from  [Kii Developer Portal](https://developer.kii.com/v2/downloads)
- Import the downloaded IoTCloudSDK.framework to SampleProject.

# Import KiiSDK.framework

KiiSDK is used to get the access token of KiiUser from Kii Cloud. To include KiiSDK, SampleProject uses [CocoaPods](https://github.com/CocoaPods/CocoaPods).

If CocoaPods is not installed, please install it first by following the [installation Guild](http://guides.cocoapods.org/using/getting-started.html#installation).

The `./Podfile` is used to define latest version of KiiSDK to be imported. Just run the following command:

```bash
$ pod install
```

# Run SampleProject

After above steps finished, open `./SampleProject.xcworkspace`

## Initialize SDKs

Both of KiiSDK and IoTCloudSDK need the same appID and appKey. Please set the appropriate values in the file `IoTCloudSDK/Properties.plist`.

- Initialize KiiSDK in `IoTCloudSDK/AppDelegate.swift`
  - If using one of US, JP, CN and SG, please call `Kii.beginWithID((dict["appID"] as! String), andKey: (dict["appKey"] as! String), andSite: KiiSite)` using appropriate value for the site.
  - If using a custom base URL, please provide a value of `kiiCloudCustomURL` for KiiSDK in `IoTCloudSDK/Properties.plist`. Then call `Kii.beginWithID((dict["appID"] as! String), andKey: (dict["appKey"] as! String), andCustomURL: (dict["kiiCloudCustomURL"] as! String))`

- Initialize IotCloudSDK in  `IoTCloudSDK/LoginViewController.swift` when calling `IoTCloudAPIBuilder(appID: (dict["appID"] as! String), appKey: (dict["appKey"] as! String), site: Site, owner: Owner, tag: String? )`
  - If using one of US, JP, CN and SG, please use `Site.US`, `Site.JP`, `Site.CN`, or `Site.SG` for the value of site.
  - If using custom site base URL, please provide a value of `iotCloudAPIBaseURL` for IoTCloudSDK in `IoTCloudSDK/Properties.plist`, then set the value of site with `Site.CUSTOM((dict["iotCloudAPIBaseURL"] as! String))`.

# License
