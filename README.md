iOS SampleProject for the [thing-if SDK](https://github.com/KiiPlatform/thing-if-iOSSDK)

# Requirements

- iOS 9.0+
- Xcode 7.0+
- swift 2.0+

# Import ThingIFSDK.framework

You can use one of the following ways to get an ThingIFSDK.framework:

## Use Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that automates the process of adding frameworks to your Cocoa application.

- Install Carthage with [Homebrew](http://brew.sh/) using the following command:

  ```bash
  $ brew update
  $ brew install carthage
  ```

- Specify thing-if SDK it in your `Cartfile`:

  ```ogdl
  github "KiiPlatform/thing-if-iOSSDK" >= 0.8
  ```
- Then generate thing-if SDK framework by the following command:
  ```bash
  $ carthage update
  ```
- After successfully generated thing-if SDK framework, import it to SampleProject.


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

Both of KiiSDK and thing-if SDK need the same appID and appKey. Please set the appropriate values in the file `ThingIFSDK/Properties.plist`.

- Initialize KiiSDK in `ThingIFSDK/AppDelegate.swift`
  - If using one of US, JP, CN and SG, please call `Kii.beginWithID((dict["appID"] as! String), andKey: (dict["appKey"] as! String), andSite: KiiSite)` using appropriate value for the site.
  - If using a custom base URL, please provide a value of `kiiCloudCustomURL` for KiiSDK in `ThingIFSDK/Properties.plist`. Then call `Kii.beginWithID((dict["appID"] as! String), andKey: (dict["appKey"] as! String), andCustomURL: (dict["kiiCloudCustomURL"] as! String))`

- Initialize thing-if SDK in  `ThingIFSDK/LoginViewController.swift` when calling `IoTCloudAPIBuilder(appID: (dict["appID"] as! String), appKey: (dict["appKey"] as! String), site: Site, owner: Owner, tag: String? )`
  - If using one of US, JP, CN and SG, please use `Site.US`, `Site.JP`, `Site.CN`, or `Site.SG` for the value of site.
  - If using custom site base URL, please provide a value of `iotCloudAPIBaseURL` for thing-if SDK in `ThingIFSDK/Properties.plist`, then set the value of site with `Site.CUSTOM((dict["iotCloudAPIBaseURL"] as! String))`.

# License

thing-if iOSSample is released under the MIT license. See LICENSE for details.
