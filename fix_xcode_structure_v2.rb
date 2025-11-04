#!/usr/bin/env ruby
require 'xcodeproj'

project_path = 'SpeakEasyComplete.xcodeproj'
project = Xcodeproj::Project.open(project_path)

# Get the main target
target = project.targets.first
main_group = project.main_group

# Create or get main app group
app_group = main_group.find_subpath('SpeakEasyComplete', true)
app_group.clear

# Add folders as folder references
folders = ['Controllers', 'Models', 'Views', 'Services', 'ViewModels', 'Data', 'Extensions', 'Theme', 'Utilities', 'Resources']

folders.each do |folder|
  if Dir.exist?(folder)
    puts "Adding #{folder}..."
    folder_ref = app_group.new_reference(folder)
    folder_ref.source_tree = 'SOURCE_ROOT'
    folder_ref.path = folder
  end
end

# Add Assets.xcassets
if Dir.exist?('Assets.xcassets')
  assets_ref = app_group.new_reference('Assets.xcassets')
  target.resources_build_phase.add_file_reference(assets_ref)
end

# Add main app file
if File.exist?('SpeakEasyApp.swift')
  app_file_ref = app_group.new_file('SpeakEasyApp.swift')
  target.add_file_references([app_file_ref])
end

# Add Info.plist and entitlements references
['Info.plist', 'SpeakEasy.entitlements'].each do |file|
  app_group.new_file(file) if File.exist?(file)
end

# Save project
project.save

puts "\n✅ Xcode project structure reorganized!"
puts "📁 Added folder references: #{folders.join(', ')}"
puts "🔄 Reopen Xcode to see the changes"
