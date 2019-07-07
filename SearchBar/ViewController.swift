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
    
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var searchedWordTableView: UITableView!
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
        self.searchedWords = nil
        //when blankstring in textfield , show 5 searched words
        if input.trimmingCharacters(in: .whitespaces) == blankString{
            let searchedThings = try! Realm().objects(SearchedThing.self).sorted(byKeyPath: "time", ascending: false)
            if searchedThings.count > 0{
                var searched5Words = [String]()
                for searchedThing in searchedThings{
                    let word = searchedThing.word
                    searched5Words.append(word)
                    if searched5Words.count == maximumSearchedLoadNum{ break}
                }
                self.searchedWords = searched5Words
            }
        }
        //when inputstring in textfield, show predicate word with input
        else{
            
        }
    }
    
    private func showSearchHistory(){
        if let searchedWords = self.searchedWords, searchedWords.count > 0{
            searchedWordTableView.reloadData()
            searchedWordTableView.isHidden = false
            tableViewHeightConstraint.constant = rowHeight * CGFloat( searchedWords.count)
        }
        else{
            searchedWordTableView.isHidden = true
        }
    }
    
    private func hideSearchHistory(){
        if let _ = self.searchedWords{
            
        }
    }

    @IBAction func btnTouched(_ sender: Any) {
        let word = searchBarTextField.text
        saveSearchedWord(word)
        doSomethigByWord(word)
    }
    
    private func saveSearchedWord(_ word: String?){
        print("saveSearchedWord")
        if let text = word, text.count > 0{
            let searchedThing = SearchedThing(value: ["word" : text, "time" : Int(Util.getCurrentTime(format:"yyyyMMddHHmmss"))!])
            
            let realm = try! Realm()
            try! realm.write {
                realm.add(searchedThing,update: true)
            }
        }
    }
    
    private func doSomethigByWord(_ word: String?){
        print("doSomethigByWord")
        searchedWordTableView.isHidden = true
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
        saveSearchedWord(word)
        doSomethigByWord(word)
    }
}

