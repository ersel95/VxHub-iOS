import XCTest
@testable import VxHub

final class VxLocalizerTests: XCTestCase {

    func testLocalizeReturnsKeyWhenNoTranslation() {
        // When there's no stored localization, .localize() should return the key itself
        let key = "NONEXISTENT_KEY_\(UUID().uuidString)"
        let result = key.localize()
        XCTAssertEqual(result, key, "Localize should return the key when no translation exists")
    }

    func testLocalizeEmptyString() {
        let result = "".localize()
        XCTAssertEqual(result, "", "Empty string localize should return empty string")
    }

    func testLocalizerSharedInstanceExists() {
        // VxLocalizer is a struct with a static shared instance
        let localizer = VxLocalizer.shared
        XCTAssertNotNil(localizer)
    }
}
