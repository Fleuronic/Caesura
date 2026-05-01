// Copyright © Fleuronic LLC. All rights reserved.

import Schemata
import PersistDB
import protocol Catenary.Clause

struct Set {
	let body: [String: any Sendable]

	init(_ valueSet: ValueSet<some Schemata.Model>) {
		body = valueSet.dictionary
	}
}

// MARK: -
extension Set: Clause {
	static let name = "_set"
}
