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
        XCTAssertEqual("1.100.3".version!, Semver(major: "1", minor:"100", patch:"3"))
        XCTAssertNotEqual("1.100.3".version!, "1.101.3".version!)
        // Big number
        XCTAssertEqual("69938113471411635120691317071569414.452.368".version!, Semver(major: "69938113471411635120691317071569414", minor:"452", patch:"368"))
        XCTAssertNotEqual("69938113471411635120691317071569414.452.36".version!, "69938113471411635120691317071569414.452.368".version!)
        // prefixed
        XCTAssertEqual("semver.1.100.3".version!, Semver(major: "1", minor:"100", patch:"3"))
        XCTAssertNotEqual("semver.1.100.3".version!, "semver.2.100.3".version!)
    }

    func testEqualPrefixedVersion() {
        XCTAssertEqual("semver.1.100.3".version!, "v1.100.3".version!)
        XCTAssertEqual("semver.1.100.3-rc.1".version!, "ver1.100.3-rc.1".version!)
    }

    func testEqualPrereleaseVersion() {
        XCTAssertEqual("1.100.3-rc.1".version!, Semver(major: "1", minor:"100", patch:"3", prereleaseIdentifiers:["rc", "1"]))
        XCTAssertNotEqual("1.100.3-rc.1".version!, "1.101.3-rc.2".version!)
        XCTAssertNotEqual("1.100.3-alpha".version!, "1.101.3-beta".version!)
        XCTAssertNotEqual("1.100.3-rc.a".version!, "1.101.3-rc.1".version!)
    }

    func testEqualBuildmetadataVersion() {
        XCTAssertEqual("1.101.345+build.sha.111".version!, Semver(major: "1", minor:"101", patch:"345"))
        XCTAssertEqual("1.101.345+build.sha.111".version!, "1.101.345+test.metadata".version!)
        XCTAssertEqual("1.101.345-rc.1+build.sha.111".version!, "1.101.345-rc.1+test.metadata".version!)
        XCTAssertNotEqual("1.101.345-rc.1+build.sha.111".version!, "1.101.345-rc.2+build.sha.111".version!)
    }

    func testCompareBasicVersion() {
        // Compare Major
        XCTAssertLessThan("1.100.0".version!, "2.0.0".version!)
        // Compare Minor
        XCTAssertLessThan("1.99.231".version!, "1.101.12344".version!)
        // Compare Patch
        XCTAssertLessThan("1.99.231".version!, "1.99.12344".version!)
    }

    func testCompareBasicAndPrereleaseVersion() {
        XCTAssertLessThan("1.99.231-alpha".version!, "1.99.231".version!)
    }

    func testComparePrereleaseVersion() {
        // alphabetical order
        XCTAssertLessThan("1.99.231-test.alpha".version!, "1.99.231-test.beta".version!)
        XCTAssertLessThan("1.99.231-test.19b".version!, "1.99.231-test.alpha".version!)

        // numeric < non-numeric
        XCTAssertLessThan("1.99.231-test.2".version!, "1.99.231-test.19b".version!)

        // smaller-set < larger-set
        XCTAssertLessThan("1.99.231-alpha.beta".version!, "1.99.231-alpha.beta.11".version!)
    }
}
