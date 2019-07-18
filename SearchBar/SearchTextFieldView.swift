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

class SearchTextFieldView: UIView {
    let initType: InitType
    let disposeBag = DisposeBag()
    var searchBarHeight: CGFloat = 0
    let maximumSearchedLoadNum = 5
    let searchedWordFontSize: CGFloat = 17.0
    var superViewHeightConstraint: NSLayoutConstraint?
    
    @IBOutlet weak var runButton: UIButton!
    lazy var searchedThings =  try! Realm().objects(SearchedThing.self).sorted(byKeyPath: "time", ascending: false)
    var suggestionWords: [SearchedThing]?
    
    @IBOutlet weak var searchBarHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var suggestionListViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var suggestionListTableView: UITableView!
    @IBOutlet weak var searchBarTextField: UITextField!
    
    enum InitType{
        case frameType, coderType
    }

    override init(frame: CGRect) {
        initType = .frameType
        super.init(frame: frame)
        if commonInit(){
            frameTypeInit()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        initType = .coderType
        super.init(coder: aDecoder)
        if commonInit(){
            coderTypeInit()
        }
        
    }
    
    private func commonInit() -> Bool{
        //xib connect
        guard let xibName = NSStringFromClass(self.classForCoder).components(separatedBy: ".").last else { return false }
        let view =  Bundle.main.loadNibNamed(xibName, owner: self, options: nil)?.first as! UIView
        
        //firstHeight define to searchBarHeight
        searchBarHeight = self.bounds.height
        setSearchBarEventHandler()
        setRunButtonEventHandler()
        setSuggestionListTableView()
        self.addSubviewBySameConstraint(subView: view)
        
        return true
    }
    
    private func frameTypeInit(){
    }
    
    private func coderTypeInit(){
        //remove already Height Constraint
        for constraint in self.constraints{
            if constraint.firstAttribute == .bottom ||
                constraint.firstAttribute == .height {
                self.removeConstraint(constraint)
                break
            }
        }
        //create new Height Constraint
        superViewHeightConstraint = NSLayoutConstraint(item: self, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: searchBarHeight)
        if let constraint = superViewHeightConstraint{
            self.addConstraint(constraint)
        }
    }
    
    override func layoutSubviews() {
        //init searchBarHeight
        if  searchBarHeightConstraint.constant != searchBarHeight{
            searchBarHeightConstraint.constant = searchBarHeight
        }
    }
    
    //MARK: UI Handler
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
    
    private func setRunButtonEventHandler(){
        runButton.rx.controlEvent([.touchUpInside])
            .subscribe(onNext: { [unowned self]  in
                self.doWhenRun()
            })
            .disposed(by: disposeBag)
    }

    private func setSuggestionListTableView(){
        suggestionListTableView.delegate = self
        suggestionListTableView.dataSource = self
        
        let nib = UINib(nibName: reuseCellIdentifier, bundle: nil)
        suggestionListTableView.register(nib, forCellReuseIdentifier: reuseCellIdentifier)
    }
    
    private func updateSearchedHistory(input: String?){
        self.getSuggestionWords(input: input)
    
        if let suggestionWords = self.suggestionWords , suggestionWords.count > 0{
            showSearchHistory(wordCount: suggestionWords.count)
        }
        else{
            hideSearchHistory()
        }
    }
    
    private func showSearchHistory(wordCount: Int){
        suggestionListTableView.isHidden = false
        suggestionListTableView.reloadData()
        
        let tableViewHeight = (rowHeight * CGFloat(wordCount))
        let allHeight = searchBarHeight + tableViewHeight
        suggestionListViewHeightConstraint.constant = tableViewHeight
       
        if initType == .frameType{
            self.frame.size.height =  allHeight
        }
        else if initType == .coderType{
            superViewHeightConstraint?.constant = allHeight
        }
    }
    
    private func hideSearchHistory(){
        suggestionListTableView.isHidden = true
        if initType == .frameType{
            self.frame.size.height =  searchBarHeight
        }
        else if initType == .coderType{
            superViewHeightConstraint?.constant = searchBarHeight
        }
    }
    
    private func getSuggestionWords(input: String?) {
        var suggestionWords = [SearchedThing]()
        //when inputstring in textfield, show predicate 2 searched word + 3 frequently word
        if let input = input, input.trimmingCharacters(in: .whitespaces) != blankString{
            let realm = try! Realm()
            let searchedThings = realm.objects(SearchedThing.self).filter("word BEGINSWITH %@", input.lowercased()).sorted(byKeyPath: "time", ascending: false)
            
            for searchedThing in searchedThings{
                suggestionWords.append(searchedThing)
                if (suggestionWords.count == maximumSearchedLoadNum){ break}
            }
        }
        //when blankstring in textfield , show 5 searched words
        else{
            for searchedThing in searchedThings{
                suggestionWords.append(searchedThing)
                if (suggestionWords.count == maximumSearchedLoadNum){ break}
            }
        }
        
        self.suggestionWords = suggestionWords
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
    
    private func doWhenRun(){
        print("doWhenRun")
        if let word = self.searchBarTextField.text{
            self.addSearchedWord(word)
        }
        hideSearchHistory()
    }
}

extension SearchTextFieldView: UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return rowHeight
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return suggestionWords?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseCellIdentifier, for: indexPath) as! SearchedTableviewCell
        //del button event
        cell.delButton.rx.tap.asDriver()
            .drive(onNext: { [weak self] in
                // code that has to be handled by view controller
                self?.removeSearchedWord(cell.searchedWordLabel!.text!)
                self?.updateSearchedHistory(input:
                    self?.searchBarTextField.text)
            }).disposed(by: cell.bag)
        
        if let suggestionWords = self.suggestionWords{
            //bold effect to equal string with textfield
            let word = NSMutableAttributedString(string: suggestionWords[indexPath.row].word)
            let range = NSRange(location: 0, length: searchBarTextField.text!.count)
            let atrribute = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: searchedWordFontSize)]
            
            word.addAttributes(atrribute, range: range)
            
            cell.searchedWordLabel.attributedText = word
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let suggestionWords = self.suggestionWords{
            searchBarTextField.text = suggestionWords[indexPath.row].word
            doWhenRun()
        }
    }
}

