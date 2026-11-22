# Adds the PoeticUITests UI-testing bundle (App Store screenshot runner).
# Idempotent: exits early if the target already exists.
# Run: ruby Tools/add_uitest_target.rb
require 'xcodeproj'

ROOT = File.expand_path('..', __dir__)
PROJECT_PATH = File.join(ROOT, 'Poetic.xcodeproj')
project = Xcodeproj::Project.open(PROJECT_PATH)

if project.targets.any? { |t| t.name == 'PoeticUITests' }
  puts 'PoeticUITests target already exists — nothing to do'
  exit 0
end

app = project.targets.find { |t| t.name == 'Poetic' } or abort 'app target missing'

uitest = project.new_target(:ui_test_bundle, 'PoeticUITests', :ios, '17.0')
uitest.build_configurations.each do |config|
  settings = config.build_settings
  settings['PRODUCT_BUNDLE_IDENTIFIER'] = 'Dean.Thompson.PoeticUITests'
  settings['PRODUCT_NAME'] = 'PoeticUITests'
  settings['GENERATE_INFOPLIST_FILE'] = 'YES'
  settings['TEST_TARGET_NAME'] = 'Poetic'
  settings['CODE_SIGN_STYLE'] = 'Automatic'
  settings['DEVELOPMENT_TEAM'] = 'YT4PWFD9G5'
  settings['SWIFT_VERSION'] = '5.0'
  settings['TARGETED_DEVICE_FAMILY'] = '1,2'
  settings['IPHONEOS_DEPLOYMENT_TARGET'] = '17.0'
  settings['CURRENT_PROJECT_VERSION'] = '1'
  settings['MARKETING_VERSION'] = '1.0'
end
uitest.add_dependency(app)

group = project.main_group.new_group('PoeticUITests', 'PoeticUITests')
ref = group.new_reference('ScreenshotTests.swift')
uitest.add_file_references([ref])
puts 'created PoeticUITests target with ScreenshotTests.swift'

project.save

# Shared scheme so xcodebuild can run just the UI tests.
scheme = Xcodeproj::XCScheme.new
scheme.add_build_target(app)
scheme.set_launch_target(app)
scheme.add_test_target(uitest)
scheme.save_as(PROJECT_PATH, 'PoeticUITests', true)
puts 'saved shared scheme PoeticUITests'

# Sanity: the Core Data XCVersionGroup must survive the save.
reopened = Xcodeproj::Project.open(PROJECT_PATH)
vg = reopened.objects.find { |o| o.isa == 'XCVersionGroup' }
children = vg.children.map(&:path)
abort "XCVersionGroup damaged: #{children.inspect}" unless
  children.include?('Poetic.xcdatamodel') && children.include?('Poetic 2.xcdatamodel')
puts "version group intact: #{children.inspect}"
