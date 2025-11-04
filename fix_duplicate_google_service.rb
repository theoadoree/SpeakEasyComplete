#!/usr/bin/env ruby

require 'xcodeproj'

puts "🔧 Fixing duplicate GoogleService-Info.plist..."

project = Xcodeproj::Project.open('SpeakEasyComplete.xcodeproj')
target = project.targets.first

# Find and remove the root-level GoogleService-Info.plist from resources phase
removed_count = 0

target.resources_build_phase.files.each do |build_file|
  next unless build_file.file_ref

  file_path = build_file.file_ref.path

  # Remove root-level GoogleService-Info.plist, keep the one in Resources/
  if file_path == 'GoogleService-Info.plist'
    puts "  ✓ Removing root-level GoogleService-Info.plist from resources"
    target.resources_build_phase.files.delete(build_file)
    removed_count += 1
  end
end

# Also remove from file references if it's in the root group
project.main_group.children.each do |child|
  if child.respond_to?(:path) && child.path == 'GoogleService-Info.plist'
    puts "  ✓ Removing root-level GoogleService-Info.plist file reference"
    child.remove_from_project
  end
end

if removed_count > 0
  project.save
  puts ""
  puts "✅ Fixed! Removed #{removed_count} duplicate reference(s)"
  puts "   Keeping: Resources/GoogleService-Info.plist"
else
  puts "⚠️  No duplicates found"
end

puts ""
