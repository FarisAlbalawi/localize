//
//  LanguageManager.swift
//  localize
//
//  Created by Faris Albalawi on 6/28/20.
//  Copyright © 2020 Faris Albalawi. All rights reserved.
//

import UIKit


// MARK: - Languages

public enum Languages: String {
  case ar,en,nl,ja,ko,vi,ru,sv,fr,es,pt,it,de,da,fi,nb,tr,el,id,
  ms,th,hi,hu,pl,cs,sk,uk,hr,ca,ro,he,ur,fa,ku,arc,sl,ml,am
  case enGB = "en-GB"
  case enAU = "en-AU"
  case enCA = "en-CA"
  case enIN = "en-IN"
  case frCA = "fr-CA"
  case esMX = "es-MX"
  case ptBR = "pt-BR"
  case zhHans = "zh-Hans"
  case zhHant = "zh-Hant"
  case zhHK = "zh-HK"
  case es419 = "es-419"
  case ptPT = "pt-PT"
}

public class LanguageManager {

  public typealias Animation = ((UIView) -> Void)
  public typealias ViewControllerFactory = ((String?) -> UIViewController)
  public typealias WindowAndTitle = (UIWindow?, String?)

    
  public static let shared: LanguageManager = LanguageManager()

  public var currentLanguage: Languages {
    get {
       let currentLang = getLanguage()
       return Languages(rawValue: currentLang)!
    }
    set {
      UserDefaults.standard.set([newValue.rawValue], forKey: "AppleLanguages")
      UserDefaults.standard.synchronize()
    }
  }


  /// The diriction of the language.
  public var isRightToLeft: Bool {
    get {
      return isLanguageRightToLeft(language: currentLanguage)
    }
  }

  /// The app locale to use it in dates and currency.
  public var appLocale: Locale {
    get {
      return Locale(identifier: currentLanguage.rawValue)
    }
  }

  public func setLanguage(language: Languages,
                          for windows: [WindowAndTitle]? = nil,
                          viewControllerFactory: ViewControllerFactory? = nil,
                          animation: Animation? = nil) {

    changeCurrentLanguageTo(language)

    guard let viewControllerFactory = viewControllerFactory else {
      return
    }

    let windowsToChange = getWindowsToChangeFrom(windows)

    windowsToChange?.forEach({ windowAndTitle in
      let (window, title) = windowAndTitle
      let viewController = viewControllerFactory(title)
      changeViewController(for: window,
                           rootViewController: viewController,
                           animation: animation)
    })

  }

  private func changeCurrentLanguageTo(_ language: Languages) {
    // change the dircation of the views
    let semanticContentAttribute: UISemanticContentAttribute = isLanguageRightToLeft(language: language) ? .forceRightToLeft : .forceLeftToRight
    UIView.appearance().semanticContentAttribute = semanticContentAttribute

    // set current language
    currentLanguage = language

  }
     func getLanguage() -> String {
        let appleLanguages = UserDefaults.standard.object(forKey: "AppleLanguages") as! [String]
        let prefferedLanguage = appleLanguages[0]
        if prefferedLanguage.contains("-") {
            let array = prefferedLanguage.components(separatedBy: "-")
            return array[0]
        }
        return prefferedLanguage
    }
    

  private func getWindowsToChangeFrom(_ windows: [WindowAndTitle]?) -> [WindowAndTitle]? {
    var windowsToChange: [WindowAndTitle]?
    if let windows = windows {
      windowsToChange = windows
    } else {
      windowsToChange = UIApplication.shared.connectedScenes
        .compactMap({$0 as? UIWindowScene})
        .map({ ($0.windows.first, $0.title) })
    }

    return windowsToChange
  }

  private func changeViewController(for window: UIWindow?,
                                    rootViewController: UIViewController,
                                    animation: Animation? = nil) {
    guard let snapshot = window?.snapshotView(afterScreenUpdates: true) else {
      return
    }
    rootViewController.view.addSubview(snapshot);

    window?.rootViewController = rootViewController

    UIView.animate(withDuration: 0.5, animations: {
      animation?(snapshot)
    }) { _ in
      snapshot.removeFromSuperview()
    }
  }

  private func isLanguageRightToLeft(language: Languages) -> Bool {
    return Locale.characterDirection(forLanguage: language.rawValue) == .rightToLeft
  }

}



// MARK: - Swizzling

fileprivate extension UIView {
  static func localize() {

    let orginalSelector = #selector(awakeFromNib)
    let swizzledSelector = #selector(swizzledAwakeFromNib)

    let orginalMethod = class_getInstanceMethod(self, orginalSelector)
    let swizzledMethod = class_getInstanceMethod(self, swizzledSelector)

    let didAddMethod = class_addMethod(self, orginalSelector, method_getImplementation(swizzledMethod!), method_getTypeEncoding(swizzledMethod!))

    if didAddMethod {
      class_replaceMethod(self, swizzledSelector, method_getImplementation(orginalMethod!), method_getTypeEncoding(orginalMethod!))
    } else {
      method_exchangeImplementations(orginalMethod!, swizzledMethod!)
    }

  }

  @objc func swizzledAwakeFromNib() {
    swizzledAwakeFromNib()

    switch self {
    case let txtf as UITextField:
      txtf.text = txtf.text?.localiz()
      txtf.placeholder = txtf.placeholder?.localiz()
    case let lbl as UILabel:
      lbl.text = lbl.text?.localiz()
    case let tabbar as UITabBar:
      tabbar.items?.forEach({ $0.title = $0.title?.localiz() })
    case let btn as UIButton:
      btn.setTitle(btn.title(for: .normal)?.localiz(), for: .normal)
    case let sgmnt as UISegmentedControl:
      (0 ..< sgmnt.numberOfSegments).forEach { sgmnt.setTitle(sgmnt.titleForSegment(at: $0)?.localiz(), forSegmentAt: $0) }
    case let txtv as UITextView:
      txtv.text = txtv.text?.localiz()
    default:
      break
    }
  }
}

// MARK: - String extension

public extension String {
  func localiz(comment: String = "") -> String {
    guard let bundle = Bundle.main.path(forResource: LanguageManager.shared.currentLanguage.rawValue, ofType: "lproj") else {
      return NSLocalizedString(self, comment: comment)
    }

    let langBundle = Bundle(path: bundle)
    return NSLocalizedString(self, tableName: nil, bundle: langBundle!, comment: comment)
  }

}

// MARK: - ImageDirection

public enum ImageDirection: Int {
  case fixed, leftToRight, rightToLeft
}

private extension UIView {

  var direction: ImageDirection {
    set {
      switch newValue {
      case .fixed:
        break
      case .leftToRight where LanguageManager.shared.isRightToLeft:
        transform = CGAffineTransform(scaleX: -1, y: 1)
      case .rightToLeft where !LanguageManager.shared.isRightToLeft:
        transform = CGAffineTransform(scaleX: -1, y: 1)
      default:
        break
      }
    }
    get {
      fatalError("There is no value return from this variable, this variable used to change the image direction depending on the langauge")
    }
  }
}

@IBDesignable
public extension UIImageView {
  @IBInspectable var imageDirection: Int {
    set {
      direction = ImageDirection(rawValue: newValue)!
    }
    get {
      return direction.rawValue
    }
  }
}

@IBDesignable
public extension UIButton {
  @IBInspectable var imageDirection: Int {
    set {
      direction = ImageDirection(rawValue: newValue)!
    }
    get {
      return direction.rawValue
    }
  }
}

