//
//  ViewController.swift
//  SearchView
//
//  Created by SokJinYoung on 04/07/2019.
//  Copyright © 2019 Stone. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RealmSwift

class ViewController: UIViewController {
    let disposeBag = DisposeBag()
    let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView.init()
        indicator.style = .whiteLarge
        indicator.color = .blue
        indicator.hidesWhenStopped = true
        return indicator
    }()

    @IBOutlet weak var searchView: SearchView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //by frame init
        //        let textFieldView = SearchTextFieldView.init(frame: CGRect(x: 50, y: 50, width: 250, height: 100))
        //        self.view.addSubview(textFieldView)
        
        activityIndicator.center = self.view.center
        self.view.addSubview(activityIndicator)
      
        searchView.actWhenRun = {[weak self] in
            //input Your act when running
            self?.activityIndicator.startAnimating()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {[weak self] in
                self?.activityIndicator.stopAnimating()
            }
        }
    }
}

