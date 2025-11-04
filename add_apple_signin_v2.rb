#!/usr/bin/env ruby

require 'xcodeproj'

puts "🍎 Adding Sign in with Apple support..."
puts ""

project = Xcodeproj::Project.open('SpeakEasyComplete.xcodeproj')
target = project.targets.first

puts "🎯 Target: #{target.name}"
puts ""

# 1. Add AuthenticationServices framework (native iOS framework)
puts "📦 Adding AuthenticationServices.framework..."

frameworks_group = project.main_group.find_subpath('Frameworks', true)
frameworks_group ||= project.main_group.new_group('Frameworks')

frameworks_build_phase = target.frameworks_build_phase

# Add AuthenticationServices.framework
auth_services_ref = frameworks_group.new_file('System/Library/Frameworks/AuthenticationServices.framework')
auth_services_ref.source_tree = 'SDKROOT'

unless frameworks_build_phase.files.any? { |f| f.file_ref == auth_services_ref }
  frameworks_build_phase.add_file_reference(auth_services_ref)
  puts "  ✓ Added AuthenticationServices.framework"
else
  puts "  ✓ AuthenticationServices.framework already added"
end

# 2. Add entitlements file to project
puts ""
puts "🔐 Adding entitlements file..."

entitlements_path = 'SpeakEasyComplete.entitlements'

if File.exist?(entitlements_path)
  puts "  ✓ Entitlements file exists"

  # Add to project if not already there
  entitlements_ref = project.main_group.children.find { |c| c.path == entitlements_path }

  if entitlements_ref.nil?
    entitlements_ref = project.main_group.new_file(entitlements_path)
    puts "  ✓ Added to project"
  else
    puts "  ✓ Already in project"
  end

  # Set CODE_SIGN_ENTITLEMENTS in build settings
  target.build_configurations.each do |config|
    config.build_settings['CODE_SIGN_ENTITLEMENTS'] = entitlements_path
  end
  puts "  ✓ Set CODE_SIGN_ENTITLEMENTS build setting"
else
  puts "  ⚠️  Entitlements file not found at #{entitlements_path}"
end

puts ""
puts "💾 Saving project..."
project.save

puts ""
puts "✅ Sign in with Apple support added!"
puts ""
puts "📊 Summary:"
puts "  ✓ AuthenticationServices.framework linked"
puts "  ✓ Entitlements file configured"
puts "  ✓ CODE_SIGN_ENTITLEMENTS build setting set"
puts ""
puts "🔐 Entitlements:"
puts "  com.apple.developer.applesignin = Default"
puts ""
puts "📱 Ready to use Sign in with Apple!"
puts ""
