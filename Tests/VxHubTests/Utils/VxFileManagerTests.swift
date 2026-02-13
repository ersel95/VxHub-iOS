import XCTest
@testable import VxHub
@testable import VxHubCore

final class VxFileManagerTests: XCTestCase {

    var fileManager: VxFileManager!

    override func setUp() {
        super.setUp()
        fileManager = VxFileManager()
    }

    func testDirectoryCreation() {
        let baseURL = fileManager.vxHubDirectoryURL(for: .baseDir)
        XCTAssertTrue(FileManager.default.fileExists(atPath: baseURL.path), "Base directory should exist after init")
    }

    func testSubDirectoryURLs() {
        let imagesURL = fileManager.vxHubDirectoryURL(for: .imagesDir)
        XCTAssertTrue(imagesURL.path.contains("VxImages"), "Images directory URL should contain VxImages")

        let videoURL = fileManager.vxHubDirectoryURL(for: .videoDir)
        XCTAssertTrue(videoURL.path.contains("VxVideos"), "Video directory URL should contain VxVideos")

        let thirdPartyURL = fileManager.vxHubDirectoryURL(for: .thirdPartyDir)
        XCTAssertTrue(thirdPartyURL.path.contains("VxThirdPartyResources"), "Third party directory URL should contain VxThirdPartyResources")
    }

    func testSaveAndLoadData() {
        let testData = "Hello VxHub".data(using: .utf8)!
        let expectation = expectation(description: "Save completes")

        fileManager.save(testData, type: .baseDir, fileName: "test_file.txt", overwrite: true) { result in
            switch result {
            case .success:
                expectation.fulfill()
            case .failure(let error):
                XCTFail("Save failed: \(error)")
            }
        }

        wait(for: [expectation], timeout: 5.0)

        // Verify file exists
        let fileURL = fileManager.vxHubDirectoryURL(for: .baseDir).appendingPathComponent("test_file.txt")
        XCTAssertTrue(FileManager.default.fileExists(atPath: fileURL.path))

        // Clean up
        try? FileManager.default.removeItem(at: fileURL)
    }

    func testPathForImage() {
        let path = fileManager.pathForImage(named: "test_image.png")
        XCTAssertTrue(path.path.contains("VxImages"))
        XCTAssertTrue(path.path.contains("test_image.png"))
    }

    func testPathForVideo() {
        let path = fileManager.pathForVideo(named: "test_video")
        XCTAssertTrue(path.path.contains("VxVideos"))
        XCTAssertTrue(path.path.contains("test_video.mp4"), "Should auto-append .mp4 extension")
    }

    func testPathForVideoWithExtension() {
        let path = fileManager.pathForVideo(named: "test_video.mp4")
        XCTAssertTrue(path.path.contains("test_video.mp4"))
        // Should not double-append .mp4
        XCTAssertFalse(path.path.contains("test_video.mp4.mp4"))
    }

    func testLocalizedKeyForImage() {
        let key = fileManager.localizedKeyForImage("https://cdn.example.com/images/en/icons/logo.png")
        XCTAssertNotNil(key)
        XCTAssertEqual(key, "en-icons-logo.png")
    }

    func testLocalizedKeyForImageNilInput() {
        let key = fileManager.localizedKeyForImage(nil)
        XCTAssertNil(key)
    }

    func testLocalizedKeyForImageInvalidURL() {
        let key = fileManager.localizedKeyForImage("")
        XCTAssertNil(key)
    }

    func testSaveOverwrite() {
        let data1 = "version1".data(using: .utf8)!
        let data2 = "version2".data(using: .utf8)!
        let fileName = "overwrite_test.txt"

        let exp1 = expectation(description: "First save")
        fileManager.save(data1, type: .baseDir, fileName: fileName, overwrite: true) { _ in
            exp1.fulfill()
        }
        wait(for: [exp1], timeout: 5.0)

        let exp2 = expectation(description: "Second save")
        fileManager.save(data2, type: .baseDir, fileName: fileName, overwrite: true) { _ in
            exp2.fulfill()
        }
        wait(for: [exp2], timeout: 5.0)

        // Verify content is version2
        let fileURL = fileManager.vxHubDirectoryURL(for: .baseDir).appendingPathComponent(fileName)
        if let data = try? Data(contentsOf: fileURL), let content = String(data: data, encoding: .utf8) {
            XCTAssertEqual(content, "version2")
        } else {
            XCTFail("Could not read overwritten file")
        }

        // Clean up
        try? FileManager.default.removeItem(at: fileURL)
    }
}
