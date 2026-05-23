import Foundation

public enum MetadataQueryBuilder {
    public static func predicate(for request: SearchRequest) -> String {
        let query = request.trimmedQuery

        switch request.mode {
        case .exact:
            if request.ignoreExtension {
                return "(\(filenameEquals(query)) || \(filenameEqualsPattern("\(query).*")))"
            }

            return filenameEquals(query)
        case .fuzzy:
            return filenameEqualsPattern("*\(query)*")
        }
    }

    private static func filenameEquals(_ value: String) -> String {
        #"kMDItemFSName ==[c] "\#(escapeLiteral(value))""#
    }

    private static func filenameEqualsPattern(_ value: String) -> String {
        #"kMDItemFSName ==[c] "\#(escapePattern(value))""#
    }

    private static func escapeLiteral(_ value: String) -> String {
        escapeCommon(value)
            .replacingOccurrences(of: "*", with: #"\*"#)
    }

    private static func escapePattern(_ value: String) -> String {
        escapeCommon(value)
    }

    private static func escapeCommon(_ value: String) -> String {
        value
            .replacingOccurrences(of: #"\"#, with: #"\\"#)
            .replacingOccurrences(of: #"""#, with: #"\""#)
    }
}
