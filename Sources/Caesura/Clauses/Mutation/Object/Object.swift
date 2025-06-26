// Copyright © Fleuronic LLC. All rights reserved.

import Schemata
import PersistDB
import protocol Catenary.Clause

struct Object {
    let body: [String: any Sendable]

    init(_ valueSet: ValueSet<some Schemata.Model>) {
        body = valueSet.dictionary
    }
}

// MARK: -
extension Object: Clause {
    static let name = "object"
}
