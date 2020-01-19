//
//  ParserTests.swift
//  SemverTests
//
//  Created by Nate Kim on 21/01/2019.
//  Copyright © 2019 glwithu06. All rights reserved.
//

import Foundation
import XCTest
import Semver

class ParserTests: XCTestCase {

    func testParseBasicVersion() throws {
        let ver = try Semver(string: "1.452.368")

        XCTAssertEqual(ver.major, "1")
        XCTAssertEqual(ver.minor, "452")
        XCTAssertEqual(ver.patch, "368")
        XCTAssertEqual(ver.prereleaseIdentifiers, [])
        XCTAssertEqual(ver.buildMetadataIdentifiers, [])
    }

    func testParsePrereleaseVersion() throws {
        let ver = try Semver(string: "1.452.368-rc.alpha.11.log-test")

        XCTAssertEqual(ver.major, "1")
        XCTAssertEqual(ver.minor, "452")
        XCTAssertEqual(ver.patch, "368")
        XCTAssertEqual(ver.prereleaseIdentifiers.count, 4)
        XCTAssertEqual(ver.prereleaseIdentifiers[0], "rc")
        XCTAssertEqual(ver.prereleaseIdentifiers[1], "alpha")
        XCTAssertEqual(ver.prereleaseIdentifiers[2], "11")
        XCTAssertEqual(ver.prereleaseIdentifiers[3], "log-test")
        XCTAssertEqual(ver.buildMetadataIdentifiers, [])
    }

    func testParseBuildMetadataVersion() throws {
        let ver = try Semver(string: "1.452.368+sha.exp.5114f85.20190121.hyphen-test")

        XCTAssertEqual(ver.major, "1")
        XCTAssertEqual(ver.minor, "452")
        XCTAssertEqual(ver.patch, "368")
        XCTAssertEqual(ver.prereleaseIdentifiers, [])
        XCTAssertEqual(ver.buildMetadataIdentifiers.count, 5)
        XCTAssertEqual(ver.buildMetadataIdentifiers[0], "sha")
        XCTAssertEqual(ver.buildMetadataIdentifiers[1], "exp")
        XCTAssertEqual(ver.buildMetadataIdentifiers[2], "5114f85")
        XCTAssertEqual(ver.buildMetadataIdentifiers[3], "20190121")
        XCTAssertEqual(ver.buildMetadataIdentifiers[4], "hyphen-test")
    }

    func testParseBigNumberVersion() throws {
        let ver = try Semver(string: "69938113471411635120691317071569414.64537206108257636612034178144141277.47527207420859796686256474452275428")
        XCTAssertEqual(ver.major, "69938113471411635120691317071569414")
        XCTAssertEqual(ver.minor, "64537206108257636612034178144141277")
        XCTAssertEqual(ver.patch, "47527207420859796686256474452275428")
    }

    func testParseFullVersion() throws {
        let ver = try Semver(string: "69938113471411635120691317071569414.452.368-rc.alpha.11.log-test+sha.exp.5114f85.20190121.hyphen-test")

        XCTAssertEqual(ver.major, "69938113471411635120691317071569414")
        XCTAssertEqual(ver.minor, "452")
        XCTAssertEqual(ver.patch, "368")
        XCTAssertEqual(ver.prereleaseIdentifiers.count, 4)
        XCTAssertEqual(ver.prereleaseIdentifiers[0], "rc")
        XCTAssertEqual(ver.prereleaseIdentifiers[1], "alpha")
        XCTAssertEqual(ver.prereleaseIdentifiers[2], "11")
        XCTAssertEqual(ver.prereleaseIdentifiers[3], "log-test")
        XCTAssertEqual(ver.buildMetadataIdentifiers.count, 5)
        XCTAssertEqual(ver.buildMetadataIdentifiers[0], "sha")
        XCTAssertEqual(ver.buildMetadataIdentifiers[1], "exp")
        XCTAssertEqual(ver.buildMetadataIdentifiers[2], "5114f85")
        XCTAssertEqual(ver.buildMetadataIdentifiers[3], "20190121")
        XCTAssertEqual(ver.buildMetadataIdentifiers[4], "hyphen-test")
    }

