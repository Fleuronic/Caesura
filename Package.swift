// swift-tools-version:5.7
import PackageDescription

let package = Package(
	name: "Caesura",
	platforms: [
		.iOS(.v13),
		.macOS(.v10_15),
		.tvOS(.v13),
		.watchOS(.v6)
	],
	products: [
		.library(
			name: "Caesura",
			targets: ["Caesura"]
		)
	],
	dependencies: [
		.package(url: "https://github.com/Fleuronic/Catenary", branch: "main"),
		.package(url: "https://github.com/Fleuronic/Catenoid", branch: "main"),
		.package(url: "https://github.com/jordanekay/papyrus", branch: "main")
	],
	targets: [
		.target(
			name: "Caesura",
			dependencies: [
				"Catenary",
				"Catenoid",
				.product(name: "Papyrus", package: "papyrus")
			]
		)
    ]
)
