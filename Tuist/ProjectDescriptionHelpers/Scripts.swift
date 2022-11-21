//
//  Scripts.swift
//  ProjectDescriptionHelpers
//
//  Created by hong on 2022/11/19.
//

import ProjectDescription

public extension TargetScript {
    static let SwiftLintString = TargetScript.pre(script: """
if test -d "/opt/homebrew/bin/"; then
    PATH="/opt/homebrew/bin/:${PATH}"
fi

export PATH

if which swiftlint > /dev/null; then
    swiftlint
else
    echo "warning: SwiftLint not installed, download from https://github.com/realm/SwiftLint"
fi
""", name: "SwiftLintString")

    static let SwiftLintShell = TargetScript.pre(
        path: .relativeToRoot("Scripts/SwiftLintRunScript.sh"),
        name: "SwiftLintShell"
    )
    
    static let FirebaseShell = TargetScript.pre(
        path: .relativeToRoot("Scripts/FirebaseRunScript.sh"),
        name: "FirebaseShell"
    )
}
