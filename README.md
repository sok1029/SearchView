# SearchView
A text field that automatically completes and shows the items you have already retrieved.


<img alt="Demo" src="/resources/demo.GIF?raw=true" width="290">&nbsp;


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
