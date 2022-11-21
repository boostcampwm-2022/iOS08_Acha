import ProjectDescription

public extension Project {
    static func makeModule(
        name: String,
        platform: Platform = .iOS,
        product: Product,
        organizationName: String = "Acha",
        packages: [Package] = [],
        deploymentTarget: DeploymentTarget? = .iOS(targetVersion: "14.0", devices: [.iphone, .ipad]),
        dependencies: [TargetDependency] = [],
        sources: SourceFilesList = ["Sources/**"],
        resources: ResourceFileElements? = nil,
        infoPlist: InfoPlist = .default
    ) -> Project {
        let settings: Settings = .settings(
            base: [:],
            configurations: [
                .debug(name: .debug),
                .release(name: .release)
            ], defaultSettings: .recommended)

        let appTarget = Target(
            name: name,
            platform: platform,
            product: product,
            bundleId: "co.boostcamp.\(name)",
            deploymentTarget: deploymentTarget,
            infoPlist: infoPlist,
            sources: sources,
            resources: resources,
            scripts: [.SwiftLintString],
            dependencies: dependencies
        )

        let testTarget = Target(
            name: "\(name)Tests",
            platform: platform,
            product: .unitTests,
            bundleId: "\(organizationName).\(name)Tests",
            deploymentTarget: deploymentTarget,
            infoPlist: .default,
            sources: ["Tests/**"],
            dependencies: [.target(name: name)]
        )

        let schemes: [Scheme] = [.makeScheme(target: .debug, name: name)]

        let targets: [Target] = [appTarget, testTarget]

        return Project(
            name: name,
            organizationName: organizationName,
            packages: packages,
            settings: settings,
            targets: targets,
            schemes: schemes
        )
    }
}

extension Scheme {
    static func makeScheme(target: ConfigurationName, name: String) -> Scheme {
        return Scheme(
            name: name,
            shared: true,
            buildAction: .buildAction(targets: ["\(name)"]),
            testAction: .targets(
                ["\(name)Tests"],
                configuration: target,
                options: .options(coverage: true, codeCoverageTargets: ["\(name)"])
            ),
            runAction: .runAction(configuration: target),
            archiveAction: .archiveAction(configuration: target),
            profileAction: .profileAction(configuration: target),
            analyzeAction: .analyzeAction(configuration: target)
        )
    }
}


// MARK: - Dependencies
public extension TargetDependency {
    enum SPM {}
}

public extension Package {
    static let Rx = Package.remote(url: "https://github.com/ReactiveX/RxSwift",
                                   requirement: .upToNextMajor(from: "6.0.0"))
    static let Then = Package.remote(url: "https://github.com/devxoul/Then.git",
                                     requirement: .upToNextMajor(from: "3.0.0"))
    static let Firebase = Package.remote(url: "https://github.com/firebase/firebase-ios-sdk.git",
                                         requirement: .upToNextMajor(from: "9.0.0"))
    static let SnapKit = Package.remote(url: "https://github.com/SnapKit/SnapKit.git",
                                        requirement: .upToNextMajor(from: "5.0.0"))
    static let Realm = Package.remote(url: "https://github.com/realm/realm-swift.git", requirement: .upToNextMajor(from: "10.0.0"))
}

public extension TargetDependency.SPM {
    static let RxSwift = TargetDependency.package(product: "RxSwift")
    static let RxCocoa = TargetDependency.package(product: "RxCocoa")
    static let RxRelay = TargetDependency.package(product: "RxRelay")
    static let RxGesture = TargetDependency.package(product: "RxGesture")
    static let Then = TargetDependency.package(product: "Then")
    static let FirebaseAuth = TargetDependency.package(product: "FirebaseAuth")
    static let FirebaseDatabase = TargetDependency.package(product: "FirebaseDatabase")
    static let FirebaseFirestore = TargetDependency.package(product: "FirebaseFirestore")
    static let FirebaseStorage = TargetDependency.package(product: "FirebaseStorage")
    static let FirebaseMessaging = TargetDependency.package(product: "FirebaseMessaging")
    static let SnapKit = TargetDependency.package(product: "SnapKit")
    static let RealmSwift = TargetDependency.package(product: "RealmSwift")
}
