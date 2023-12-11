import XCTest

final class ProfileElementsTest: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUp() {
        super.setUp()
        app = .init()
        app.launch()
        app.tabBars["Tab Bar"].buttons["Profile"].tap()
    }

    func testElements() {

        let scrollViewsQuery = app.scrollViews
        let avatar = scrollViewsQuery.otherElements
            .containing(.button, identifier: "Add photo")
            .children(matching: .other).element

        let elementsQuery = scrollViewsQuery.otherElements
        let nameField = elementsQuery.staticTexts["nameField"]
        let bioField = elementsQuery.staticTexts["bioField"]
        let addPhotoButton = elementsQuery.staticTexts["Add photo"]
        let editButton = elementsQuery.staticTexts["Edit Profile"]

        XCTAssertTrue(avatar.exists)
        XCTAssertTrue(addPhotoButton.exists)
        XCTAssertTrue(nameField.exists)
        XCTAssertTrue(bioField.exists)
        XCTAssertTrue(editButton.exists)
        
        elementsQuery.staticTexts["Edit Profile"].tap()
        
        let nameEditField = elementsQuery.textFields["Type your name"]
        let bioEditField = elementsQuery.textFields["Describe yourself"]
        let saveButton = app.navigationBars["Edit Profile"].buttons["Save"]
        let cancelButton = app.navigationBars["Edit Profile"].buttons["Cancel"]
        
        XCTAssertTrue(cancelButton.exists)
        XCTAssertTrue(saveButton.exists)
        XCTAssertTrue(avatar.exists)
        XCTAssertTrue(nameEditField.exists)
        XCTAssertTrue(bioEditField.exists)
    }
}
