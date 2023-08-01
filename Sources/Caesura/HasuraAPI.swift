// Copyright © Fleuronic LLC. All rights reserved.

import Catena
import Catenary
import Schemata
import PersistDB
import SociableWeaver

public protocol HasuraAPI: GraphQLAPI, Storage {}

// MARK: -
public extension HasuraAPI {
	func insert<Model: Catena.Model>(_ model: Model) async -> Self.Result<Model.ID> {
		let fields: Self.Result<[IDFields<Model>]> = await send(.insert([model], many: false))
		return fields.map(\.first!.id)
	}

	func insert<Model: Catena.Model>(_ models: [Model]) async -> Self.Result<[Model.ID]> {
		let fields: Self.Result<[IDFields<Model>]> = await send(.insert(models, many: true))
		return fields.map { $0.map(\.id) }
	}

	func fetch<Model: Catena.Model>(where predicate: Predicate<Model>? = nil) async -> Self.Result<[Model.ID]> {
		await fetch(IDFields<Model>.self, where: predicate).map { $0.map(\.id) }
	}

	func fetch<Fields: Catena.Fields>(_ fields: Fields.Type, where predicate: Predicate<Fields.Model>? = nil) async -> Self.Result<[Fields]> {
		var fetchPredicate = Fields.Model.all
		predicate.map { fetchPredicate = fetchPredicate.filter($0) }
		return await send(fetchPredicate)
	}

	func update<Model: Catena.Model>(_ valueSet: ValueSet<Model>, with id: Model.ID) async -> Self.Result<Model.ID> {
		let fields: Self.Result<[IDFields<Model>]> = await send(.update(.primaryKey(id), valueSet))
		return fields.map(\.first!.id)
	}

	func update<Model: Catena.Model>(_ valueSet: ValueSet<Model>, where predicate: Predicate<Model>?) async -> Self.Result<[Model.ID]> {
		let fields: Self.Result<[IDFields<Model>]> = await send(.update(.predicate(predicate), valueSet))
		return fields.map { $0.map(\.id) }
	}

    func delete<Model: Catena.Model>(_ type: Model.Type, with id: Model.ID) async -> Self.Result<Model.ID?> {
		await send(.delete(.primaryKey(id))).map { (fields: [IDFields<Model>]) in
			fields.first?.id
		}
	}

	func delete<Model: Catena.Model>(_ type: Model.Type, with ids: [Model.ID]) async -> Self.Result<[Model.ID]> {
		let predicate: Predicate<Model> = ids.contains(Model.idKeyPath)
		return await delete(type, where: predicate)
	}


	func delete<Model: Catena.Model>(_ type: Model.Type, where predicate: Predicate<Model>? = nil) async -> Self.Result<[Model.ID]> {
		await send(.delete(.predicate(predicate))).map { (fields: [IDFields<Model>]) in
			fields.map(\.id)
		}
	}

	func queryString<Fields: Catena.Fields>(for query: GraphQL.Query<Fields>) -> String {
		Weave(.init(query)) {
			object(for: query)
		}.description
	}
}

// MARK: -
private extension HasuraAPI {
	func object<Fields: Catena.Fields>(for query: GraphQL.Query<Fields>) -> Object {
		let name = name(of: query)
		let keyPaths = Fields.projection.keyPaths
		let paths = keyPaths
			.map(Fields.Model.schema.properties)
			.map { $0.map(\.path) }
			.filter{ !$0.isEmpty } + keyPaths.compactMap {
				Fields.toManyKeys[$0]
			}
		let fields = paths.map { $0.objectWeavable(for: query) }
		let base = Object(name) {
			ForEachWeavable(
				fields
			) { $0 }
		}

		switch query {
		case let .query(query):
			return query
				.predicates
				.map(\.dictionary)
				.reduce(base) {
					$0.argument(
						key: "where",
						value: $1.named
					)
				}
		case let .mutation(mutation):
			return arguments(for: mutation, returning: Fields.self)
				.reduce(base) {
					$0.argument(
						key: $1.0,
						value: $1.1
					)
				}
		}
	}

	func name<Fields: Catena.Fields>(of query: GraphQL.Query<Fields>) -> String {
		let tableName = Fields.Model.schema.name
		switch query {
		case .query:
			return tableName
		case let .mutation(mutation):
			let name = "\(mutation)_\(tableName)"
			switch mutation {
			case .insert(_, false):
				return "\(name)_one"
			case .update(.primaryKey, _), .delete(.primaryKey):
				return "\(name)_by_pk"
			default:
				return "\(name)"
			}
		}
	}

	func arguments<Fields: Catena.Fields>(for mutation: GraphQL.Query<Fields>.Mutation, returning fieldsType: Fields.Type) -> [String: ArgumentValueRepresentable] {
		let empty: [String: ArgumentValueRepresentable] = [:]
		switch mutation {
		case let .insert(models, many):
			if many {
				return ["objects": models.map(\.identifiedValueSet.dictionary)]
			} else {
				return ["object": models.first!.identifiedValueSet.dictionary]
			}
		case .update:
			return [
				"where": empty,
				"_set": empty
			]
		case let .delete(selector):
			switch selector {
			case let .primaryKey(id):
				return (\Fields.Model.id == id).dictionary.compactMapValues {
					($0 as? [String: Any])?.values.first as? ArgumentValueRepresentable
				}
			case let .predicate(predicate):
				return [
					"where": predicate.map {
						$0.dictionary.compactMapValues {
							($0 as? [String: Any])?.named
						}
					} ?? [:]
				]
			}
		}
	}
}

// MARK: -
private extension OperationType {
	init<Fields>(_ query: GraphQL.Query<Fields>) {
		switch query {
		case .query:
			self = .query
		case .mutation:
			self = .mutation
		}
	}
}

// MARK: -
private extension String {
	var operatorName: String {
		switch self {
		case "==":
			return "_eq"
		case "NOT":
			return "_not"
		case "IN":
			return "_in"
		default:
			return self
		}
	}
}

// MARK: -
private extension [String] {
	func objectWeavable<Fields>(for query: GraphQL.Query<Fields>) -> ObjectWeavable {
		let head = self[0]
		let tail = Array(self[1...])
		let weavable: ObjectWeavable = (count == 1) ? Field(head) : Object(head) {
			tail.objectWeavable(for: query)
		}

		switch query {
		case .query, .mutation(.insert(_, false)), .mutation(.update(.primaryKey, _)), .mutation(.delete(.primaryKey)):
			return weavable
		default:
			return Object("returning") { weavable }
		}
	}
}

// MARK: -
private extension [String: Any] {
	var named: Self {
		.init(
			uniqueKeysWithValues: map { key, value in
				value as? [String: String] == ["IS": "(null)"] ?
					("_not", [key: [:]]) :
					(key.operatorName, (value as? [String: Any])?.named ?? value)
			}
		)
	}
}
