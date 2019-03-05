//
//  Semver+Parser.swift
//  Semver
//
//  Created by Nate Kim on 21/01/2019.
//  Copyright © 2019 glwithu06. All rights reserved.
//

import Foundation

internal let dotDelimiter = "."
internal let prereleaseDelimiter = "-"
internal let buildMetaDataDelimiter = "+"

extension Semver {
    public enum ParsingError: Error {
        public enum Component {
            case major, minor, patch, prereleaseIdentifiers, buildMetadataIdentifiers
        }
        case malformedString(String, Error?)
        case digitsNotFound(String)
        case parseError(Component, Error)

        var localizedDescription: String {
            switch self {
            case .malformedString(let version, let e):
                return "malformed \"\(version)\"\t\(e.map { "\nInfo)" + $0.localizedDescription } ?? "")"
            case .digitsNotFound(let version):
                return "no digits in \(version)"
            case .parseError(let component, let e):
                return "\(component) error: \(e.localizedDescription)"
            }
        }
    }

    static internal func parse(_ input: String) throws -> Semver {
        let major: String
        let minor: String
        let patch: String
        let prereleaseIdentifiers: [String]
        let buildMetadataIdentifiers: [String]
        let extra: String

        let validateRegex = try NSRegularExpression(pattern: "^([0-9A-Za-z|\\\(prereleaseDelimiter)|\\\(dotDelimiter)|\\\(buildMetaDataDelimiter)]+)$")
        guard input.rangeOfFirstMatch(for: validateRegex).length == input.count else {
            throw ParsingError.malformedString(input, nil)
        }

        let scanner = Scanner(string: input)
        let prefix = scanner.scanUpToCharacters(from: CharacterSet.decimalDigits)
        guard prefix != "-" else { throw ParsingError.malformedString(input, nil) }

        let delimiterCharacterSet = CharacterSet(charactersIn: "\(prereleaseDelimiter)\(buildMetaDataDelimiter)")
        guard let versionStr = scanner.scanUpToCharacters(from: delimiterCharacterSet) else {
            throw ParsingError.malformedString(input, nil)
        }

        let versionScanner = Scanner(string: versionStr)
        guard let majorStr = versionScanner.scanCharacters(from: CharacterSet.decimalDigits) else {
            throw ParsingError.digitsNotFound(input)
        }
        major = majorStr

        func scanNextVersion(_ scanner: Scanner) throws -> String {
            guard !scanner.isAtEnd else {
                return "0"
            }
            scanner.scanString(dotDelimiter, into: nil)
            guard let digits = scanner.scanCharacters(from: CharacterSet.decimalDigits) else {
                throw ParsingError.digitsNotFound(scanner.string)
            }
            return digits
        }
        minor = try scanNextVersion(versionScanner)
        patch = try scanNextVersion(versionScanner)

        let scanIndex = String.Index(encodedOffset: scanner.scanLocation)
        extra = String(input[scanIndex...])
        do {
            let prereleaseRegex = try NSRegularExpression(pattern: "(?<=\(prereleaseDelimiter))([0-9A-Za-z-\\\(dotDelimiter)]+)")
            prereleaseIdentifiers = Range(extra.rangeOfFirstMatch(for: prereleaseRegex), in: extra)
                .map { String(extra[$0]) }
                .map { $0.components(separatedBy: dotDelimiter) }
                ?? []
        } catch let e {
            throw ParsingError.parseError(.prereleaseIdentifiers, e)
        }

        do {
            let buildMetadataRegex = try NSRegularExpression(pattern: "(?<=\\\(buildMetaDataDelimiter))([0-9A-Za-z-\\\(dotDelimiter)]+)")
            buildMetadataIdentifiers = Range(extra.rangeOfFirstMatch(for: buildMetadataRegex), in: extra)
                .map { String(extra[$0]) }
                .map { $0.components(separatedBy: dotDelimiter) }
                ?? []
        } catch let e {
            throw ParsingError.parseError(.buildMetadataIdentifiers, e)
        }

        let prerelease = prereleaseIdentifiers.count > 0 ? prereleaseDelimiter + prereleaseIdentifiers.joined(separator: dotDelimiter) : ""
        let metadata = buildMetadataIdentifiers.count > 0 ? buildMetaDataDelimiter + buildMetadataIdentifiers.joined(separator: dotDelimiter) : ""
        guard extra.replacingOccurrences(of: prerelease, with: "").replacingOccurrences(of: metadata, with: "").count == 0 else {
            throw ParsingError.malformedString(input, nil)
        }

        return Semver(major: major,
                      minor: minor,
                      patch: patch,
                      prereleaseIdentifiers: prereleaseIdentifiers,
                      buildMetadataIdentifiers: buildMetadataIdentifiers)
    }

    public init(_ version: String) throws {
        self = try Semver.parse(version)
    }

    public init<T: Numeric>(_ version: T) throws {
        self = try Semver.parse("\(version)")
    }
}

extension Bundle {
    public var version: Semver? {
        if let bundleVersion = self.infoDictionary?["CFBundleShortVersionString"] as? String {
            return try? Semver(bundleVersion)
        } else {
            return nil
        }
    }
}

extension String {

    fileprivate func rangeOfFirstMatch(for regex: NSRegularExpression) -> NSRange {
        return regex.rangeOfFirstMatch(in: self, range: NSRange(location: 0, length: self.count))
    }

    internal func firstMatch(for regex: NSRegularExpression) -> String? {
        return regex.firstMatch(in: self, range: NSRange(location: 0, length: self.count))
            .map { Range($0.range, in: self)! }
            .map { String(self[$0]) }
    }
}

extension Scanner {

    fileprivate func scanUpToCharacters(from: CharacterSet) -> String? {
        var str: NSString?
        scanUpToCharacters(from: from, into: &str)
        return str as String?
    }

    fileprivate func scanCharacters(from: CharacterSet) -> String? {
        var str: NSString?
        scanCharacters(from: from, into: &str)
        return str as String?
    }
}
