#!/usr/bin/env ruby

require 'xcodeproj'

puts "🔧 Rebuilding SpeakEasyComplete.xcodeproj (Robust Version)..."
puts ""

project_path = 'SpeakEasyComplete.xcodeproj'

# Backup original
backup_path = "#{project_path}.backup.#{Time.now.to_i}"
puts "📦 Creating backup: #{backup_path}"
`cp -r #{project_path} #{backup_path}`

# Open project
project = Xcodeproj::Project.open(project_path)
target = project.targets.first

puts "🎯 Target: #{target.name}"
puts ""

# Clear build phases completely
puts "🗑️  Clearing all build phases..."
target.source_build_phase.clear
target.resources_build_phase.clear
target.frameworks_build_phase.clear

# Clear main group completely
puts "🗑️  Clearing main group..."
project.main_group.clear

puts ""
puts "📁 Rebuilding from filesystem..."
puts ""

# Helper to add files recursively with error handling
def add_files_to_group(group, dir_path, target, project, indent = "  ")
  return unless Dir.exist?(dir_path)

  Dir.entries(dir_path).sort.each do |entry|
    next if entry.start_with?('.')
    next if entry == 'SpeakEasyComplete.xcodeproj'
    next if entry == 'build'
    next if entry == 'DerivedData'
    next if entry.end_with?('.backup')

    full_path = File.join(dir_path, entry)

    begin
      if File.directory?(full_path)
        # Create subgroup
        puts "#{indent}📁 #{entry}/"
        subgroup = group.new_group(entry, entry)
        add_files_to_group(subgroup, full_path, target, project, indent + "  ")
      elsif entry.end_with?('.swift')
        # Add Swift file
        puts "#{indent}📄 #{entry}"
        file_ref = group.new_file(full_path)
        target.source_build_phase.add_file_reference(file_ref)
      elsif entry.end_with?('.xcassets', '.storyboard', '.xib')
        # Add resource
        puts "#{indent}🎨 #{entry}"
        file_ref = group.new_file(full_path)
        target.resources_build_phase.add_file_reference(file_ref)
      elsif entry.end_with?('.plist') && entry != 'Info.plist'
        # Add plist (except Info.plist)
        puts "#{indent}📋 #{entry}"
        file_ref = group.new_file(full_path)
        target.resources_build_phase.add_file_reference(file_ref)
      elsif entry.end_with?('.entitlements')
        # Add entitlements
        puts "#{indent}🔐 #{entry}"
        group.new_file(full_path)
      end
    rescue => e
      puts "#{indent}⚠️  Skipped #{entry}: #{e.message}"
    end
  end
end

# Get base directory
base_dir = File.dirname(File.absolute_path(project_path))

# Add all folders
folders = %w[AppDelegate Models Views Controllers Services Data Extensions Theme Resources Utilities]

folders.each do |folder|
  folder_path = File.join(base_dir, folder)
  if Dir.exist?(folder_path)
    group = project.main_group.new_group(folder, folder)
    add_files_to_group(group, folder_path, target, project)
  end
end

# Add root-level files
puts ""
puts "📄 Root-level files:"
Dir.glob(File.join(base_dir, '*.swift')).each do |file|
  puts "  - #{File.basename(file)}"
  file_ref = project.main_group.new_file(file)
  target.source_build_phase.add_file_reference(file_ref)
end

# GoogleService-Info.plist
google_service_file = File.join(base_dir, 'GoogleService-Info.plist')
if File.exist?(google_service_file)
  puts "  - GoogleService-Info.plist"
  file_ref = project.main_group.new_file(google_service_file)
  target.resources_build_phase.add_file_reference(file_ref)
end

# Info.plist
info_plist_file = File.join(base_dir, 'Info.plist')
if File.exist?(info_plist_file)
  puts "  - Info.plist (reference only)"
  project.main_group.new_file(info_plist_file)
end

puts ""
puts "⚙️  Configuring build settings..."

target.build_configurations.each do |config|
  # Standard settings
  config.build_settings['PRODUCT_NAME'] = '$(TARGET_NAME)'
  config.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = 'com.scott.speakeasy'
  config.build_settings['INFOPLIST_FILE'] = 'Info.plist'
  config.build_settings['SWIFT_VERSION'] = '5.0'
  config.build_settings['TARGETED_DEVICE_FAMILY'] = '1,2'
  config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'

  # Disable code signing for Debug
  if config.name == 'Debug'
    config.build_settings['CODE_SIGN_IDENTITY'] = ''
    config.build_settings['CODE_SIGN_STYLE'] = 'Automatic'
    config.build_settings['CODE_SIGNING_REQUIRED'] = 'NO'
    config.build_settings['CODE_SIGNING_ALLOWED'] = 'NO'
    config.build_settings['DEVELOPMENT_TEAM'] = ''
  end

  puts "  ✓ #{config.name}"
end

# Save project
puts ""
puts "💾 Saving..."
project.save

puts ""
puts "✅ Project rebuilt successfully!"
puts ""
puts "📊 Summary:"
puts "  - Backup: #{backup_path}"
puts "  - All file references rebuilt from filesystem"
puts "  - All doubled paths removed"
puts "  - Build phases cleaned and rebuilt"
puts ""
puts "🚀 Ready to build!"
puts ""
