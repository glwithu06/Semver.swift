//
//  Semver+Parser.swift
//  Semver
//
//  Created by Nate Kim on 21/01/2019.
//  Copyright © 2019 glwithu06. All rights reserved.
//

import Foundation

extension Semver: ExpressibleByFloatLiteral {
    public init(floatLiteral value: FloatLiteralType) {
        self = (try? Semver(value)) ?? Semver(major: "0")
    }
}

extension Semver: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: IntegerLiteralType) {
        self = (try? Semver(value)) ?? Semver(major: "0")
    }
}

extension Semver: ExpressibleByStringLiteral {
    public init(stringLiteral value: StringLiteralType) {
        self = (try? Semver(value)) ?? Semver(major: "0")
    }
}
