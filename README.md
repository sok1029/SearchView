# SearchView
A text field that automatically completes and shows the items you have already retrieved.


<img alt="Demo" src="/resources/demo.GIF?raw=true" width="290">&nbsp;

## Set For Usage

Before using SearchView, let's set the default settings for using Realm.

```swift
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    setDefaultRealmForUser(username: Bundle.main.bundleIdentifier!)
    return true
}

func setDefaultRealmForUser(username: String) {
    //for new property adde
    var config = Realm.Configuration(
    schemaVersion: 1,
    migrationBlock: { migration, oldSchemaVersion in
        if (oldSchemaVersion < 1) {
        // Nothing to do!
        }
    })

    config.fileURL = config.fileURL!.deletingLastPathComponent().appendingPathComponent("\(username).realm")
    // Set this as the configuration used for the default Realm
    Realm.Configuration.defaultConfiguration = config
}

```

## Usage

### Code Usage

```swift
let searchView = SearchView.init(frame: "input your CGRect instance")
self.view.addSubview(searchView)

```

### Storyboadrd Usage

<img alt="Demo" src="/resources/usage.png?raw=true" width="290">&nbsp;

1. Make the UIView on the storyboard
2. Set Custom class to 'SearchView'

### Add Run Act 

```swift
searchView.actWhenRun = {
    // Input your act when running
}

```

## Mechanism

SearchView is designed to perform the same behavior as **Google AutoComplete** except for the list of recommendations through networking with servers

**Google AutoComplete** mechanism

1.  If nothing is entered in the text field and only the cursor is present, all searched items are shown in the latest order.
2.  Each time it is entered in a text field, it is shown by updating the search items in the latest order to match the typed text.


## Requirements

* iOS 11

## Dependencies

* [RxSwift](https://github.com/ReactiveX/RxSwift) >= 5.0
* [RealmSwift](https://github.com/realm/realm-cocoa) 

## Author

sok1029@gmail.com
