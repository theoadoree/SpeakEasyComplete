#!/usr/bin/env ruby
require 'xcodeproj'

project_path = 'SpeakEasyComplete.xcodeproj'
project = Xcodeproj::Project.open(project_path)

# Get the main target
target = project.targets.first

puts "🔧 Adding Swift Package Manager dependencies..."
puts ""

# Package configurations
packages = [
  {
    name: 'Firebase',
    url: 'https://github.com/firebase/firebase-ios-sdk.git',
    requirement: {
      kind: 'upToNextMajorVersion',
      minimumVersion: '11.5.0'
    },
    products: ['FirebaseAuth', 'FirebaseAnalytics', 'FirebaseFirestore', 'FirebaseStorage']
  },
  {
    name: 'GoogleSignIn',
    url: 'https://github.com/google/GoogleSignIn-iOS.git',
    requirement: {
      kind: 'upToNextMajorVersion',
      minimumVersion: '7.1.0'
    },
    products: ['GoogleSignIn', 'GoogleSignInSwift']
  },
  {
    name: 'Alamofire',
    url: 'https://github.com/Alamofire/Alamofire.git',
    requirement: {
      kind: 'upToNextMajorVersion',
      minimumVersion: '5.9.0'
    },
    products: ['Alamofire']
  }
]

# Add remote packages to the project
packages.each do |package_info|
  puts "📦 Adding #{package_info[:name]}..."
  puts "   URL: #{package_info[:url]}"
  puts "   Version: #{package_info[:requirement][:minimumVersion]}+"

  begin
    # Create package reference
    package_ref = project.root_object.package_references.new
    package_ref.repositoryURL = package_info[:url]
    package_ref.requirement = package_info[:requirement]

    # Add products to target
    package_info[:products].each do |product_name|
      puts "   → Adding product: #{product_name}"

      # Create package product dependency
      product_dependency = target.package_product_dependencies.new
      product_dependency.product_name = product_name
      product_dependency.package = package_ref
    end

    puts "   ✅ #{package_info[:name]} added successfully"
  rescue => e
    puts "   ⚠️  Error adding #{package_info[:name]}: #{e.message}"
  end
  puts ""
end

# Save the project
project.save

puts ""
puts "=" * 60
puts "✅ All Swift Package Manager dependencies have been added!"
puts "=" * 60
puts ""
puts "📋 Summary:"
puts "  • Firebase iOS SDK (Auth, Analytics, Firestore, Storage)"
puts "  • Google Sign-In (GoogleSignIn, GoogleSignInSwift)"
puts "  • Alamofire (Networking)"
puts ""
puts "🔄 Next steps:"
puts "  1. Open the project in Xcode"
puts "  2. Xcode will automatically resolve and download packages"
puts "  3. Build the project (⌘B)"
puts ""
