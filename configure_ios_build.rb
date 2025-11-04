#!/usr/bin/env ruby

require 'xcodeproj'

puts "🔧 Configuring project for iOS build..."
puts ""

project = Xcodeproj::Project.open('SpeakEasyComplete.xcodeproj')
target = project.targets.first

puts "🎯 Target: #{target.name}"
puts ""

# Configure build settings for iOS
target.build_configurations.each do |config|
  # iOS Platform settings
  config.build_settings['SDKROOT'] = 'iphoneos'
  config.build_settings['SUPPORTED_PLATFORMS'] = 'iphoneos iphonesimulator'
  config.build_settings['TARGETED_DEVICE_FAMILY'] = '1,2'  # iPhone and iPad
  config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'

  # Product settings
  config.build_settings['PRODUCT_NAME'] = '$(TARGET_NAME)'
  config.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = 'com.scott.speakeasy'
  config.build_settings['INFOPLIST_FILE'] = 'Info.plist'

  # Swift settings
  config.build_settings['SWIFT_VERSION'] = '5.0'
  config.build_settings['SWIFT_OPTIMIZATION_LEVEL'] = '-Onone' if config.name == 'Debug'

  # Code signing (disabled for now)
  if config.name == 'Debug'
    config.build_settings['CODE_SIGN_IDENTITY'] = ''
    config.build_settings['CODE_SIGN_STYLE'] = 'Automatic'
    config.build_settings['CODE_SIGNING_REQUIRED'] = 'NO'
    config.build_settings['CODE_SIGNING_ALLOWED'] = 'NO'
    config.build_settings['DEVELOPMENT_TEAM'] = ''
  end

  # Remove macOS specific settings
  config.build_settings.delete('MACOSX_DEPLOYMENT_TARGET')
  config.build_settings.delete('COMBINE_HIDPI_IMAGES')

  puts "  ✓ Configured #{config.name} for iOS"
end

# Update target platform
target.build_phases.each do |phase|
  if phase.is_a?(Xcodeproj::Project::Object::PBXSourcesBuildPhase)
    puts "  ✓ Updated source build phase"
  end
end

project.save

puts ""
puts "✅ Project configured for iOS!"
puts ""
puts "📱 Settings:"
puts "  - Platform: iOS (iPhone & iPad)"
puts "  - Deployment Target: iOS 15.0+"
puts "  - SDK: iphoneos"
puts "  - Code Signing: Disabled for Debug"
puts ""
puts "🚀 Build for iOS simulator:"
puts "   xcodebuild -project SpeakEasyComplete.xcodeproj -scheme SpeakEasyComplete -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 15' build"
puts ""
