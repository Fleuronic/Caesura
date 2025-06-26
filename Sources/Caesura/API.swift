// Copyright © Fleuronic LLC. All rights reserved.

import Identity
import PersistDB
import struct Catena.IDFields
import protocol Catena.ResultProviding
import protocol Catenary.API
import protocol Catenary.Schematic
import protocol Catenoid.Model
import protocol Catenoid.Fields

public protocol API: Catenary.API, Schematic, ResultProviding, Storage {
    associatedtype Endpoint: Caesura.Endpoint

    var endpoint: Endpoint { get }
}

// MARK: -
public extension API where Error == StorageError {
	func insert<Model: Catenoid.Model>(_ model: Model) async -> SingleResult<Model.ID> where Model.ID == Model.IdentifiedModel.ID,  Model.IdentifiedModel.RawIdentifier: Decodable {
        await result {
            try await endpoint.run(
                Query<Self, IDFields<Model.IdentifiedModel>>(
                    name: { "insert_\($0)_one" },
                    object: .init(model.valueSet)
                )
            ).fields.first!.id
        }
    }

	func insert<Model: Catenoid.Model>(_ models: [Model]) async -> Results<Model.ID> where Model.ID == Model.IdentifiedModel.ID,  Model.IdentifiedModel.RawIdentifier: Decodable {
        await result {
            try await endpoint.run(
                Query<Self, IDFields<Model.IdentifiedModel>>(
                    name: { "insert_\($0)" },
                    fieldsName: "returning",
                    objects: .init(models.map { $0.valueSet })
                )
            ).fields.map(\.id)
        }
    }

    func fetch<Fields: Catenoid.Fields & Decodable>(where predicate: Predicate<Fields.Model>?) async -> Results<Fields> {
        await result {
            try await endpoint.run(
                Query<Self, _>(
                    where: predicate.map(Where.init)
                )
            ).fields
        }
    }

    func delete<Model: PersistDB.Model & Identifiable>(where predicate: Predicate<Model>?) async -> Results<Model.ID> where Model.RawIdentifier: Decodable {
        await result {
            try await endpoint.run(
                Query<Self, IDFields<Model>>(
                    name: { "delete_\($0)" },
                    fieldsName: "returning",
                    where: predicate.map(Where.init)
                )
            ).fields.map(\.id)
        }
    }
}
