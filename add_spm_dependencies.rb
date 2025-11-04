#!/usr/bin/env ruby

require 'xcodeproj'

puts "📦 Adding Swift Package Manager dependencies..."
puts ""

project = Xcodeproj::Project.open('SpeakEasyComplete.xcodeproj')
target = project.targets.first

puts "🎯 Target: #{target.name}"
puts ""

# Define package dependencies
packages = [
  {
    name: "firebase-ios-sdk",
    url: "https://github.com/firebase/firebase-ios-sdk",
    requirement: { kind: "upToNextMajorVersion", minimumVersion: "10.0.0" },
    products: ["FirebaseCore", "FirebaseAuth"]
  },
  {
    name: "GoogleSignIn-iOS",
    url: "https://github.com/google/GoogleSignIn-iOS",
    requirement: { kind: "upToNextMajorVersion", minimumVersion: "7.0.0" },
    products: ["GoogleSignIn"]
  },
  {
    name: "Alamofire",
    url: "https://github.com/Alamofire/Alamofire",
    requirement: { kind: "upToNextMajorVersion", minimumVersion: "5.8.0" },
    products: ["Alamofire"]
  }
]

# Add each package
packages.each do |pkg|
  puts "📦 Adding #{pkg[:name]}..."

  begin
    # Create package reference
    package_ref = project.new(Xcodeproj::Project::Object::XCRemoteSwiftPackageReference)
    package_ref.repositoryURL = pkg[:url]
    package_ref.requirement = pkg[:requirement]

    # Add to project
    project.root_object.package_references ||= []
    project.root_object.package_references << package_ref

    # Add products to target
    pkg[:products].each do |product_name|
      product_dependency = project.new(Xcodeproj::Project::Object::XCSwiftPackageProductDependency)
      product_dependency.package = package_ref
      product_dependency.product_name = product_name

      target.package_product_dependencies ||= []
      target.package_product_dependencies << product_dependency

      puts "  ✓ Added #{product_name}"
    end
  rescue => e
    puts "  ⚠️  #{e.message}"
  end
end

puts ""
puts "💾 Saving project..."
project.save

puts ""
puts "✅ Swift Package Manager dependencies added!"
puts ""
puts "📊 Added packages:"
packages.each do |pkg|
  puts "  • #{pkg[:name]}"
  pkg[:products].each do |product|
    puts "    - #{product}"
  end
end
puts ""
puts "🔄 Next: Resolve packages in Xcode"
puts "   File → Packages → Resolve Package Versions"
puts ""
puts "   Or build to automatically resolve:"
puts "   xcodebuild -project SpeakEasyComplete.xcodeproj -scheme SpeakEasyComplete -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 15' -resolvePackageDependencies"
puts ""
