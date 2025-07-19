// Copyright © Fleuronic LLC. All rights reserved.

import protocol Catena.Fields
import protocol Catenoid.Fields
import protocol Catenoid.Model
import protocol Identity.Identifiable
import struct Identity.Identifier
import PersistDB
import protocol Schemata.ModelProjection

public protocol Storage: Sendable {
	associatedtype StorageError: Error

	func insert<Model: Catenoid.Model>(_ model: Model) async -> Result<Model.ID, StorageError> where Model.ID == Model.IdentifiedModel.ID, Model.IdentifiedModel.RawIdentifier: Decodable
	func insert<Model: Catenoid.Model>(_ models: [Model]) async -> Result<[Model.ID], StorageError> where Model.ID == Model.IdentifiedModel.ID, Model.IdentifiedModel.RawIdentifier: Decodable
	func fetch<Fields: Catenoid.Fields & Decodable>(where predicate: Predicate<Fields.Model>?) async -> Result<[Fields], StorageError>
	func delete<Model: PersistDB.Model & Identifiable>(where predicate: Predicate<Model>?) async -> Result<[Model.ID], StorageError> where Model.RawIdentifier: Decodable
}

// MARK: -
public extension Storage {
	func fetch<Fields: Catenoid.Fields & Decodable>() async -> Result<[Fields], StorageError> {
		await fetch(where: nil)
	}

	func fetch<Fields: Catenoid.Fields & Decodable>(with id: Fields.Model.ID) async -> Result<Fields, StorageError> {
		let result: Result<[Fields], StorageError> = await fetch(where: Fields.Model.idKeyPath == id)
		return result.map(\.first!)
	}

	func fetch<Fields: Catenoid.Fields & Decodable>(with ids: [Fields.Model.ID]) async -> Result<[Fields], StorageError> {
		await fetch(where: ids.contains(Fields.Model.idKeyPath))
	}

	func delete<Model: PersistDB.Model & Identifiable>(_ type: Model.Type, with ids: [Model.ID]? = nil) async -> Result<[Model.ID], StorageError> where Model.RawIdentifier: Codable {
		guard let ids else { return await delete(where: nil as Predicate<Model>?) }

		return await delete(where: ids.contains(Model.idKeyPath))
	}
}
