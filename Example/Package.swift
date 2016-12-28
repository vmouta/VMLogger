import PackageDescription

let package = Package(
    name: "VMLogger_Example",
    targets: [],
    dependencies: [
        .Package(url: "https://github.com/vmouta/VMLogger.git",
                 majorVersion: 0)
    ],
    exclude: ["Tests"]
)
