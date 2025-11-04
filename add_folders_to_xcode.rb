#!/usr/bin/env ruby
require 'xcodeproj'

project = Xcodeproj::Project.open('SpeakEasyComplete.xcodeproj')
target = project.targets.first
main_group = project.main_group

# Find or create SpeakEasyComplete group
app_group = main_group.groups.find { |g| g.display_name == 'SpeakEasyComplete' } || main_group.new_group('SpeakEasyComplete')

# Clear existing file references in the group to start fresh
app_group.clear

puts "Adding folders to Xcode project..."

# Folders to add
folders = {
  'Controllers' => '*.swift',
  'Models' => '*.swift',
  'Views' => '**/*.swift',
  'Services' => '*.swift',
  'ViewModels' => '*.swift',
  'Data' => '*.swift',
  'Extensions' => '*.swift',
  'Theme' => '*.swift',
  'Utilities' => '*.swift'
}

folders.each do |folder_name, pattern|
  next unless Dir.exist?(folder_name)

  puts "  📁 Adding #{folder_name}..."

  # Create a group for this folder
  folder_group = app_group.new_group(folder_name, folder_name)

  # Add all Swift files in this folder
  Dir.glob("#{folder_name}/#{pattern}").each do |file_path|
    next if File.directory?(file_path)

    file_ref = folder_group.new_file(file_path)

    # Add to compile sources if it's a Swift file
    if file_path.end_with?('.swift')
      target.source_build_phase.add_file_reference(file_ref) unless target.source_build_phase.files_references.include?(file_ref)
    end
  end
end

# Add Resources folder
if Dir.exist?('Resources')
  puts "  📁 Adding Resources..."
  resources_group = app_group.new_group('Resources', 'Resources')
  Dir.glob('Resources/**/*').each do |file_path|
    next if File.directory?(file_path)
    file_ref = resources_group.new_file(file_path)
    target.resources_build_phase.add_file_reference(file_ref) unless target.resources_build_phase.files_references.include?(file_ref)
  end
end

# Add Assets.xcassets
if Dir.exist?('Assets.xcassets')
  puts "  🎨 Adding Assets..."
  assets_ref = app_group.new_file('Assets.xcassets')
  target.resources_build_phase.add_file_reference(assets_ref) unless target.resources_build_phase.files_references.include?(assets_ref)
end

# Add main app file
if File.exist?('SpeakEasyApp.swift')
  puts "  📄 Adding SpeakEasyApp.swift..."
  app_file = app_group.new_file('SpeakEasyApp.swift')
  target.source_build_phase.add_file_reference(app_file) unless target.source_build_phase.files_references.include?(app_file)
end

# Add configuration files
['Info.plist', 'SpeakEasy.entitlements'].each do |config_file|
  if File.exist?(config_file)
    puts "  ⚙️  Adding #{config_file}..."
    app_group.new_file(config_file)
  end
end

project.save

puts "\n✅ Done! Folders added to Xcode project."
puts "🔄 Now open Xcode and you should see all folders organized."
