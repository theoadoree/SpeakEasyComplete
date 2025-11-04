#!/usr/bin/env ruby
require 'xcodeproj'

project_path = 'SpeakEasyComplete.xcodeproj'
project = Xcodeproj::Project.new(project_path)

# Create main target
target = project.new_target(:application, 'SpeakEasyComplete', :osx, '14.0')

# Get main group
main_group = project.main_group

# Create MVC groups
app_group = main_group.new_group('SpeakEasyComplete')

# MVC Structure
mvc_group = app_group.new_group('App')
models_group = mvc_group.new_group('Models', 'Models')
views_group = mvc_group.new_group('Views', 'Views')
controllers_group = mvc_group.new_group('Controllers', 'Controllers')

# Supporting files
services_group = app_group.new_group('Services', 'Services')
view_models_group = app_group.new_group('ViewModels', 'ViewModels')
extensions_group = app_group.new_group('Extensions', 'Extensions')
utilities_group = app_group.new_group('Utilities', 'Utilities')
data_group = app_group.new_group('Data', 'Data')
theme_group = app_group.new_group('Theme', 'Theme')

# Resources
resources_group = app_group.new_group('Resources', 'Resources')

# Add main app file
if File.exist?('SpeakEasyApp.swift')
  app_file = app_group.new_file('SpeakEasyApp.swift')
  target.add_file_references([app_file])
end

# Helper function to add files to group
def add_files_to_group(group, folder_path, target)
  return unless Dir.exist?(folder_path)

  Dir.glob("#{folder_path}/**/*.swift").sort.each do |file_path|
    relative_path = file_path
    file_ref = group.new_file(relative_path)
    target.add_file_references([file_ref])
  end
end

# Add files to each group
add_files_to_group(models_group, 'Models', target)
add_files_to_group(views_group, 'Views', target)
add_files_to_group(controllers_group, 'Controllers', target)
add_files_to_group(services_group, 'Services', target)
add_files_to_group(view_models_group, 'ViewModels', target)
add_files_to_group(extensions_group, 'Extensions', target)
add_files_to_group(utilities_group, 'Utilities', target)
add_files_to_group(data_group, 'Data', target)
add_files_to_group(theme_group, 'Theme', target)

# Add resources
if Dir.exist?('Resources')
  Dir.glob('Resources/**/*.plist').each do |file_path|
    file_ref = resources_group.new_file(file_path)
    target.resources_build_phase.add_file_reference(file_ref)
  end
end

# Add Assets.xcassets
if Dir.exist?('Assets.xcassets')
  assets_ref = resources_group.new_reference('Assets.xcassets')
  target.resources_build_phase.add_file_reference(assets_ref)
end

# Configure build settings
target.build_configurations.each do |config|
  config.build_settings['PRODUCT_NAME'] = 'SpeakEasyComplete'
  config.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = 'com.speakeasy.complete'
  config.build_settings['SWIFT_VERSION'] = '5.9'
  config.build_settings['MACOSX_DEPLOYMENT_TARGET'] = '14.0'
  config.build_settings['ASSETCATALOG_COMPILER_APPICON_NAME'] = 'AppIcon'
  config.build_settings['ENABLE_HARDENED_RUNTIME'] = 'YES'
  config.build_settings['COMBINE_HIDPI_IMAGES'] = 'YES'
  config.build_settings['INFOPLIST_FILE'] = 'Info.plist'
  config.build_settings['CODE_SIGN_ENTITLEMENTS'] = 'SpeakEasy.entitlements'
  config.build_settings['CODE_SIGN_STYLE'] = 'Automatic'
  config.build_settings['DEVELOPMENT_TEAM'] = ''
end

# Save project
project.save

puts "✅ MVC-structured Xcode project created!"
puts "📁 Project Structure:"
puts "   SpeakEasyComplete/"
puts "   ├── App/"
puts "   │   ├── Models/ (#{Dir.glob('Models/**/*.swift').count} files)"
puts "   │   ├── Views/ (#{Dir.glob('Views/**/*.swift').count} files)"
puts "   │   └── Controllers/ (#{Dir.glob('Controllers/**/*.swift').count} files)"
puts "   ├── Services/ (#{Dir.glob('Services/**/*.swift').count} files)"
puts "   ├── ViewModels/ (#{Dir.glob('ViewModels/**/*.swift').count} files)"
puts "   ├── Extensions/ (#{Dir.glob('Extensions/**/*.swift').count} files)"
puts "   ├── Utilities/ (#{Dir.glob('Utilities/**/*.swift').count} files)"
puts "   ├── Data/ (#{Dir.glob('Data/**/*.swift').count} files)"
puts "   ├── Theme/ (#{Dir.glob('Theme/**/*.swift').count} files)"
puts "   └── Resources/"
puts "       └── Assets.xcassets"
puts ""
puts "Total: #{Dir.glob('**/*.swift').count} Swift files"
