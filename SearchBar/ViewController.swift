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
    let searchedWordFontSize: CGFloat = 17.0
    
    lazy var searchedThings =  try! Realm().objects(SearchedThing.self).sorted(byKeyPath: "time", ascending: false)
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
    }

    private func setSearchBarEventHandler(){
        searchBarTextField.rx.controlEvent([.editingDidBegin,.editingChanged])
            .withLatestFrom(searchBarTextField.rx.text.orEmpty)
            .subscribe(onNext: { [unowned self]  (text) in
                self.updateSearchedHistory(input: text)
            })
            .disposed(by: disposeBag)
        
        searchBarTextField.rx.controlEvent([.editingDidEnd])
            .withLatestFrom(searchBarTextField.rx.text.orEmpty)
            .subscribe(onNext: { [unowned self]  (text) in
                self.hideSearchHistory()
            })
            .disposed(by: disposeBag)
    }
    
    private func updateSearchedHistory(input: String?){
        self.getPreloadWords(input: input)
        self.updateTableView()
    }
    
    private func updateTableView(){
        if let preloadWords = self.preloadWords , preloadWords.count > 0{
            preloadWordTableView.isHidden = false
            preloadWordTableView.reloadData()
            tableViewHeightConstraint.constant = rowHeight * CGFloat( preloadWords.count)
        }
        else{
            preloadWordTableView.isHidden = true
        }
    }
    
    private func hideSearchHistory(){
//        if let _ = self.searchedWords{
//
//        }
    }
    
    private func getPreloadWords(input: String?) {
        var preloadWords = [String]()
        //when inputstring in textfield, show predicate 2 searched word + 3 frequently word
        if let input = input, input.trimmingCharacters(in: .whitespaces) != blankString{
            let realm = try! Realm()
            let searchedThings = realm.objects(SearchedThing.self).filter("word BEGINSWITH %@", input.lowercased()).sorted(byKeyPath: "time", ascending: false)
            
            for searchedThing in searchedThings{
                preloadWords.append(searchedThing.word)
                if (preloadWords.count == maximumSearchedLoadNum){ break}
            }
        }
        //when blankstring in textfield , show 5 searched words
        else{
            for searchedThing in searchedThings{
                preloadWords.append(searchedThing.word)
                if (preloadWords.count == maximumSearchedLoadNum){ break}
            }
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
            //only lowercased text
            let searchedThing = SearchedThing(value: ["word" : text.lowercased(), "time" : Int(Util.getCurrentTime(format:"yyyyMMddHHmmss"))!])
            
            let realm = try! Realm()
            try! realm.write {
                realm.add(searchedThing,update: true)
            }
        }
    }
    
    private func removeSearchedWord(_ word: String){
        print("removeSearchedWord")
        let realm = try! Realm()
        let searchedThings = realm.objects(SearchedThing.self).filter("word = '\(word)'")
        try! realm.write {
            realm.delete(searchedThings)
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
        return preloadWords?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseCellIdentifier, for: indexPath) as! SearchedTableviewCell
        cell.delButton.rx.tap.asDriver()
            .drive(onNext: { [weak self] in
                // code that has to be handled by view controller
                self?.removeSearchedWord(cell.searchedWordLabel!.text!)
                    self?.updateSearchedHistory(input: nil)
            }).disposed(by: cell.bag)
        
        if let preloadWords = self.preloadWords{
            //bold effect to equal string with textfield
            let word = NSMutableAttributedString(string: preloadWords[indexPath.row])
            let range = NSRange(location: 0, length: searchBarTextField.text!.count)
            let atrribute = [ NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: searchedWordFontSize)]
            word.addAttributes(atrribute, range: range)
            
            cell.searchedWordLabel.attributedText = word
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let preloadWords = self.preloadWords{
            let word = preloadWords[indexPath.row]
            searchBarTextField.text = word
            addSearchedWord(word)
            doSomethigByWord(word)
        }
    }
}

