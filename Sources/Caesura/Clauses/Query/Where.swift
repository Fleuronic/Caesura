// Copyright © Fleuronic LLC. All rights reserved.

import protocol Catenary.Clause
import PersistDB
import Schemata

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
					.replacingOccurrences(of: "<", with: "_lt")
					.replacingOccurrences(of: ">", with: "_gt")
					.replacingOccurrences(of: "<=", with: "_lte")
					.replacingOccurrences(of: ">=", with: "_gte")
					.replacingOccurrences(of: "AND", with: "_and")
					.replacingOccurrences(of: "OR", with: "_or")
				let queryValue = (value as? [String: Any]).map(prepared) ?? value

				return (queryKey, queryValue)
			}
		)
	}
}
