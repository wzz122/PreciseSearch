import XCTest
@testable import PreciseSearchCore

final class MetadataQueryBuilderTests: XCTestCase {
    func testExactModeBuildsFullFilenamePredicate() {
        let request = SearchRequest(
            query: "杜媒",
            mode: .exact,
            scope: .all,
            ignoreExtension: false,
            includeHidden: false,
            maxResults: 300
        )

        XCTAssertEqual(
            MetadataQueryBuilder.predicate(for: request),
            #"kMDItemFSName ==[c] "杜媒""#
        )
    }

    func testExactModeCanMatchBasenameByIgnoringExtension() {
        let request = SearchRequest(
            query: "杜媒",
            mode: .exact,
            scope: .all,
            ignoreExtension: true,
            includeHidden: false,
            maxResults: 300
        )

        XCTAssertEqual(
            MetadataQueryBuilder.predicate(for: request),
            #"kMDItemFSName ==[c] "杜媒" || kMDItemFSName ==[c] "杜媒.*""#
        )
    }

    func testFuzzyModeBuildsContainsPredicate() {
        let request = SearchRequest(
            query: "杜媒",
            mode: .fuzzy,
            scope: .all,
            ignoreExtension: true,
            includeHidden: false,
            maxResults: 300
        )

        XCTAssertEqual(
            MetadataQueryBuilder.predicate(for: request),
            #"kMDItemFSName ==[c] "*杜媒*""#
        )
    }

    func testQueryEscapesQuotesBackslashesAndWildcards() {
        let request = SearchRequest(
            query: #"a"b\c*d"#,
            mode: .exact,
            scope: .all,
            ignoreExtension: false,
            includeHidden: false,
            maxResults: 300
        )

        XCTAssertEqual(
            MetadataQueryBuilder.predicate(for: request),
            #"kMDItemFSName ==[c] "a\"b\\c\*d""#
        )
    }
}
