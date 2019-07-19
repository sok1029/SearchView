//
//  SearchBarTests.swift
//  SearchBarTests
//
//  Created by SokJinYoung on 04/07/2019.
//  Copyright © 2019 Stone. All rights reserved.
//

import XCTest
import RealmSwift

//import Searched
@testable import SearchBar

class SearchBarTests: XCTestCase {

    var sut: SearchTextFieldView!
    
    override func setUp() {
        super.setUp()
        sut = SearchTextFieldView(frame: CGRect(x: 50, y: 50, width: 250, height: 100))
        
        //        let textFieldView = SearchTextFieldView.init(frame: CGRect(x: 50, y: 50, width: 250, height: 100))
        //        self.view.addSubview(textFieldView)
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    func testSaveHistoryWhenRun(){
        //given
        commonGiven()
        
        let input1 = "input1"
        let input2 = "Input2"
        
        //when
        sut.searchBarTextField.sendActions(for: .editingDidBegin)

        sut.searchBarTextField.text = input1
        sut.runButton.sendActions(for: .touchUpInside)

        sut.searchBarTextField.text = input2
        sut.runButton.sendActions(for: .touchUpInside)

        //then
        let searchedThings =  try! Realm().objects(SearchedThing.self)
        
        XCTAssertEqual(searchedThings[0].word, input1, "Input String didn't save in DB")
        XCTAssertEqual(searchedThings[1].word, input2.lowercased(), "saved String Not adjust lowerCased")
    }
    
    func testShowHistoryWhenWhiteSpace(){
        //given
        commonGiven()
        sut.searchBarTextField.sendActions(for: .editingDidBegin)

        var inputNum = 0
        repeat{
            inputNum += 1
            let inputString = "input\(inputNum)"
            let searchedThing = SearchedThing(value: ["word" : inputString.lowercased(), "time" : Int(Util.getCurrentTime(format:"yyyyMMddHHmmss"))!])
            
            let realm = try! Realm()
            try! realm.write {
                realm.add(searchedThing,update: true)
            }
            
            sleep(1)
        }while inputNum < sut.maxSearchedLoadNum + 1
        
        let whiteSpace = ""

        //when
        sut.searchBarTextField.text = whiteSpace
        sut.searchBarTextField.sendActions(for: .editingChanged)
        //then
          //lately maximum Until 5 words show
        commonCheckWhenHistoryShow()
    }
    
    func testShowHistroyWhenInputText(){
        //given
        commonGiven()
        sut.searchBarTextField.sendActions(for: .editingDidBegin)

        let inputs = ["LOVE","Like"]
        sut.searchBarTextField.text = inputs[0]
        sut.runButton.sendActions(for: .touchUpInside)
        
        sleep(1)
        
        sut.searchBarTextField.text = inputs[1]
        sut.runButton.sendActions(for: .touchUpInside)
        
        sut.searchBarTextField.text = ""
        sut.runButton.sendActions(for: .editingChanged)

        //when
        sut.searchBarTextField.text = "L"
        sut.searchBarTextField.sendActions(for: .editingChanged)
        //then
        var words = [String]()
        for suggestionWord in sut.suggestionWords.value{
            words.append(suggestionWord.word)
        }
        XCTAssert(words.contains(inputs[0].lowercased()) && words.contains(inputs[1].lowercased()), "testShowHistroyWhenInputText not working ")
        commonCheckWhenHistoryShow()
        //when
        sut.searchBarTextField.text = "Lo"
        sut.searchBarTextField.sendActions(for: .editingChanged)

        //then
        words = [String]()
        for suggestionWord in sut.suggestionWords.value{
            words.append(suggestionWord.word)
        }
        XCTAssert(words.contains(inputs[0].lowercased()), "lowerCased search not working ")
        commonCheckWhenHistoryShow()
        
    }
    
    func testWhenHistorySelected(){
        //given
        commonGiven()
        sut.searchBarTextField.sendActions(for: .editingDidBegin)

        let inputs = ["Love", "like"]
        sut.searchBarTextField.text = inputs[0]
        sut.runButton.sendActions(for: .touchUpInside)
        sleep(1)
        sut.searchBarTextField.text = inputs[1]
        sut.runButton.sendActions(for: .touchUpInside)
        
        sut.searchBarTextField.text = ""
        sut.searchBarTextField.sendActions(for: .editingChanged)

        //when
        let indexPath = IndexPath(row: 1, section: 0) //select "Love"
        sut.suggestionListTableView.delegate?.tableView!(sut.suggestionListTableView, didSelectRowAt: indexPath)

        //then
        XCTAssertEqual(sut.searchBarTextField.text, inputs[0].lowercased(), "SelectedWord didn't input to TextField")
        XCTAssert(sut.suggestionListTableView.isHidden == true, "History still Showing")
        let searchedThings =  try! Realm().objects(SearchedThing.self).sorted(byKeyPath: "time", ascending: false)
        
        XCTAssertEqual(searchedThings[0].word , inputs[0].lowercased(), "Select word wan't updating order lately")
    }
    
    func testWhenHistoryDeleted(){
        //given
        commonGiven()
        sut.searchBarTextField.sendActions(for: .editingDidBegin)

        let inputs = ["LOVE","like"]
        sut.searchBarTextField.text = inputs[0]
        sut.runButton.sendActions(for: .touchUpInside)
        sleep(1)
        sut.searchBarTextField.text = inputs[1]
        sut.runButton.sendActions(for: .touchUpInside)
       
        sut.searchBarTextField.text = ""
        sut.searchBarTextField.sendActions(for: .editingChanged)

        //when
        let indexPath = IndexPath(row: 0, section: 0) //delete "like"
        let cell = sut.suggestionListTableView.cellForRow(at: indexPath) as! SearchedTableviewCell
        cell.delButton.sendActions(for: .touchUpInside)
        //then
        
        var words = [String]()
        for suggestionWord in sut.suggestionWords.value{
            words.append(suggestionWord.word)
        }
        
        XCTAssert(words.contains(inputs[1].lowercased()) == false, "didn't deleted in tableview")
        
        let searchedThings =  try! Realm().objects(SearchedThing.self)
        words = [String]()
        for searchThing in searchedThings{
            words.append(searchThing.word)
        }
        
        XCTAssert(words.contains(inputs[1].lowercased()) == false, "didn't deleted in Database")
    }

    
    
    private func commonGiven(){
        let realm = try! Realm()
        try! realm.write {
            realm.deleteAll()
        }
    }
    
    private func commonCheckWhenHistoryShow(){
//        checkGraterThanMaximumLoaded()
        checkShowSuggestionWordByDescending()
        checkShowHistory()
    }
    
//    private func checkGraterThanMaximumLoaded(){
//         XCTAssertLessThan(sut.suggestionWords.value.count, sut.maxSearchedLoadNum + 1, "suggestionList is greater than maximumLoadNum")
//    }
    
    private func checkShowSuggestionWordByDescending(){
        var prevTime = 0
        for suggestionWord in sut.suggestionWords.value{
            if prevTime != 0{
                XCTAssertGreaterThan(prevTime, suggestionWord.time, "suggestionWords order is not descending")
            }
            prevTime = suggestionWord.time
        }
    }
    private func checkShowHistory(){
        XCTAssert(sut.suggestionListTableView.isHidden == false, "Show Suggestion is not working")
        XCTAssert(sut.suggestionListTableView.numberOfRows(inSection: 0) == sut.getSuggestionWordsCount(count: sut.suggestionWords.value.count), "ShowingRowCount is not same suggestionWords")
    }

    
    //given
    
    //when
    
    //then
//    func testExample() {
//        // This is an example of a functional test case.
//        // Use XCTAssert and related functions to verify your tests produce the correct results.
//    }
//
//    func testPerformanceExample() {
//        // This is an example of a performance test case.
//        self.measure {
//            // Put the code you want to measure the time of here.
//        }
//    }
    
    
}
