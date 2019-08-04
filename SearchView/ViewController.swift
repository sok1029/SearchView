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
    @IBOutlet weak var searchView: SearchView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //by frame init
        //        let textFieldView = SearchTextFieldView.init(frame: CGRect(x: 50, y: 50, width: 250, height: 100))
        //        self.view.addSubview(textFieldView)
        
        searchView.customActWhenRun = {
            //input Your act when running
            print("doSomethingInViewController")
        }
    }
}

