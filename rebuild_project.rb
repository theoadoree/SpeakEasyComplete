#!/usr/bin/env ruby

require 'xcodeproj'

puts "🔧 Rebuilding SpeakEasyComplete.xcodeproj from scratch..."
puts "This will fix all corrupted file references with doubled paths."
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

# Clear all file references and rebuild
puts "🗑️  Removing all existing file references..."
project.main_group.clear

# Recreate group structure
puts "📁 Creating clean folder structure..."

# Helper to add files recursively
def add_files_to_group(group, dir_path, target, project)
  return unless Dir.exist?(dir_path)

  Dir.entries(dir_path).sort.each do |entry|
    next if entry.start_with?('.')
    next if entry == 'SpeakEasyComplete.xcodeproj'
    next if entry == 'build'
    next if entry == 'DerivedData'

    full_path = File.join(dir_path, entry)

    if File.directory?(full_path)
      # Create subgroup
      subgroup = group.new_group(entry, entry)
      add_files_to_group(subgroup, full_path, target, project)
    elsif entry.end_with?('.swift', '.plist', '.storyboard', '.xib', '.xcassets', '.entitlements')
      # Add file reference
      file_ref = group.new_file(full_path)

      # Add to build phases
      if entry.end_with?('.swift')
        target.source_build_phase.add_file_reference(file_ref)
      elsif entry.end_with?('.plist', '.storyboard', '.xib', '.xcassets', '.entitlements')
        target.resources_build_phase.add_file_reference(file_ref) unless entry == 'Info.plist'
      end
    end
  end
end

# Get base directory
base_dir = File.dirname(File.absolute_path(project_path))

# Define folder structure
folders = [
  'AppDelegate',
  'Models',
  'Views',
  'Controllers',
  'Services',
  'Data',
  'Extensions',
  'Theme',
  'Resources',
  'Utilities'
]

puts "📂 Adding folders and files:"
folders.each do |folder|
  folder_path = File.join(base_dir, folder)
  if Dir.exist?(folder_path)
    puts "  ✓ #{folder}/"
    group = project.main_group.new_group(folder, folder)
    add_files_to_group(group, folder_path, target, project)
  end
end

# Add root-level Swift files
puts "  ✓ Root files"
Dir.glob(File.join(base_dir, '*.swift')).each do |file|
  file_ref = project.main_group.new_file(file)
  target.source_build_phase.add_file_reference(file_ref)
  puts "    - #{File.basename(file)}"
end

# Special handling for GoogleService-Info.plist
google_service_file = File.join(base_dir, 'GoogleService-Info.plist')
if File.exist?(google_service_file)
  puts "  ✓ GoogleService-Info.plist (root)"
  file_ref = project.main_group.new_file(google_service_file)
  target.resources_build_phase.add_file_reference(file_ref)
end

# Configure build settings
puts ""
puts "⚙️  Configuring build settings..."

target.build_configurations.each do |config|
  # Disable code signing for Debug
  if config.name == 'Debug'
    config.build_settings['CODE_SIGN_IDENTITY'] = '-'
    config.build_settings['CODE_SIGN_STYLE'] = 'Manual'
    config.build_settings['CODE_SIGNING_REQUIRED'] = 'NO'
    config.build_settings['CODE_SIGNING_ALLOWED'] = 'NO'
  end

  # Standard settings
  config.build_settings['PRODUCT_NAME'] = '$(TARGET_NAME)'
  config.build_settings['INFOPLIST_FILE'] = 'Info.plist'
  config.build_settings['SWIFT_VERSION'] = '5.0'
  config.build_settings['TARGETED_DEVICE_FAMILY'] = '1,2'
  config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'

  puts "  ✓ #{config.name} configuration"
end

# Remove duplicates in build phases
puts ""
puts "🔍 Removing duplicate build phase entries..."

[:source_build_phase, :resources_build_phase].each do |phase_name|
  phase = target.send(phase_name)
  seen_files = {}
  duplicates_removed = 0

  phase.files.to_a.each do |build_file|
    next unless build_file.file_ref

    file_path = build_file.file_ref.real_path.to_s

    if seen_files[file_path]
      phase.files.delete(build_file)
      duplicates_removed += 1
    else
      seen_files[file_path] = true
    end
  end

  puts "  ✓ Removed #{duplicates_removed} duplicates from #{phase_name}"
end

# Save project
puts ""
puts "💾 Saving rebuilt project..."
project.save

puts ""
puts "✅ Project rebuild complete!"
puts ""
puts "Summary:"
puts "  - Backup created: #{backup_path}"
puts "  - All file references cleaned and rebuilt"
puts "  - Doubled paths (Services/Services/, etc.) removed"
puts "  - Build phases optimized"
puts "  - Code signing disabled for Debug"
puts ""
puts "🚀 Try building now:"
puts "   xcodebuild -project SpeakEasyComplete.xcodeproj -scheme SpeakEasyComplete -configuration Debug"
puts ""
