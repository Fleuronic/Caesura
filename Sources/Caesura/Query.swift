// Copyright © Fleuronic LLC. All rights reserved.

import Schemata
import struct Catenary.Query
import struct Catenary.Schema
import struct Catenary.ArgumentList
import protocol Catena.Fields
import protocol Catenary.Fields
import protocol Catenary.Clause
import protocol Catenary.Schematic

public struct Query<
	Schematic: Catenary.Schematic,
	Fields: ModelProjection
> where Fields.Model: Model {
    let name: ((String) -> String)?
    let fieldsName: String?
    let argumentList: ArgumentList?

    init(
        name: ((String) -> String)? = nil,
        fieldsName: String? = nil,
        limit: Int? = nil,
        offset: Int? = nil,
        object: Object? = nil,
        objects: Objects? = nil,
        where: Where? = nil
    ) {
        self.name = name
        self.fieldsName = fieldsName

        var argumentList = ArgumentList()
        `where`.map { argumentList.append($0) }
        object.map { argumentList.append($0) }
        objects.map { argumentList.append($0) }
        limit.map { argumentList.append(Limit($0)) }
        offset.map { argumentList.append(Offset($0)) }

        self.argumentList = argumentList
    }
}

// MARK: -
extension Query: Encodable {
	public func encode(to encoder: any Encoder) throws {
		let keyPaths = Fields.projection.keyPaths
		let schemaName = Fields.Model.schemaName
		let query = Catenary.Query<Schematic>(
			name: name?(schemaName) ?? schemaName,
			type: name == nil ? .query : .mutation,
			argumentList: argumentList,
            keyPaths: keyPaths,
			fieldsName: fieldsName
		)

        try query.encode(to: encoder)
	}
}
