//
//  Project.swift
//  ProjectDescriptionHelpers
//
//  Created by hong on 2022/11/19.
//

import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.makeModule(
    name: "Manager",
    product: .staticFramework,
    dependencies: [
        .project(target: "ThirdPartyLib", path: .relativeToRoot("Acha/ThirdPartyLib"))
    ]
)
