//
//  LocalizedUppercaseRule.swift
//  
//
//  Created by Dean Silfen on 3/9/23.
//

import Foundation
import IDEUtils
import SwiftSyntax

struct LocalizedUppercaseRule: SwiftSyntaxRule, ConfigurationProviderRule, OptInRule {
    var configuration = SeverityConfiguration(.warning)

    init() {}

    static let description = RuleDescription(
        identifier: "local_uppcase",
        name: "Prefer Localized Uppercase",
        description: "Prefer localized uppercase to using normal uppercase when strings may end up in the UI.",
        kind: .lint,
        nonTriggeringExamples: [
            Example("""
            label.text = "yell your truth".localizedUppercase()
            """)
        ],
        triggeringExamples: [
            Example("""
                                          ↓/// uppercase function should not be used for strings when they may end up in the UI
            label.text = "yell your truth".uppercase()
            """)
        ]
    )

    func makeVisitor(file: SwiftLintFile) -> ViolationsSyntaxVisitor {
        Visitor(viewMode: .sourceAccurate)
    }
}

private extension LocalizedUppercaseRule {
    final class Visitor: ViolationsSyntaxVisitor {
        override func visitPost(_ node: FunctionCallExprSyntax) {
            let expr = node.calledExpression.as(MemberAccessExprSyntax.self)
            if expr?.name.text == "uppercase" {
                violations.append(node.positionAfterSkippingLeadingTrivia)
            }
        }
    }
}
