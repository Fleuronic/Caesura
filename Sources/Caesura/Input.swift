// Copyright © Fleuronic LLC. All rights reserved.

import PersistDB
import Identity
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
