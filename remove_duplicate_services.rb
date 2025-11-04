#!/usr/bin/env ruby

require 'xcodeproj'
require 'fileutils'

puts "🔧 Removing duplicate service files..."
puts ""

project = Xcodeproj::Project.open('SpeakEasyComplete.xcodeproj')
target = project.targets.first

# List of service files that should ONLY be in Services/
service_files = [
  'APIService.swift',
  'ActiveProductionService.swift',
  'AdaptiveLearningService.swift',
  'AssessmentService.swift',
  'AuthService.swift',
  'AutoVoiceService.swift',
  'ComprehensibleInputService.swift',
  'FocusOnFormService.swift',
  'GamificationService.swift',
  'LanguageEngine.swift',
  'LearningContentManager.swift',
  'LessonContentGenerator.swift',
  'MeaningfulInteractionService.swift',
  'MultiLanguageService.swift',
  'MusicManager.swift',
  'NotificationService.swift',
  'OpenAIService.swift',
  'OpenAIRealtimeService.swift',
  'PersonalizedLearningService.swift',
  'PronunciationDrillingService.swift',
  'RealTimeAnalyticsManager.swift',
  'SpacedRepetitionService.swift',
  'SpeechService.swift',
  'StorageService.swift',
  'UserProgressService.swift',
  'VocabularyTrackingService.swift'
]

# Find and remove duplicates from wrong locations
wrong_locations = ['Controllers', 'Views/Components', 'Models']

service_files.each do |filename|
  wrong_locations.each do |wrong_dir|
    wrong_path = File.join(wrong_dir, filename)

    if File.exist?(wrong_path)
      puts "  ✓ Removing #{wrong_path}"
      FileUtils.rm(wrong_path)

      # Remove from project
      target.source_build_phase.files.each do |build_file|
        if build_file.file_ref && build_file.file_ref.path == filename && build_file.file_ref.parent.path == wrong_dir
          target.source_build_phase.files.delete(build_file)
        end
      end
    end
  end

  # Ensure the correct one exists in Services/
  correct_path = File.join('Services', filename)
  if File.exist?(correct_path)
    puts "  ✓ Keeping Services/#{filename}"
  end
end

# Remove file references from project for wrong locations
removed_refs = 0

def remove_file_refs_recursive(group, filename, wrong_dirs)
  count = 0
  group.children.to_a.each do |child|
    if child.is_a?(Xcodeproj::Project::Object::PBXGroup)
      count += remove_file_refs_recursive(child, filename, wrong_dirs)
    elsif child.respond_to?(:path) && child.path == filename
      if wrong_dirs.include?(child.parent.path)
        child.remove_from_project
        count += 1
      end
    end
  end
  count
end

service_files.each do |filename|
  removed_refs += remove_file_refs_recursive(project.main_group, filename, wrong_locations)
end

puts ""
puts "✅ Cleaned up #{removed_refs} duplicate references"

# Save project
project.save

puts ""
puts "📊 Summary:"
puts "  - Removed duplicates from Controllers/"
puts "  - Removed duplicates from Views/Components/"
puts "  - Kept all service files in Services/"
puts ""
