// Copyright © Fleuronic LLC. All rights reserved.

import struct Catenary.Schema
import protocol Schemata.Model

public extension Schema {
    init<each T: Model>(_ types: repeat (each T).Type)  {
        var components: Set<Schema.Component> = []
        for type in repeat each types {
            components.formUnion(
                type.schema.properties.map { keyPath, property in
                    let path = switch property.type {
                    case let .toMany(type): type.anySchema.name
                    default: property.path
                    }

                    return (keyPath, [path])
                }.map(Schema.Component.init)
            )
        }

        self.init(components: components)
    }
}
