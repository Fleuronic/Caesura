// Copyright © Fleuronic LLC. All rights reserved.

import protocol Catenary.Clause

struct Limit {
	let body: Int

	init(_ count: Int) {
		body = count
	}
}

// MARK: -
extension Limit: Clause {
	static let name = "limit"
}
