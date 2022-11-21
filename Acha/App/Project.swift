//
//  Project.swift
//  ProjectDescriptionHelpers
//
//  Created by hong on 2022/11/19.
//

import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.makeModule(
    name: "Acha",
    platform: .iOS,
    product: .app,
    dependencies: [
        .project(target: "Manager", path: .relativeToRoot("Acha/Manager")),
        .project(target: "ThirdPartyLib", path: .relativeToRoot("Acha/ThirdPartyLib"))
    ],
    resources: ["Resources/**"],
    infoPlist: .file(path: "Support/Info.plist")
)
