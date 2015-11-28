//
//  Linter.swift
//  SwiftLint
//
//  Created by JP Simard on 2015-05-16.
//  Copyright (c) 2015 Realm. All rights reserved.
//

import Foundation
import SwiftXPC
import SourceKittenFramework

private func correctableRules() -> [CorrectableRule] {
    return [
        TrailingNewlineRule(),
        TrailingSemicolonRule(),
        TrailingWhitespaceRule()
    ]
}

public struct Linter {
    private let file: File
    private let rules: [Rule]
    public let reporter: Reporter.Type

    public var styleViolations: [StyleViolation] {
        let regions = file.regions()
        return rules.flatMap { rule in
            return rule.validateFile(self.file).filter { violation in
                guard let violationRegion = regions.filter({ $0.contains(violation.location) })
                                                   .first else {
                    return true
                }
                return violationRegion.isRuleEnabled(rule)
            }
        }
    }

    public init(file: File, configuration: Configuration = Configuration()!) {
        self.file = file
        rules = configuration.rules
        reporter = configuration.reporterFromString
    }

    public func correct() -> [Correction] {
        var corrections = [Correction]()
        let enabledRules = correctableRules().filter { correctableRule in
            let description = correctableRule.dynamicType.description
            return rules.map({ $0.dynamicType.description }).contains(description)
        }
        for rule in enabledRules {
            corrections += rule.correctFile(file)
        }
        return corrections
    }
}
