// Copyright © Fleuronic LLC. All rights reserved.

import protocol Catenary.Clause

struct Offset {
	let body: Int

	init(_ value: Int) {
		body = value
	}
}

// MARK: -
extension Offset: Clause {
	static let name = "offset"
}
