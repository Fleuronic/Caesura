// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "Caesura",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "Caesura",
            targets: [
				"Caesura"
			]
		)
    ],
    dependencies: [
        .package(url: "https://github.com/Fleuronic/Catenary", branch: "main"),
        .package(url: "https://github.com/NicholasBellucci/SociableWeaver.git", from: "0.1.0")
    ],
    targets: [
        .target(
            name: "Caesura",
			dependencies: [
				"Catenary",
				"SociableWeaver"
			]
		)
    ]
)
