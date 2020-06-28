//
//  ViewController.swift
//  localize
//
//  Created by Faris Albalawi on 6/28/20.
//  Copyright © 2020 Faris Albalawi. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    
    let lab: UILabel = {
        let lab = UILabel()
        lab.text = "Welcome".localiz()
        lab.textAlignment = .natural
        lab.font = UIFont.systemFont(ofSize: 40, weight: .black)
        lab.textColor = .systemBlue
        lab.translatesAutoresizingMaskIntoConstraints = false
        return lab
    }()
    
    let langButton: UIButton = {
        let butt = UIButton()
        butt.backgroundColor = .systemBlue
        butt.setTitle("Change Language".localiz(), for: .normal)
        butt.setTitleColor(.white, for: .normal)
        butt.layer.cornerRadius = 25
        butt.addTarget(self, action: #selector(changeLang), for: .touchUpInside)
        butt.translatesAutoresizingMaskIntoConstraints = false
        return butt
    }()
    
    let LanguagesLab: UILabel = {
        let lab = UILabel()
        lab.textAlignment = .natural
        lab.font = UIFont.systemFont(ofSize: 20, weight: .black)
        lab.textColor = .systemBlue
        lab.translatesAutoresizingMaskIntoConstraints = false
        return lab
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground
        
        
        self.view.addSubview(lab)
        self.view.addSubview(langButton)
        NSLayoutConstraint.activate([
            self.lab.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor,constant: 30),
            self.lab.trailingAnchor.constraint(equalTo: self.view.trailingAnchor,constant: 10),
            self.lab.leadingAnchor.constraint(equalTo: self.view.leadingAnchor,constant: 10),
            
            
            self.langButton.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor,constant: -10),
            self.langButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.langButton.widthAnchor.constraint(equalToConstant: 200),
            self.langButton.heightAnchor.constraint(equalToConstant: 50)
        
        ])
        
        

        
        print(LanguageManager.shared.currentLanguage)

        
        // Do any additional setup after loading the view.
    }

    
    // MARK: - Change APP Language
    @objc func changeLang() {
        let alert = UIAlertController(title: "Change Language".localiz(),
                                      message: nil,
                                      preferredStyle: .actionSheet)
        
        
        var title = ""
        var setLanguage: Languages!
        if LanguageManager.shared.currentLanguage == .en {
            title = "العربية"
            setLanguage = .ar
        } else if LanguageManager.shared.currentLanguage == .ar {
             title = "English"
            setLanguage = .en
         }
        
        let lan = UIAlertAction(title: title, style: .default, handler: { (action) -> Void in
            LanguageManager.shared.setLanguage(language: setLanguage,
                                                  viewControllerFactory: { title -> UIViewController in
                                                      
    
                 // the view controller that you want to show after changing the language
                 return ViewController()
               }) { view in
                  view.transform = CGAffineTransform(scaleX: 1, y: 1)
                  view.alpha = 0
               }
        
        })
        

        
        let cancel = UIAlertAction(title: "Cancel".localiz(), style: .cancel, handler: { (action) -> Void in })
        alert.addAction(lan)
        alert.addAction(cancel)

        present(alert, animated: true, completion: nil)
    }
        
        

}

