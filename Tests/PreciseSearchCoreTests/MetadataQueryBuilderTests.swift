import XCTest
@testable import PreciseSearchCore

final class MetadataQueryBuilderTests: XCTestCase {
    func testExactModeBuildsLiteralContainsPredicate() {
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
            #"kMDItemFSName ==[c] "*杜媒*""#
        )
    }

    func testExactModeEscapesWildcardsInsideLiteralQuery() {
        let request = SearchRequest(
            query: "序*列",
            mode: .exact,
            scope: .all,
            ignoreExtension: false,
            includeHidden: false,
            maxResults: 300
        )

        XCTAssertEqual(
            MetadataQueryBuilder.predicate(for: request),
            #"kMDItemFSName ==[c] "*序\*列*""#
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
            #"kMDItemFSName ==[c] "*a\"b\\c\*d*""#
        )
    }

    func testFilesystemSearchFindsExactLiteralSubstring() throws {
        let temporaryDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: temporaryDirectory, withIntermediateDirectories: true)
        defer {
            try? FileManager.default.removeItem(at: temporaryDirectory)
        }

        let fileURL = temporaryDirectory.appendingPathComponent("序列 01_3.mp4")
        FileManager.default.createFile(atPath: fileURL.path, contents: Data("video".utf8))

        let request = SearchRequest(
            query: "序",
            mode: .exact,
            scope: .all,
            ignoreExtension: true,
            includeHidden: true,
            maxResults: 300
        )

        let results = FileSystemSearch.search(request, roots: [temporaryDirectory], excluding: [])

        XCTAssertTrue(results.contains { $0.name == fileURL.lastPathComponent })
    }
}
