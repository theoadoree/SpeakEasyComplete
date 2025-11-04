#!/usr/bin/env ruby

require 'xcodeproj'

puts "🍎 Adding Sign in with Apple support..."
puts ""

project = Xcodeproj::Project.open('SpeakEasyComplete.xcodeproj')
target = project.targets.first

puts "🎯 Target: #{target.name}"
puts ""

# Add AuthenticationServices framework (native iOS framework)
frameworks_group = project.main_group.find_subpath('Frameworks', true)
frameworks_group ||= project.main_group.new_group('Frameworks')

frameworks_build_phase = target.frameworks_build_phase

# Add AuthenticationServices.framework
auth_services_ref = frameworks_group.new_file('System/Library/Frameworks/AuthenticationServices.framework')
auth_services_ref.source_tree = 'SDKROOT'

unless frameworks_build_phase.files.any? { |f| f.file_ref == auth_services_ref }
  frameworks_build_phase.add_file_reference(auth_services_ref)
  puts "  ✓ Added AuthenticationServices.framework"
end

# Add Sign in with Apple capability to entitlements
puts ""
puts "🔐 Checking entitlements..."

entitlements_path = 'SpeakEasyComplete.entitlements'

if File.exist?(entitlements_path)
  puts "  ✓ Found #{entitlements_path}"

  # Read existing entitlements
  require 'plist'
  entitlements = Plist.parse_xml(entitlements_path)

  # Add Sign in with Apple capability
  unless entitlements.key?('com.apple.developer.applesignin')
    entitlements['com.apple.developer.applesignin'] = ['Default']

    # Write back
    File.open(entitlements_path, 'w') do |file|
      file.write(entitlements.to_plist)
    end

    puts "  ✓ Added Sign in with Apple capability to entitlements"
  else
    puts "  ✓ Sign in with Apple capability already exists"
  end
else
  puts "  ⚠️  Entitlements file not found, creating one..."

  # Create entitlements file
  entitlements = {
    'com.apple.developer.applesignin' => ['Default']
  }

  File.open(entitlements_path, 'w') do |file|
    file.write(entitlements.to_plist)
  end

  # Add to project
  entitlements_ref = project.main_group.new_file(entitlements_path)

  # Set CODE_SIGN_ENTITLEMENTS in build settings
  target.build_configurations.each do |config|
    config.build_settings['CODE_SIGN_ENTITLEMENTS'] = entitlements_path
  end

  puts "  ✓ Created #{entitlements_path} with Sign in with Apple"
end

# Update Info.plist for Apple Sign In callback
info_plist_path = 'Info.plist'

if File.exist?(info_plist_path)
  puts ""
  puts "📋 Checking Info.plist..."

  require 'plist'
  info_plist = Plist.parse_xml(info_plist_path)

  # Check if CFBundleURLTypes exists for Apple Sign In
  bundle_url_types = info_plist['CFBundleURLTypes'] || []

  # Check if Apple Sign In URL scheme exists
  has_apple_signin_scheme = bundle_url_types.any? do |url_type|
    schemes = url_type['CFBundleURLSchemes'] || []
    schemes.include?('com.scott.speakeasy')
  end

  unless has_apple_signin_scheme
    # Add Apple Sign In URL scheme
    bundle_url_types << {
      'CFBundleTypeRole' => 'Editor',
      'CFBundleURLSchemes' => ['com.scott.speakeasy']
    }

    info_plist['CFBundleURLTypes'] = bundle_url_types

    # Write back
    File.open(info_plist_path, 'w') do |file|
      file.write(info_plist.to_plist)
    end

    puts "  ✓ Added Apple Sign In URL scheme to Info.plist"
  else
    puts "  ✓ Apple Sign In URL scheme already exists"
  end
end

puts ""
puts "💾 Saving project..."
project.save

puts ""
puts "✅ Sign in with Apple support added!"
puts ""
puts "📊 Summary:"
puts "  ✓ AuthenticationServices.framework linked"
puts "  ✓ Sign in with Apple capability in entitlements"
puts "  ✓ URL scheme configured in Info.plist"
puts ""
puts "🔐 Capability:"
puts "  com.apple.developer.applesignin = Default"
puts ""
puts "📱 Ready to use Sign in with Apple!"
puts ""
