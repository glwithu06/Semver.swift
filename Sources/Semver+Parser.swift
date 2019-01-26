//
//  Semver+Parser.swift
//  Semver
//
//  Created by Nate Kim on 21/01/2019.
//  Copyright © 2019 glwithu06. All rights reserved.
//

import Foundation

internal let dotDelimeter = "."
internal let prereleaseDelimeter = "-"
internal let buildMetaDataDelimeter = "+"

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
                return "There are no digits in \(version)"
            case .parseError(let component, let e):
                return "\(component) error: \(e.localizedDescription)"
            }
        }
    }

    static public func parse(_ input: String) throws -> Semver {
        let major: String
        let minor: String
        let patch: String
        let prereleaseIdentifiers: [String]
        let buildMetadataIdentifiers: [String]
        let extra: String

        let validateRegex = try NSRegularExpression(pattern: "^([0-9A-Za-z\(prereleaseDelimeter)\\\(dotDelimeter)|\\\(buildMetaDataDelimeter)]+)$")
        guard input.rangeOfFirstMatch(for: validateRegex).length == input.count else {
            throw ParsingError.malformedString(input, nil)
        }

        let scanner = Scanner(string: input)
        let prefix = scanner.scanUpToCharacters(from: CharacterSet.decimalDigits)
        guard prefix != "-" else { throw ParsingError.malformedString(input, nil) }

        let delimeterCharacterSet = CharacterSet(charactersIn: "\(prereleaseDelimeter)\(buildMetaDataDelimeter)")
        guard let versionStr = scanner.scanUpToCharacters(from: delimeterCharacterSet) else {
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
            scanner.scanString(dotDelimeter, into: nil)
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
            let prereleaseRegex = try NSRegularExpression(pattern: "(?<=\(prereleaseDelimeter))([0-9A-Za-z-\\.]+)")
            prereleaseIdentifiers = Range(extra.rangeOfFirstMatch(for: prereleaseRegex), in: extra)
                .map { String(extra[$0]) }
                .map { $0.components(separatedBy: dotDelimeter) }
                ?? []
        } catch let e {
            throw ParsingError.parseError(.prereleaseIdentifiers, e)
        }

        do {
            let buildMetadataRegex = try NSRegularExpression(pattern: "(?<=\\\(buildMetaDataDelimeter))([0-9A-Za-z-\\.]+)")
            buildMetadataIdentifiers = Range(extra.rangeOfFirstMatch(for: buildMetadataRegex), in: extra)
                .map { String(extra[$0]) }
                .map { $0.components(separatedBy: dotDelimeter) }
                ?? []
        } catch let e {
            throw ParsingError.parseError(.buildMetadataIdentifiers, e)
        }

        let prerelease = prereleaseIdentifiers.count > 0 ? prereleaseDelimeter + prereleaseIdentifiers.joined(separator: dotDelimeter) : ""
        let metadata = buildMetadataIdentifiers.count > 0 ? buildMetaDataDelimeter + buildMetadataIdentifiers.joined(separator: dotDelimeter) : ""
        guard extra.replacingOccurrences(of: prerelease, with: "").replacingOccurrences(of: metadata, with: "").count == 0 else {
            throw ParsingError.malformedString(input, nil)
        }

        return Semver(major: major,
                      minor: minor,
                      patch: patch,
                      prereleaseIdentifiers: prereleaseIdentifiers,
                      buildMetadataIdentifiers: buildMetadataIdentifiers)
    }

    public init(version: String) throws {
        self = try Semver.parse(version)
    }

    public init<T: Numeric>(version: T) throws {
        self = try Semver.parse("\(version)")
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
