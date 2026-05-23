import Foundation

public enum MetadataQueryBuilder {
    public static func predicate(for request: SearchRequest) -> String {
        let query = request.trimmedQuery

        switch request.mode {
        case .exact:
            return filenameContainsLiteral(query)
        case .fuzzy:
            return filenameContainsLiteral(query)
        }
    }

    private static func filenameContainsLiteral(_ value: String) -> String {
        #"kMDItemFSName ==[c] "*\#(escapeLiteral(value))*""#
    }

    private static func escapeLiteral(_ value: String) -> String {
        value
            .replacingOccurrences(of: #"\"#, with: #"\\"#)
            .replacingOccurrences(of: #"""#, with: #"\""#)
            .replacingOccurrences(of: "*", with: #"\*"#)
    }
}
