// Copyright © Fleuronic LLC. All rights reserved.

import Papyrus
import struct Catenary.Response

@API @Mock
public protocol Endpoint {
    @POST("")
	func run<T, Fields>(_ query: Field<Query<T, Fields>>) async throws -> Response<Fields>
}
