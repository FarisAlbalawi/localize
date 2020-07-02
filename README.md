# localize

## Features 
-  Supports All languages 
-  Flipping the app from left to right if the language Arabic
-  Change the language inside of the app
-  Change the language from setting
-  Swift 5

## Usage

### import LanguageManager file
Add the LanguageManager.swift in your project 

### localized string file
Add `Localizable.strings` for a Language 
```string
"Welcome" = "مرحباً بك";
```
### localiz
```swift
let yourString = "Welcome".localiz()
```

### change the language inside of the app 

```swift
LanguageManager.shared.setLanguage(language: .ar,viewControllerFactory: { title -> UIViewController in
      // set the view controller that you want to show after changing the language
     return ViewController()
    }) { view in
       view.transform = CGAffineTransform(scaleX: 1, y: 1)
      view.alpha = 0
    }
               
```

## Author

Faris Albalawi,
FA.FarisAlbalawi@gmail.com

## Reference
[Here](http://47.107.33.27/ios/kaisafinstockswift/blob/19eca7c82901112f29b9bea91b414ffd083aff2e/KaisafinStockSwift/Config/KSLanguageManager.swift).
