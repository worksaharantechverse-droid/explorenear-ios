import XCTest
@testable import ExploreNear

final class PlaceCategoryTests: XCTestCase {
    func testExpectedCategories() {
        XCTAssertEqual(
            PlaceCategory.allCases.map(\.rawValue),
            ["coffee", "restaurants", "parks", "museums"]
        )
        XCTAssertEqual(PlaceCategory.allCases.map(\.title), ["Coffee", "Restaurants", "Parks", "Museums"])
    }

    func testQueriesAndSymbolsAreDefined() {
        for category in PlaceCategory.allCases {
            XCTAssertFalse(category.title.isEmpty)
            XCTAssertFalse(category.query.isEmpty)
            XCTAssertFalse(category.symbol.isEmpty)
        }
        XCTAssertEqual(PlaceCategory.coffee.query, "coffee shops")
        XCTAssertEqual(PlaceCategory.museums.query, "museums")
    }
}
