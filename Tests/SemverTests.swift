//
//  SemverTests.swift
//  SemverTests
//
//  Created by Nate Kim on 22/01/2019.
//  Copyright © 2019 glwithu06. All rights reserved.
//

import XCTest
@testable import Semver

class SemverTests: XCTestCase {

    func testSemverConstructor() {
        let ver = Semver(major: 1, minor: 452, patch: 368,
                         prereleaseIdentifiers: ["rc", "alpha", "11", "log-test"], buildMetadataIdentifiers: ["sha", "exp", "5114f85", "20190121"])

        XCTAssertEqual(ver.major, "1")
        XCTAssertEqual(ver.minor, "452")
        XCTAssertEqual(ver.patch, "368")
        XCTAssertEqual(ver.prereleaseIdentifiers.count, 4)
        XCTAssertEqual(ver.prereleaseIdentifiers[0], "rc")
        XCTAssertEqual(ver.prereleaseIdentifiers[1], "alpha")
        XCTAssertEqual(ver.prereleaseIdentifiers[2], "11")
        XCTAssertEqual(ver.prereleaseIdentifiers[3], "log-test")
        XCTAssertEqual(ver.buildMetadataIdentifiers.count, 4)
        XCTAssertEqual(ver.buildMetadataIdentifiers[0], "sha")
        XCTAssertEqual(ver.buildMetadataIdentifiers[1], "exp")
        XCTAssertEqual(ver.buildMetadataIdentifiers[2], "5114f85")
        XCTAssertEqual(ver.buildMetadataIdentifiers[3], "20190121")
    }

    func testEqualBasicVersion() {
        XCTAssertEqual(try Semver("1.100.3"), Semver(major: "1", minor: "100", patch: "3"))
        XCTAssertNotEqual(try Semver("1.100.3"), try Semver("1.101.3"))
        // Big number
        XCTAssertEqual(try Semver("69938113471411635120691317071569414.452.368"),
                       Semver(major: "69938113471411635120691317071569414", minor: "452", patch: "368"))
        XCTAssertNotEqual(try Semver("69938113471411635120691317071569414.452.36"),
                          try Semver("69938113471411635120691317071569414.452.368"))
        // prefixed
        XCTAssertEqual(try Semver("semver.1.100.3"), Semver(major: "1", minor: "100", patch: "3"))
        XCTAssertNotEqual(try Semver("semver.1.100.3"), try Semver("semver.2.100.3"))
    }

    func testEqualPrefixedVersion() {
        XCTAssertEqual(try Semver("semver.1.100.3"), try Semver("v1.100.3"))
        XCTAssertEqual(try Semver("semver.1.100.3-rc.1"), try Semver("ver1.100.3-rc.1"))
    }

    func testEqualPrereleaseVersion() {
        XCTAssertEqual(try Semver("1.100.3-rc.1"), Semver(major: "1", minor: "100", patch: "3", prereleaseIdentifiers: ["rc", "1"]))
        XCTAssertNotEqual(try Semver("1.100.3-rc.1"), try Semver("1.100.3-rc.2"))
        XCTAssertNotEqual(try Semver("1.100.3-rc.1"), try Semver("1.100.3-rc.1.2.3"))
        XCTAssertNotEqual(try Semver("1.100.3-alpha"), try Semver("1.100.3-beta"))
        XCTAssertNotEqual(try Semver("1.100.3-rc.a"), try Semver("1.100.3-rc.1"))
    }

    func testEqualBuildmetadataVersion() {
        XCTAssertEqual(try Semver("1.101.345+build.sha.111"), Semver(major: "1", minor: "101", patch: "345"))
        XCTAssertEqual(try Semver("1.101.345+build.sha.111"), try Semver("1.101.345+test.metadata"))
        XCTAssertEqual(try Semver("1.101.345-rc.1+build.sha.111"), try Semver("1.101.345-rc.1+test.metadata"))
        XCTAssertNotEqual(try Semver("1.101.345-rc.1+build.sha.111"), try Semver("1.101.345-rc.2+build.sha.111"))
    }

    func testCompareBasicVersion() {
        // Compare Major
        XCTAssertLessThan(try Semver("1.100.0"), try Semver("2.0.0"))
        // Compare Minor
        XCTAssertLessThan(try Semver("1.99.231"), try Semver("1.101.12344"))
        // Compare Patch
        XCTAssertLessThan(try Semver("1.99.231"), try Semver("1.99.12344"))
        // Ignore build metadata
        XCTAssertEqual(try Semver("1.99.231+b"), try Semver("1.99.231+a"))
    }

    func testCompareBasicAndPrereleaseVersion() {
        XCTAssertLessThan(try Semver("1.99.231-alpha"), try Semver("1.99.231"))
    }

    func testComparePrereleaseVersion() {
        // alphabetical order
        XCTAssertLessThan(try Semver("1.99.231-test.alpha"), try Semver("1.99.231-test.beta"))
        XCTAssertLessThan(try Semver("1.99.231-test.19b"), try Semver("1.99.231-test.alpha"))

        // numeric order
        XCTAssertLessThan(try Semver("1.99.231-test.1.2"), try Semver("1.99.231-test.1.3"))

        // numeric < non-numeric
        XCTAssertLessThan(try Semver("1.99.231-test.2"), try Semver("1.99.231-test.19b"))

        // smaller-set < larger-set
        XCTAssertLessThan(try Semver("1.99.231-alpha.beta"), try Semver("1.99.231-alpha.beta.11"))

        // Ignore build metatdata
        XCTAssertEqual(try Semver("1.99.231-alpha.beta+b"), try Semver("1.99.231-alpha.beta+a"))
    }

    func testVersionToString() throws {
        let version = try Semver("1.101.345-rc.alpha.11+build.sha.111.extended")

        XCTAssertEqual("1.101.345", version.toString(style: .compact))
        XCTAssertEqual("1.101.345-rc.alpha.11", version.toString(style: .comparable))
        XCTAssertEqual("1.101.345-rc.alpha.11+build.sha.111.extended", version.toString(style: .full))
        XCTAssertEqual("1.101.345-rc.alpha.11+build.sha.111.extended", version.toString())
    }
}
