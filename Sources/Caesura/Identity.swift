// Copyright © Fleuronic LLC. All rights reserved.

import Identity
import struct Catena.IDFields

extension IDFields: Swift.Decodable where Model.ID: Decodable {
	public init(from decoder: any Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		try self.init(id: container.decode(Model.ID.self, forKey: .id))
	}
}

// MARK: -
private extension IDFields {
	enum CodingKeys: String, CodingKey {
		case id
	}
}
