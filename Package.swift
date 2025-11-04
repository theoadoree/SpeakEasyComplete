// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "SpeakEasyComplete",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "SpeakEasyComplete",
            targets: ["SpeakEasyComplete"]
        )
    ],
    dependencies: [
        // Firebase SDK
        .package(
            url: "https://github.com/firebase/firebase-ios-sdk",
            from: "10.0.0"
        ),
        // Google Sign-In
        .package(
            url: "https://github.com/google/GoogleSignIn-iOS",
            from: "7.0.0"
        ),
        // Alamofire for networking
        .package(
            url: "https://github.com/Alamofire/Alamofire",
            from: "5.8.0"
        )
    ],
    targets: [
        .target(
            name: "SpeakEasyComplete",
            dependencies: [
                .product(name: "FirebaseCore", package: "firebase-ios-sdk"),
                .product(name: "FirebaseAuth", package: "firebase-ios-sdk"),
                .product(name: "GoogleSignIn", package: "GoogleSignIn-iOS"),
                "Alamofire"
            ],
            path: "."
        )
    ]
)
