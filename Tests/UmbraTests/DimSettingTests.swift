import XCTest
@testable import Umbra

final class DimSettingTests: XCTestCase {
    func testPercentFromAlpha() {
        XCTAssertEqual(DimSetting(alpha: 0).percent, 0)
        XCTAssertEqual(DimSetting(alpha: 0.25).percent, 25)
        XCTAssertEqual(DimSetting(alpha: 0.5).percent, 50)
    }

    func testTitlesByBand() {
        XCTAssertEqual(DimSetting(alpha: 0.0).title, "Off")
        XCTAssertEqual(DimSetting(alpha: 0.05).title, "Barely there")
        XCTAssertEqual(DimSetting(alpha: 0.12).title, "Light")
        XCTAssertEqual(DimSetting(alpha: 0.25).title, "Noticeable")
        XCTAssertEqual(DimSetting(alpha: 0.45).title, "Heavy")
    }

    func testEveryAlphaHasNonEmptyGuidance() {
        for step in 0...50 {
            let setting = DimSetting(alpha: Double(step) / 100.0)
            XCTAssertFalse(setting.title.isEmpty)
            XCTAssertFalse(setting.detail.isEmpty)
        }
    }

    func testRangeTopMatchesMaxAlpha() {
        XCTAssertEqual(DimSetting.range.upperBound, DimSetting.maxAlpha)
        XCTAssertEqual(DimSetting.range.lowerBound, 0)
    }
}
