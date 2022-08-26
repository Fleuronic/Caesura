// Copyright © Fleuronic LLC. All rights reserved.

import Schemata
import SociableWeaver
import PersistDB
import struct Catenary.ArgumentList
import struct Catenary.Schema
import protocol Catenary.Clause
import protocol Catenary.Schematic

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
                (
                    key
                        .replacingOccurrences(of: "==", with: "_eq")
                        .replacingOccurrences(of: "AND", with: "_and"),
                    (value as? [String: Any]).map(prepared) ?? value
                )
            }
        )
    }
}
