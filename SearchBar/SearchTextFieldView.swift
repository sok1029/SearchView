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
    var viewHeightConstraint: NSLayoutConstraint?
    
    lazy var searchedThings =  try! Realm().objects(SearchedThing.self).sorted(byKeyPath: "time", ascending: false)
    var preloadWords: [String]?
    
    @IBOutlet weak var searchBarHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var preloadWordTableView: UITableView!
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
        //firstHeight define searchBarHeight
        searchBarHeight = self.bounds.height
        setSearchBarEventHandler()
        setPreloadTableView()
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
        viewHeightConstraint = NSLayoutConstraint(item: self, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: searchBarHeight)
        self.addConstraint(viewHeightConstraint!)
    }
    
    override func layoutSubviews() {
        //set searchBarHeight UI
        if  searchBarHeightConstraint.constant != searchBarHeight{
            searchBarHeightConstraint.constant = searchBarHeight
        }
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
    
    private func setPreloadTableView(){
        preloadWordTableView.delegate = self
        preloadWordTableView.dataSource = self
        
        let nib = UINib(nibName: reuseCellIdentifier, bundle: nil)
        preloadWordTableView.register(nib, forCellReuseIdentifier: reuseCellIdentifier)
    }
    
    private func updateSearchedHistory(input: String?){
        self.getPreloadWords(input: input)
    
        if let preloadWords = self.preloadWords , preloadWords.count > 0{
            showSearchHistory(wordCount: preloadWords.count)
        }
        else{
            hideSearchHistory()
        }
    }
    
    private func showSearchHistory(wordCount: Int){
        preloadWordTableView.isHidden = false
        preloadWordTableView.reloadData()
        let tableViewHeight = (rowHeight * CGFloat(wordCount))
        let allHeight = searchBarHeight + tableViewHeight
        tableViewHeightConstraint.constant = tableViewHeight
        if initType == .frameType{
            self.frame.size.height =  allHeight
        }
        else if initType == .coderType{
            viewHeightConstraint?.constant = allHeight
        }
    }
    
    private func hideSearchHistory(){
        preloadWordTableView.isHidden = true
        if initType == .frameType{
            self.frame.size.height =  searchBarHeight
        }
        else if initType == .coderType{
            viewHeightConstraint?.constant = searchBarHeight
        }
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

extension SearchTextFieldView: UITableViewDelegate,UITableViewDataSource{
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
            let atrribute = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: searchedWordFontSize)]
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
            hideSearchHistory()
            doSomethigByWord(word)
        }
    }
}

