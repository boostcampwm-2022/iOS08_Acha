//
//  Project.swift
//  ProjectDescriptionHelpers
//
//  Created by hong on 2022/11/19.
//

import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.makeModule(
    name: "ThirdPartyLib",
    product: .framework,
    packages: [
        .Rx,
        .Firebase,
        .SnapKit,
        .Then,
        .Realm
    ],
    dependencies: [
        .SPM.RxSwift,
        .SPM.RxCocoa,
        .SPM.FirebaseAuth,
        .SPM.FirebaseDatabase,
        .SPM.FirebaseFirestore,
        .SPM.Then,
        .SPM.SnapKit
    ]
)
