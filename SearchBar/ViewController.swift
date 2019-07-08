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
    @objc dynamic var time: Int = 0

    override static func primaryKey() -> String? {
        return "word"
    }
}

class ViewController: UIViewController {
    let disposeBag = DisposeBag()
    let maximumSearchedLoadNum = 5
    var searchedWords: [String]?
//    var searchedWords = Variable<[String]>([])
    var preloadWords: [String]?

    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var preloadWordTableView: UITableView!
    @IBOutlet weak var searchBarTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        // Do any additional setup after loading the view.
    }

    func configure(){
        setSearchBarEventHandler()
//        setPreloadDatabase()
    }
    
//    private func subscribeSearchedWords(){
//        preloadWords.asObservable().subscribe { (texts) in
//            //save to DB
//            texts
//        }
//    }
//    
    private func setSearchBarEventHandler(){
        searchBarTextField.rx.controlEvent([.editingDidBegin])
            .withLatestFrom(searchBarTextField.rx.text.orEmpty)
            .subscribe(onNext: { [unowned self]  (text) in
                self.loadSearchedWords()
                self.showSearchedHistory(input: text)
            })
            .disposed(by: disposeBag)
        
        searchBarTextField.rx.controlEvent([.editingChanged])
            .withLatestFrom(searchBarTextField.rx.text.orEmpty)
            .subscribe(onNext: { [unowned self]  (text) in
                self.showSearchedHistory(input: text)
            })
            .disposed(by: disposeBag)
        
        searchBarTextField.rx.controlEvent([.editingDidEnd])
            .withLatestFrom(searchBarTextField.rx.text.orEmpty)
            .subscribe(onNext: { [unowned self]  (text) in
                self.hideSearchHistory()
            })
            .disposed(by: disposeBag)
    }
    
    private func loadSearchedWords() {
        if self.searchedWords == nil{
            let searchedThings = try! Realm().objects(SearchedThing.self).sorted(byKeyPath: "time", ascending: false)
            if searchedThings.count > 0{
                var searchedWords = [String]()
                for searchedThing in searchedThings{
                    let word = searchedThing.word
                    searchedWords.append(word)
                }
                self.searchedWords = searchedWords
            }
        }
    }
    
    private func showSearchedHistory(input: String){
        self.getPreloadWords(input: input)

        if let preloadWords = self.preloadWords , preloadWords.count > 0{
            preloadWordTableView.reloadData()
            preloadWordTableView.isHidden = false
            tableViewHeightConstraint.constant = rowHeight * CGFloat( preloadWords.count)
        }
        else{
            preloadWordTableView.isHidden = true
        }
    }
    
    private func hideSearchHistory(){
        if let _ = self.searchedWords{
            
        }
    }
    
    private func getPreloadWords(input: String) {
        var preloadWords = [String]()
        //when blankstring in textfield , show 5 searched words
        if input.trimmingCharacters(in: .whitespaces) == blankString{
            if let searchedWords = self.searchedWords{
                for searchedWord in searchedWords{
                    preloadWords.append(searchedWord)
                    if (preloadWords.count == maximumSearchedLoadNum){ break}
                }
            }
        }
        //when inputstring in textfield, show predicate 2 searched word + 3 frequently word
        else{
            
        }
        self.preloadWords = preloadWords
    }
   
    @IBAction func btnTouched(_ sender: Any) {
        let word = searchBarTextField.text
        addSearchedWord(word)
        doSomethigByWord(word)
    }
    
    private func addSearchedWord(_ word: String?){
        print("addSearchedWord")
        if let text = word, text.count > 0{
            let searchedThing = SearchedThing(value: ["word" : text, "time" : Int(Util.getCurrentTime(format:"yyyyMMddHHmmss"))!])
            
            let realm = try! Realm()
            try! realm.write {
                realm.add(searchedThing,update: true)
            }
            var fromIndex = 0
            for searchedWord in searchedWords!{
                if searchedWord == word{
                    break
                }
                fromIndex += 1
            }
            searchedWords!.moveIndex(from: fromIndex, to: 0)
        }
    }
    
    private func removeSearchedWord(_ word: String){
        print("removeSearchedWord")
        let realm = try! Realm()
        let searchedThings = realm.objects(SearchedThing.self).filter("word = \(word)")
        try! realm.write {
            realm.delete(searchedThings[0])
        }
    }
    
    private func doSomethigByWord(_ word: String?){
        print("doSomethigByWord")
        preloadWordTableView.isHidden = true
    }

}

extension ViewController: UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return rowHeight
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let searchedWords = self.searchedWords{
            return searchedWords.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseCellIdentifier, for: indexPath) as! SearchedTableviewCell
        cell.searchedWordLabel.text = searchedWords![indexPath.row]
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let word = searchedWords![indexPath.row]
        searchBarTextField.text = word
        addSearchedWord(word)
        doSomethigByWord(word)
    }
}

