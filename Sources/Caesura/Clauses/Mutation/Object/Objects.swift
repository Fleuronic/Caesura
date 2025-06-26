// Copyright © Fleuronic LLC. All rights reserved.

import Schemata
import PersistDB
import protocol Catenary.Clause

struct Objects {
    let body: [[String: any Sendable]]

    init(_ valueSets: [ValueSet<some Schemata.Model>]) {
        body = valueSets.map(\.dictionary) as! [[String: any Sendable]]
    }
}

// MARK: -
extension Objects: Clause {
    static let name = "objects"
}
