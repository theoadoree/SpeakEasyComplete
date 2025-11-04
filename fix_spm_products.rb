#!/usr/bin/env ruby

require 'xcodeproj'

puts "🔧 Fixing Swift Package Manager product dependencies..."
puts ""

project = Xcodeproj::Project.open('SpeakEasyComplete.xcodeproj')
target = project.targets.first

puts "🎯 Target: #{target.name}"
puts ""

# Clear existing package dependencies
puts "🗑️  Clearing old dependencies..."
target.package_product_dependencies.clear if target.package_product_dependencies

# Find package references
firebase_pkg = project.root_object.package_references.find { |ref| ref.repositoryURL.include?('firebase-ios-sdk') }
google_signin_pkg = project.root_object.package_references.find { |ref| ref.repositoryURL.include?('GoogleSignIn-iOS') }
alamofire_pkg = project.root_object.package_references.find { |ref| ref.repositoryURL.include?('Alamofire') }

if firebase_pkg.nil? || google_signin_pkg.nil? || alamofire_pkg.nil?
  puts "❌ Package references not found in project"
  puts "   Run add_spm_dependencies.rb first"
  exit 1
end

puts "📦 Found packages:"
puts "  ✓ firebase-ios-sdk"
puts "  ✓ GoogleSignIn-iOS"
puts "  ✓ Alamofire"
puts ""

# Add product dependencies
products = [
  { package: firebase_pkg, name: "FirebaseCore" },
  { package: firebase_pkg, name: "FirebaseAuth" },
  { package: google_signin_pkg, name: "GoogleSignIn" },
  { package: google_signin_pkg, name: "GoogleSignInSwift" },
  { package: alamofire_pkg, name: "Alamofire" }
]

puts "🔗 Adding product dependencies:"
products.each do |product_info|
  product_dep = project.new(Xcodeproj::Project::Object::XCSwiftPackageProductDependency)
  product_dep.package = product_info[:package]
  product_dep.product_name = product_info[:name]

  target.package_product_dependencies << product_dep
  puts "  ✓ #{product_info[:name]}"
end

puts ""
puts "💾 Saving..."
project.save

puts ""
puts "✅ Package products linked to target!"
puts ""
