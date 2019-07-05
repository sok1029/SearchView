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

class SearchedThing: Object{
    @objc dynamic var word = blankString
}

class ViewController: UIViewController {
    let disposeBag = DisposeBag()
    var searchedWords: [String]?
    
    @IBOutlet weak var searchBarTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        // Do any additional setup after loading the view.
    }

    func configure(){
        setSearchBarEventHandler()
    }
    
    private func setSearchBarEventHandler(){
        searchBarTextField.rx.controlEvent([.editingDidBegin,.editingChanged])
            .withLatestFrom(searchBarTextField.rx.text.orEmpty)
            .subscribe(onNext: { [unowned self]  (text) in
                self.loadSearchedWords(input: text)
                self.showSearchHistory()
            })
            .disposed(by: disposeBag)
        
        searchBarTextField.rx.controlEvent([.editingDidEnd])
            .withLatestFrom(searchBarTextField.rx.text.orEmpty)
            .subscribe(onNext: { [unowned self]  (text) in
                self.hideSearchHistory()
            })
            .disposed(by: disposeBag)
    }
    
    private func loadSearchedWords(input: String) {
        let maximumLoad = 5
        self.searchedWords = nil
        //when blankstring in textfield , show 5 searched words
        if input.trimmingCharacters(in: .whitespaces) == blankString{
            let searchedThings = try! Realm().objects(SearchedThing.self)
            if searchedThings.count > 0{
                var searched5Words = [String]()
                for searchedThing in searchedThings.reversed(){ //lately
                    let word = searchedThing.word
                    searched5Words.append(word)
                    if searched5Words.count == maximumLoad{ break}
                }
                self.searchedWords = searched5Words
            }
        }
        //when inputstring in textfield, show predicate word with input
        else{
            
        }
    }
    
    private func showSearchHistory(){
        if let searchedWords = self.searchedWords{
            for word in searchedWords{
                print(word)
            }
        }
    }
    
    private func hideSearchHistory(){
        if let _ = self.searchedWords{
            
        }
    }

    @IBAction func btnTouched(_ sender: Any) {
       saveSearchedWord()
    }
    
    private func saveSearchedWord(){
        if let text = searchBarTextField.text, text.count > 0{
            let searchedThing = SearchedThing(value: ["word" : searchBarTextField.text])
            
            let realm = try! Realm()
            try! realm.write {
                realm.add(searchedThing)
            }
        }
    }
}

