//
//  ViewController.swift
//  SearchBar
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
    @IBOutlet weak var searchTextFieldView: SearchTextFieldView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //by frame init
        //        let textFieldView = SearchTextFieldView.init(frame: CGRect(x: 50, y: 50, width: 250, height: 100))
        //        self.view.addSubview(textFieldView)
        setTextFieldViewButtonEventHandler()
    }
    
    private func setTextFieldViewButtonEventHandler(){
        searchTextFieldView.runButton.rx.controlEvent([.touchUpInside])
            .subscribe(onNext: { [unowned self]  (text) in
                print("doSomethingInViewController")
            })
            .disposed(by: disposeBag)
    }
    func configure(){
//      searchTextFieldView.commonInit()

    }

}

