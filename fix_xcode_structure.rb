#!/usr/bin/env ruby
require 'xcodeproj'

project_path = 'SpeakEasyComplete.xcodeproj'
project = Xcodeproj::Project.open(project_path)

# Get the main target
target = project.targets.first
main_group = project.main_group

# Remove existing SpeakEasyComplete group if it exists
existing_group = main_group.groups.find { |g| g.display_name == 'SpeakEasyComplete' }
existing_group.clear if existing_group

# Create main app group
app_group = main_group.new_group('SpeakEasyComplete', 'SpeakEasyComplete')

# Add folders as groups with folder references
folders = ['Controllers', 'Models', 'Views', 'Services', 'ViewModels', 'Data', 'Extensions', 'Theme', 'Utilities', 'Resources']

folders.each do |folder|
  if Dir.exist?(folder)
    # Create group reference that mirrors the file system
    group_ref = app_group.new_reference(folder)
    group_ref.source_tree = '<group>'

    # Add all Swift files in the folder to the target
    Dir.glob("#{folder}/**/*.swift").each do |file|
      file_ref = group_ref.new_reference(file)
      target.add_file_references([file_ref]) if file.end_with?('.swift')
    end
  end
end

# Add main app file
if File.exist?('SpeakEasyApp.swift')
  app_file = app_group.new_reference('SpeakEasyApp.swift')
  target.add_file_references([app_file])
end

# Add Assets
if Dir.exist?('Assets.xcassets')
  assets = app_group.new_reference('Assets.xcassets')
  target.resources_build_phase.add_file_reference(assets)
end

# Add Info.plist reference
if File.exist?('Info.plist')
  app_group.new_reference('Info.plist')
end

# Add entitlements
if File.exist?('SpeakEasy.entitlements')
  app_group.new_reference('SpeakEasy.entitlements')
end

# Save project
project.save

puts "✅ Xcode project structure reorganized!"
puts "📁 Added folder groups: #{folders.join(', ')}"
puts "🔄 Please reopen the project in Xcode"