    func testParsePrefixedVersion() throws {
        let ver = try Semver(string: "v001.452.368-rc.alpha.11.log-test")

        XCTAssertEqual(ver.major, "001")
        XCTAssertEqual(ver.minor, "452")
        XCTAssertEqual(ver.patch, "368")
        XCTAssertEqual(ver.prereleaseIdentifiers.count, 4)
        XCTAssertEqual(ver.prereleaseIdentifiers[0], "rc")
        XCTAssertEqual(ver.prereleaseIdentifiers[1], "alpha")
        XCTAssertEqual(ver.prereleaseIdentifiers[2], "11")
        XCTAssertEqual(ver.prereleaseIdentifiers[3], "log-test")
        XCTAssertEqual(ver.buildMetadataIdentifiers, [])
    }

    func testParseMajorOnlyVersion() throws {
        let ver = try Semver(string: "v1-rc.alpha.11.log-test")

        XCTAssertEqual(ver.major, "1")
        XCTAssertEqual(ver.minor, "0")
        XCTAssertEqual(ver.patch, "0")
        XCTAssertEqual(ver.prereleaseIdentifiers.count, 4)
        XCTAssertEqual(ver.prereleaseIdentifiers[0], "rc")
        XCTAssertEqual(ver.prereleaseIdentifiers[1], "alpha")
        XCTAssertEqual(ver.prereleaseIdentifiers[2], "11")
        XCTAssertEqual(ver.prereleaseIdentifiers[3], "log-test")
        XCTAssertEqual(ver.buildMetadataIdentifiers, [])
    }

    func testParseMajorMinorVersion() throws {
        let ver = try Semver(string: "v1.354-rc.alpha.11.log-test")

        XCTAssertEqual(ver.major, "1")
        XCTAssertEqual(ver.minor, "354")
        XCTAssertEqual(ver.patch, "0")
        XCTAssertEqual(ver.prereleaseIdentifiers.count, 4)
        XCTAssertEqual(ver.prereleaseIdentifiers[0], "rc")
        XCTAssertEqual(ver.prereleaseIdentifiers[1], "alpha")
        XCTAssertEqual(ver.prereleaseIdentifiers[2], "11")
        XCTAssertEqual(ver.prereleaseIdentifiers[3], "log-test")
        XCTAssertEqual(ver.buildMetadataIdentifiers, [])
    }

    func testParseInvalidVersion() {
        let invalidVersions = [
            "",
            "lorem ipsum",
            "0.a.0-pre+meta",
            "0.0.b-pre+meta",
            "0.0.0- +meta",
            "0.0.0-+meta",
            "0.0.0-+",
            "0.0.0-_+meta",
            "0.0.0-pre+_",
            "0.-100.3"
        ]
        for version in invalidVersions {
            XCTAssertThrowsError(try Semver(string: version))
        }
    }

    func testParseIntVersion() throws {
        let ver = try Semver(number: 1)

        XCTAssertEqual(ver.major, "1")
        XCTAssertEqual(ver.minor, "0")
        XCTAssertEqual(ver.patch, "0")
        XCTAssertEqual(ver.prereleaseIdentifiers, [])
        XCTAssertEqual(ver.buildMetadataIdentifiers, [])
    }

    func testParseNegativeIntVersion() throws {
        XCTAssertThrowsError(try Semver(number: -11))
    }

    func testParseFloatVersion() throws {
        let ver = try Semver(number: 1.5637881234)

        XCTAssertEqual(ver.major, "1")
        XCTAssertEqual(ver.minor, "5637881234")
        XCTAssertEqual(ver.patch, "0")
        XCTAssertEqual(ver.prereleaseIdentifiers, [])
        XCTAssertEqual(ver.buildMetadataIdentifiers, [])
    }

    func testParseStringVersion() throws {
        let ver = try Semver(string: "v001.452.368-rc.alpha.11.log-test")

        XCTAssertEqual(ver.major, "001")
        XCTAssertEqual(ver.minor, "452")
        XCTAssertEqual(ver.patch, "368")
        XCTAssertEqual(ver.prereleaseIdentifiers.count, 4)
        XCTAssertEqual(ver.prereleaseIdentifiers[0], "rc")
        XCTAssertEqual(ver.prereleaseIdentifiers[1], "alpha")
        XCTAssertEqual(ver.prereleaseIdentifiers[2], "11")
        XCTAssertEqual(ver.prereleaseIdentifiers[3], "log-test")
        XCTAssertEqual(ver.buildMetadataIdentifiers, [])
    }

