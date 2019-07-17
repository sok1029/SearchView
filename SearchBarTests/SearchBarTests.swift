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
        let realm = try! Realm()
        try! realm.write {
            realm.deleteAll()
        }
        
        let input1 = "input1"
        let input2 = "Input2"
        
        //when
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
        let realm = try! Realm()
        try! realm.write {
            realm.deleteAll()
        }
        
        var inputNum = 0
        repeat{
            inputNum += 1
            let inputString = "input\(inputNum)"
            let searchedThing = SearchedThing(value: ["word" : inputString.lowercased(), "time" : Int(Util.getCurrentTime(format:"yyyyMMddHHmmss"))!])
            
            try! realm.write {
                realm.add(searchedThing,update: true)
            }
            sleep(1)
        }while inputNum < sut.maximumSearchedLoadNum + 1
        
        let whiteSpace = ""

        //when
        sut.searchBarTextField.text = whiteSpace
        sut.searchBarTextField.sendActions(for: .editingDidBegin)
        //then
          //lately maximum Until 5 words show
        checkGraterThanMaximumLoaded()
        checkShowSuggestionWordByDescending()
    }
    
    private func checkGraterThanMaximumLoaded(){
         XCTAssertLessThan(sut.suggestionWords!.count, sut.maximumSearchedLoadNum + 1, "suggestionList is greater than maximumLoadNum")
    }
    
    private func checkShowSuggestionWordByDescending(){
        var prevTime = 0
        for suggestionWord in sut.suggestionWords!{
            if prevTime != 0{
                XCTAssertGreaterThan(prevTime, suggestionWord.time, "suggestionWords order is not descending")
            }
            prevTime = suggestionWord.time
        }
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
