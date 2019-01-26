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

    func testEqualBasicVersion() {
        XCTAssertEqual(try Semver(version: "1.100.3"), Semver(major: "1", minor: "100", patch: "3"))
        XCTAssertNotEqual(try Semver(version: "1.100.3"), try Semver(version: "1.101.3"))
        // Big number
        XCTAssertEqual(try Semver(version: "69938113471411635120691317071569414.452.368"),
                       Semver(major: "69938113471411635120691317071569414", minor: "452", patch: "368"))
        XCTAssertNotEqual(try Semver(version: "69938113471411635120691317071569414.452.36"),
                          try Semver(version: "69938113471411635120691317071569414.452.368"))
        // prefixed
        XCTAssertEqual(try Semver(version: "semver.1.100.3"), Semver(major: "1", minor: "100", patch: "3"))
        XCTAssertNotEqual(try Semver(version: "semver.1.100.3"), try Semver(version: "semver.2.100.3"))
    }

    func testEqualPrefixedVersion() {
        XCTAssertEqual(try Semver(version: "semver.1.100.3"), try Semver(version: "v1.100.3"))
        XCTAssertEqual(try Semver(version: "semver.1.100.3-rc.1"), try Semver(version: "ver1.100.3-rc.1"))
    }

    func testEqualPrereleaseVersion() {
        XCTAssertEqual(try Semver(version: "1.100.3-rc.1"), Semver(major: "1", minor: "100", patch: "3", prereleaseIdentifiers: ["rc", "1"]))
        XCTAssertNotEqual(try Semver(version: "1.100.3-rc.1"), try Semver(version: "1.101.3-rc.2"))
        XCTAssertNotEqual(try Semver(version: "1.100.3-alpha"), try Semver(version: "1.101.3-beta"))
        XCTAssertNotEqual(try Semver(version: "1.100.3-rc.a"), try Semver(version: "1.101.3-rc.1"))
    }

    func testEqualBuildmetadataVersion() {
        XCTAssertEqual(try Semver(version: "1.101.345+build.sha.111"), Semver(major: "1", minor: "101", patch: "345"))
        XCTAssertEqual(try Semver(version: "1.101.345+build.sha.111"), try Semver(version: "1.101.345+test.metadata"))
        XCTAssertEqual(try Semver(version: "1.101.345-rc.1+build.sha.111"), try Semver(version: "1.101.345-rc.1+test.metadata"))
        XCTAssertNotEqual(try Semver(version: "1.101.345-rc.1+build.sha.111"), try Semver(version: "1.101.345-rc.2+build.sha.111"))
    }

    func testCompareBasicVersion() {
        // Compare Major
        XCTAssertLessThan(try Semver(version: "1.100.0"), try Semver(version: "2.0.0"))
        // Compare Minor
        XCTAssertLessThan(try Semver(version: "1.99.231"), try Semver(version: "1.101.12344"))
        // Compare Patch
        XCTAssertLessThan(try Semver(version: "1.99.231"), try Semver(version: "1.99.12344"))
        // Ignore build metadata
        XCTAssertEqual(try Semver(version: "1.99.231+b"), try Semver(version: "1.99.231+a"))
    }

    func testCompareBasicAndPrereleaseVersion() {
        XCTAssertLessThan(try Semver(version: "1.99.231-alpha"), try Semver(version: "1.99.231"))
    }

    func testComparePrereleaseVersion() {
        // alphabetical order
        XCTAssertLessThan(try Semver(version: "1.99.231-test.alpha"), try Semver(version: "1.99.231-test.beta"))
        XCTAssertLessThan(try Semver(version: "1.99.231-test.19b"), try Semver(version: "1.99.231-test.alpha"))

        // numeric < non-numeric
        XCTAssertLessThan(try Semver(version: "1.99.231-test.2"), try Semver(version: "1.99.231-test.19b"))

        // smaller-set < larger-set
        XCTAssertLessThan(try Semver(version: "1.99.231-alpha.beta"), try Semver(version: "1.99.231-alpha.beta.11"))

        // Ignore build metatdata
        XCTAssertEqual(try Semver(version: "1.99.231-alpha.beta+b"), try Semver(version: "1.99.231-alpha.beta+a"))
    }

    func testVersionToString() throws {
        let version = try Semver(version: "1.101.345-rc.alpha.11+build.sha.111.extended")

        XCTAssertEqual("1.101.345", version.toString(style: .short))
        XCTAssertEqual("1.101.345-rc.alpha.11", version.toString(style: .comparable))
        XCTAssertEqual("1.101.345-rc.alpha.11+build.sha.111.extended", version.toString(style: .full))
        XCTAssertEqual("1.101.345-rc.alpha.11+build.sha.111.extended", version.toString())
    }
}