    func testParseInvalidStringVersion() {
        let invalidVersions = [
            "",
            "lorem ipsum",
            "0.a.0-pre+meta",
            "0.0.b-pre+meta",
            "0.0.0- +meta",
            "0.0.0-+meta",
            "0.0.0-+",
            "0.0.0-_+meta",
            "0.0.0-pre+_",
            "0.-100.3"
        ]
        for version in invalidVersions {
            XCTAssertThrowsError(try Semver(string: version))
        }
    }

    func testParseExpressibleByIntegerLiteral() {
        let ver: Semver = 10

        XCTAssertEqual(ver.major, "10")
        XCTAssertEqual(ver.minor, "0")
        XCTAssertEqual(ver.patch, "0")
        XCTAssertEqual(ver.prereleaseIdentifiers, [])
        XCTAssertEqual(ver.buildMetadataIdentifiers, [])
    }

    func testParseInvalidExpressibleByIntegerLiteral() {
        let ver: Semver = -10

        XCTAssertEqual(ver.major, "0")
        XCTAssertEqual(ver.minor, "0")
        XCTAssertEqual(ver.patch, "0")
        XCTAssertEqual(ver.prereleaseIdentifiers, [])
        XCTAssertEqual(ver.buildMetadataIdentifiers, [])
    }

    func testParseExpressibleByFloatLiteral() {
        let ver: Semver = 10.346593

        XCTAssertEqual(ver.major, "10")
        XCTAssertEqual(ver.minor, "346593")
        XCTAssertEqual(ver.patch, "0")
        XCTAssertEqual(ver.prereleaseIdentifiers, [])
        XCTAssertEqual(ver.buildMetadataIdentifiers, [])
    }

    func testParseInavlidExpressibleByFloatLiteral() {
        let ver: Semver = -10.346593

        XCTAssertEqual(ver.major, "0")
        XCTAssertEqual(ver.minor, "0")
        XCTAssertEqual(ver.patch, "0")
        XCTAssertEqual(ver.prereleaseIdentifiers, [])
        XCTAssertEqual(ver.buildMetadataIdentifiers, [])
    }

    func testParseExpressibleByStringLiteral() {
        let ver: Semver = "69938113471411635120691317071569414.452.368-rc.alpha.11.log-test+sha.exp.5114f85.20190121.hyphen-test"

        XCTAssertEqual(ver.major, "69938113471411635120691317071569414")
        XCTAssertEqual(ver.minor, "452")
        XCTAssertEqual(ver.patch, "368")
        XCTAssertEqual(ver.prereleaseIdentifiers.count, 4)
        XCTAssertEqual(ver.prereleaseIdentifiers[0], "rc")
        XCTAssertEqual(ver.prereleaseIdentifiers[1], "alpha")
        XCTAssertEqual(ver.prereleaseIdentifiers[2], "11")
        XCTAssertEqual(ver.prereleaseIdentifiers[3], "log-test")
        XCTAssertEqual(ver.buildMetadataIdentifiers.count, 5)
        XCTAssertEqual(ver.buildMetadataIdentifiers[0], "sha")
        XCTAssertEqual(ver.buildMetadataIdentifiers[1], "exp")
        XCTAssertEqual(ver.buildMetadataIdentifiers[2], "5114f85")
        XCTAssertEqual(ver.buildMetadataIdentifiers[3], "20190121")
        XCTAssertEqual(ver.buildMetadataIdentifiers[4], "hyphen-test")
    }

    func testParseInavlidExpressibleByStringLiteral() {
        let ver: Semver = "0.a.0-pre+meta"

        XCTAssertEqual(ver.major, "0")
        XCTAssertEqual(ver.minor, "0")
        XCTAssertEqual(ver.patch, "0")
        XCTAssertEqual(ver.prereleaseIdentifiers, [])
        XCTAssertEqual(ver.buildMetadataIdentifiers, [])
    }
}
