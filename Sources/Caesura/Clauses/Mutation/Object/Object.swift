// Copyright © Fleuronic LLC. All rights reserved.

import Schemata
import SociableWeaver
import PersistDB
import struct Catenary.ArgumentList
import struct Catenary.Schema
import protocol Catenary.Clause
import protocol Catenoid.Model
import protocol Catenary.Schematic

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
