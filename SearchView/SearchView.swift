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

class SearchedWord: Object{
    @objc dynamic var text = ""
    @objc dynamic var time: Int = 0
    
    override static func primaryKey() -> String? {
        return "text"
    }
}

class SearchView: UIView {
    let initType: InitType
  
    let disposeBag = DisposeBag()
    
    let maxSearchedLoadNum = 5
    let maxSearchedLoadNumMixed = 2
    let searchedWordFontSize: CGFloat = 17.0
    var searchBarHeight: CGFloat = 0
    
    lazy var suggestionWords = Variable<[SearchedWord]>([])
    lazy var searchedWords =  try! Realm().objects(SearchedWord.self).sorted(byKeyPath: "time", ascending: false)
    
    var actWhenRun: (()->())?
    var superViewHeightConstraint: NSLayoutConstraint?
    
    @IBOutlet weak var runButton: UIButton!
    
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
        
        //init searchBarHeight by bounsHeight
        searchBarHeight = self.bounds.height
        
        setUIEventHandler()
        setActWhenSuggestionWordsUpdate()
        setSuggestionWordsList()
        
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
    
    //MARK: UI Event Handler
    private func setUIEventHandler(){
        //textField
        searchBarTextField.rx.controlEvent([.editingDidBegin,.editingChanged])
            .withLatestFrom(searchBarTextField.rx.text.orEmpty)
            .subscribe(onNext: { [weak self]  (text) in
                self?.updateSuggestionWordsList(input: text)
            })
            .disposed(by: disposeBag)
        
        searchBarTextField.rx.controlEvent([.editingDidEnd])
            .withLatestFrom(searchBarTextField.rx.text.orEmpty)
            .subscribe(onNext: { [weak self]  (text) in
                self?.hideSuggestionWordsList()
            })
            .disposed(by: disposeBag)
        //run button
        runButton.rx.controlEvent([.touchUpInside])
            .subscribe(onNext: { [weak self]  in
                self?.doWhenRun()
            })
            .disposed(by: disposeBag)
    }
    
    //MARK: SuggestionWords List
    private func setSuggestionWordsList(){
        suggestionListTableView.delegate = self
        suggestionListTableView.dataSource = self
        
        let nib = UINib(nibName: reuseCellIdentifier, bundle: nil)
        suggestionListTableView.register(nib, forCellReuseIdentifier: reuseCellIdentifier)
    }
    
    private func setActWhenSuggestionWordsUpdate(){
        suggestionWords.asObservable()
            .subscribe(onNext: { [weak self] suggestionWords in
                guard let strongSelf = self else {return}
                if suggestionWords.count > 0{
                    let wordsCount = strongSelf.getSuggestionWordsCount(count: suggestionWords.count)
                    strongSelf.showSuggestionWordsList(count: wordsCount)
                }
                else{
                    strongSelf.hideSuggestionWordsList()
                }
            })
            .disposed(by: disposeBag)
    }
    
    func getSuggestionWordsCount(count: Int) -> Int{
        return count < maxSearchedLoadNum ?  count : maxSearchedLoadNum
    }
    
    private func updateSuggestionWordsList(input: String?){
        var suggestionWords = [SearchedWord]()
        //when is string in textfield, (searched word) in client + (frequently word) in server
        if let input = input, input.trimmingCharacters(in: .whitespaces) != ""{
            //searched in client
            let searchedWords = getSearchedWord(beginWith: input)
            for searchedword in searchedWords{
                suggestionWords.append(searchedword)
//                if (suggestionWords.count == maxSearchedLoadNumMixed){ break}
            }
            //Suggestion in server
                //input your ServerRequest Code
            
            self.suggestionWords.value = suggestionWords
        }
        //when blankstring in textfield , show 5 searched words
        else{
            for searchedWord in searchedWords{
                suggestionWords.append(searchedWord)
            }
            self.suggestionWords.value = suggestionWords
        }
    }
    
    private func showSuggestionWordsList(count: Int){
        suggestionListTableView.isHidden = false
        suggestionListTableView.reloadData()
        
        let tableViewHeight = (rowHeight * CGFloat(count))
        let allHeight = searchBarHeight + tableViewHeight
        suggestionListViewHeightConstraint.constant = tableViewHeight
       
        if initType == .frameType{
            self.frame.size.height =  allHeight
        }
        else if initType == .coderType{
            superViewHeightConstraint?.constant = allHeight
        }
    }
    
    private func hideSuggestionWordsList(){
        suggestionListTableView.isHidden = true
        if initType == .frameType{
            self.frame.size.height =  searchBarHeight
        }
        else if initType == .coderType{
            superViewHeightConstraint?.constant = searchBarHeight
        }
    }
    
    //MARK: Database (Realm)
    private func addSearchedWord(_ word: String?){
        if let text = word, text.count > 0{
            //only lowercased text
            let searchedThing = SearchedWord(value: ["text" : text.lowercased(), "time" : Int(Util.getCurrentTime(format:"yyyyMMddHHmmss"))!])
            
            let realm = try! Realm()
            try! realm.write {
                realm.add(searchedThing,update: true)
            }
        }
    }
    
    private func removeSearchedWord(_ word: String){
        let realm = try! Realm()
        let searchedThings = realm.objects(SearchedWord.self).filter("text = '\(word)'")
        try! realm.write {
            realm.delete(searchedThings)
        }
    }
    
    private func getSearchedWord(beginWith word: String) -> Results<SearchedWord>{
        let realm = try! Realm()
        return realm.objects(SearchedWord.self).filter("text BEGINSWITH %@", word.lowercased()).sorted(byKeyPath: "time", ascending: false)
    }
    
    //MARK: Run Action
    private func doWhenRun(){
        if let word = self.searchBarTextField.text, word.count > 0{
            self.addSearchedWord(word)
            if let act = actWhenRun{
                act()
            }
        }
        hideSuggestionWordsList()
    }
}

//MARK: TableViewDelegate, TableViewDataSource
extension SearchView: UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return rowHeight
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  getSuggestionWordsCount(count: suggestionWords.value.count)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseCellIdentifier, for: indexPath) as! SearchedTableviewCell
        //del button event
        cell.delButton.rx.tap.asDriver()
            .drive(onNext: { [weak self] in
                self?.removeSearchedWord(cell.searchedWordLabel!.text!)
                self?.suggestionWords.value.remove(at: indexPath.row)
            }).disposed(by: cell.bag)
        
        //bold effect to equal string with textfield
        let word = NSMutableAttributedString(string: suggestionWords.value[indexPath.row].text)
        let range = NSRange(location: 0, length: searchBarTextField.text!.count)
        let atrribute = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: searchedWordFontSize)]
        word.addAttributes(atrribute, range: range)
        cell.searchedWordLabel.attributedText = word
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        searchBarTextField.text = suggestionWords.value[indexPath.row].text
        doWhenRun()
    }
}

extension UIView {
    func addSubviewBySameConstraint(subView: UIView){
        self.addSubview(subView)
        subView.translatesAutoresizingMaskIntoConstraints = false
        subView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        subView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        subView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        subView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
    }
}

class Util {
    static func getCurrentTime(format: String) -> String{
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: date)
    }
}



