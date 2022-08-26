// Copyright © Fleuronic LLC. All rights reserved.

import struct PersistDB.ValueSet
import protocol PersistDB.Model
import protocol Schemata.ModelValue
import protocol Identity.Identifiable
import protocol Catena.Valued
import protocol Catenoid.Model

public protocol Input: Catenoid.Model, Valued, Sendable where IdentifiedModel.RawIdentifier: Sendable {
    var valueSet: ValueSet<IdentifiedModel> { get }
}

// MARK: -
public extension Input {
    // MARK: Model
    var identifiedModelID: ID? { nil }
}
