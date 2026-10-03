// swift-tools-version: 6.1

import PackageDescription

let package = Package(
  name: "Rodd",
  platforms: [
    .macOS(.v14)
  ],
  products: [
    .executable(name: "Rodd", targets: ["RoddApp"])
  ],
  targets: [
    .target(
      name: "RoddKit",
      path: ".",
      exclude: [
        "app/App",
        "app/Tests",
        "app/Checks",
        "app/Resources",
        "BACKLOG.md",
        "Changelog.md",
        "README.md",
        "content/README.md",
        "docs",
        "schemas",
        "scripts",
        "tests",
      ],
      sources: ["app/Sources/RoddApp"],
      resources: [
        .copy("content/prayer-packs/sigrdrifumal-west-norse-ca-1200")
      ]
    ),
    .executableTarget(
      name: "RoddApp",
      dependencies: ["RoddKit"],
      path: "app/App/RoddApp"
    ),
    .testTarget(
      name: "RoddAppTests",
      dependencies: ["RoddKit"],
      path: "app/Tests/RoddAppTests",
      swiftSettings: [
        .unsafeFlags([
          "-F", "/Library/Developer/CommandLineTools/Library/Developer/Frameworks",
        ])
      ],
      linkerSettings: [
        .linkedFramework("Testing"),
        .unsafeFlags([
          "-F", "/Library/Developer/CommandLineTools/Library/Developer/Frameworks",
          "-Xlinker", "-rpath",
          "-Xlinker", "/Library/Developer/CommandLineTools/Library/Developer/Frameworks",
          "-Xlinker", "-rpath",
          "-Xlinker", "/Library/Developer/CommandLineTools/Library/Developer/usr/lib",
        ]),
      ]
    ),
    .executableTarget(
      name: "RoddChecks",
      dependencies: ["RoddKit"],
      path: "app/Checks/RoddChecks",
      swiftSettings: [
        .unsafeFlags([
          "-F", "/Library/Developer/CommandLineTools/Library/Developer/Frameworks",
        ])
      ],
      linkerSettings: [
        .linkedFramework("Testing"),
        .unsafeFlags([
          "-F", "/Library/Developer/CommandLineTools/Library/Developer/Frameworks",
          "-Xlinker", "-rpath",
          "-Xlinker", "/Library/Developer/CommandLineTools/Library/Developer/Frameworks",
          "-Xlinker", "-rpath",
          "-Xlinker", "/Library/Developer/CommandLineTools/Library/Developer/usr/lib",
        ]),
      ]
    ),
  ]
)
