# Semantic Versioning

Semantic Versioning implementation in Swift.
`Semver` represent a semantic version according to the [Semantic Versioning Specification](http://semver.org/spec/v2.0.0.html).

## Requirements

* Xcode 10.1+
* Swift 4.2
* iOS 8
* macOS 10.11
* tvOS 9.0
* watchOS 2.0

## Installation

`Semver` doesn't contain any external dependencies.
These are currently support options:

### Cocoapods
```
# Podfile
user_framework!
target 'YOUR_TARGET_NAME' do
    pod 'Semver.swift'
end
```
Replace `YOUR_TARGET_NAME` and then, in the `Podfile` directory, type:
```
$ pod install
```

### Swift Package Manager

Create a `Package.swift` file.
```Swift
// swift-tools-version:4.2

import PackageDescription

let package = Package(
  name: "NAME",
  dependencies: [
    .package(url: "https://github.com/glwithu06/Semver.swift.git", "1.0.0")
  ],
  targets: [
    .target(name: "NAME", dependencies: ["Semver"])
  ]
)
```
Then type:
```
$ swift build
```

### Manually using gitsubmodules

* Add Semver as a submodule
```
$ git submodule add git@github.com:glwithu06/Semver.swift.git
```
* Generate Semver.xcodeproj

```
$ swift package generate-xcodeproj
```
* Drag `Semver.xcodeproj` into Project Navigator
* Go to `Project > Targets > Build Phases > Link Binary With Libraries`, click `+` and selecte `Semver` targets 

## Usage

### Create

`Semver` can be instantiated directly:

```Swift
let version = Semver(major: "1", minor: "23", patch: "45", prereleaseIdentifiers: ["rc", "1"], buildMetadataIdentifiers: ["B001"])

```
or

```Swift
let version = Semver(major: 1, minor: 23, patch: 45, prereleaseIdentifiers: ["rc", "1"], buildMetadataIdentifiers: ["B001"])

```
`minor`, `patch` are optional parameters default to "0".

`prereleaseIdentifiers`, `buildMetadataIdentifiers` are optional parameters default to `[]`.


### Parse

You can create `Semver` from String.

```Swift
let version = try Semver("1.23.45-rc.1+B001")

```
or from Numeric.

```Swift
let version = try Semver(1.23)
```

```Swift
let version = try Semver(10)
```

If the version is invalid, it throws a `ParsingError`.

### Extensions

`Semver` conforms to `ExpressibleByStringLiteral`, `ExpressibleByIntegerLiteral`, `ExpressibleByFloatLiteral`.

It can convert a `String` to `Semver`.

```Swift
let version: Semver = "1.23.45-rc.1+B001"
```

or `Numeric` to `Semver`.

```Swift
let version: Semver = 1
```

```Swift
let version: Semver = 1.23
```

⚠️ If the version is invalid, `Semver` represents "0.0.0". It doesn't throw any errors.

### Compare

The default operators for comparsion are implemented(`<` , `<=` , `>` ,`>=` ,`==` , `!=`).

This will comapre major, minor, patch and the prerelease identifiers according to the [Semantic Versioning Specification](http://semver.org/spec/v2.0.0.html).

## Contribution
Any pull requests and bug reports are welcome!

Feel free to make a pull request.
