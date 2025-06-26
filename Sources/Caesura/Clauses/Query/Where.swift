// Copyright © Fleuronic LLC. All rights reserved.

import Schemata
import PersistDB
import protocol Catenary.Clause

struct Where {
    let body: [String: any Sendable]

    init<Model>(_ predicate: Predicate<Model>) {
        body = Self.prepared(predicate.dictionary)
    }
}

// MARK: -
extension Where: Clause {
	static let name = "where"
}

// MARK: -
private extension Where {
    static func prepared(_ dictionary: [String: any Sendable]) -> [String: any Sendable] {
        .init(uniqueKeysWithValues:
            dictionary.map { key, value in
				let queryKey = key
					.replacingOccurrences(of: "==", with: "_eq")
					.replacingOccurrences(of: "AND", with: "_and")
				let queryValue = (value as? [String: Any]).map(prepared) ?? value

				return (queryKey, queryValue)
            }
        )
    }
}
