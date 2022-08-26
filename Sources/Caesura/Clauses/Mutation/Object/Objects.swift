// Copyright © Fleuronic LLC. All rights reserved.

import Schemata
import SociableWeaver
import PersistDB
import struct Catenary.ArgumentList
import struct Catenary.Schema
import protocol Catenary.Clause
import protocol Catenoid.Model
import protocol Catenary.Schematic

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
