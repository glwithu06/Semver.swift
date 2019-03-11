//
//  Semver.swift
//  Semver
//
//  Created by Nate Kim on 15/01/2019.
//  Copyright © 2019 glwithu06. All rights reserved.
//

import Foundation

/**
 * A struct that represent a semantic version according to [the Semantic Versioning Specification](https://semver.org/spec/v2.0.0.html).
 *
 * - Properties:
 *   - major: major in string.
 *   - minor: minor minor in string.
 *   - patch: patch in string.
 *   - prereleaseIdentifiers: dot separated list of pre-release identifiers.
 *   - buildMetadataIdentifiers: dot separated list of build metadata identifiers.
 */
public struct Semver: CustomStringConvertible, Comparable {

    public let major: String
    public let minor: String
    public let patch: String
    public let prereleaseIdentifiers: [String]
    public let buildMetadataIdentifiers: [String]
    public var description: String {
        return toString(style: .full)
    }

    internal init(major: String,
                minor: String = "0",
                patch: String = "0",
                prereleaseIdentifiers: [String] = [],
                buildMetadataIdentifiers: [String] = []) {
        self.major = major
        self.minor = minor
        self.patch = patch
        self.prereleaseIdentifiers = prereleaseIdentifiers
        self.buildMetadataIdentifiers = buildMetadataIdentifiers
    }

    /// Primary constructor to create Semver.
    ///
    /// - Parameters:
    ///   - major: major in number.
    ///   - minor: minor in number.
    ///   - patch: patch in number.
    ///   - prereleaseIdentifiers: dot separated list of pre-release identifiers.
    ///   - buildMetadataIdentifiers: dot separated list of build metadata identifiers.
    public init(major: UInt,
                minor: UInt = 0,
                patch: UInt = 0,
                prereleaseIdentifiers: [String] = [],
                buildMetadataIdentifiers: [String] = []) {
        self.init(
            major: "\(major)",
            minor: "\(minor)",
            patch: "\(patch)",
            prereleaseIdentifiers: prereleaseIdentifiers,
            buildMetadataIdentifiers: buildMetadataIdentifiers
        )
    }

    /// Returns a string representation of the `Semver`.
    ///
    /// - Parameter style: Specifies string representation Style.
    /// - Returns: a string representation of the Semver.
    public func toString(style: Style = .full) -> String {
        let version = [major, minor, patch].joined(separator: dotDelimiter)
        let prerelease = prereleaseIdentifiers.joined(separator: dotDelimiter)
        let buildMetadata = buildMetadataIdentifiers.joined(separator: dotDelimiter)
        switch style {
        case .full:
            return version
                + (prerelease.count > 0 ? "\(prereleaseDelimiter)\(prerelease)" : "")
                + (buildMetadata.count > 0 ? "\(buildMetaDataDelimiter)\(buildMetadata)" : "")
        case .comparable:
            return version
                + (prerelease.count > 0 ? "\(prereleaseDelimiter)\(prerelease)" : "")
        case .compact:
            return version
        }
    }
}

extension Semver {
    /// Specifies string representation style.
    ///
    /// - compact: Specifies a compact style, *Major.Minor.Patch* only
    /// - comparable: Specifies a COMPARABLE style, *Major.Minor.Patch-PreReleaseIdentifiers*
    /// - full: Specifies a FULL style, *Major.Minor.Patch-PreReleaseIdentifiers+BuildMetadataIdentifiers*
    public enum Style {
        /// Specifies a compact style, *Major.Minor.Patch* only, such as “1.2.3”.
        case compact
        /// Specifies a COMPARABLE style, *Major.Minor.Patch-PreReleaseIdentifiers*, such as “1.2.3-rc.1”.
        case comparable
        /// Specifies a FULL style, *Major.Minor.Patch-PreReleaseIdentifiers+BuildMetadataIdentifiers*, such as “1.2.3-rc.1+SHA.a0f21”.
        case full
    }
}

public func == (left: Semver, right: Semver) -> Bool {
    return  (left.major.compare(right.major, options: .numeric) == .orderedSame) &&
            (left.minor.compare(right.minor, options: .numeric) == .orderedSame) &&
            (left.patch.compare(right.patch, options: .numeric) == .orderedSame) &&
            (left.prereleaseIdentifiers.count == right.prereleaseIdentifiers.count) &&
            zip(left.prereleaseIdentifiers, right.prereleaseIdentifiers)
                .reduce(into: true, { (result, element) in
                    guard result == true else { return }

                    let (l, r) = element
                    switch (l.isNumber, r.isNumber) {
                    case (true, true):
                        result = (l.compare(r, options: .numeric) == .orderedSame)
                    case (false, false):
                        result = l == r
                    default:
                        result = false
                    }
                })
}

public func < (left: Semver, right: Semver) -> Bool {
    for (l, r) in zip([left.major, left.minor, left.patch],
                      [right.major, right.minor, right.patch]) where l != r {
        return l.compare(r, options: .numeric) == .orderedAscending
    }

    if left.prereleaseIdentifiers.count == 0 { return false }
    if right.prereleaseIdentifiers.count == 0 { return true }

    for (l, r) in zip(left.prereleaseIdentifiers, right.prereleaseIdentifiers) {
        switch (l.isNumber, r.isNumber) {
        case (true, true):
            let result = l.compare(r, options: .numeric)
            if result == .orderedSame {
                continue
            }
            return result == .orderedAscending
        case (true, false): return true
        case (false, true): return false
        default:
            if l == r {
                continue
            }
            return l < r
        }
    }

    return left.prereleaseIdentifiers.count < right.prereleaseIdentifiers.count
}

extension String {
    fileprivate var isNumber: Bool {
        guard let regex = try? NSRegularExpression(pattern: "[0-9]+") else { return false }
        return self.firstMatch(for: regex).map { $0 == self } ?? false
    }
}
