# Adds the PoeticWidgets app-extension target and wires shared files.
# Idempotent: exits early if the target already exists.
# Run: ruby Tools/add_widget_target.rb
require 'xcodeproj'

ROOT = File.expand_path('..', __dir__)
project = Xcodeproj::Project.open(File.join(ROOT, 'Poetic.xcodeproj'))

if project.targets.any? { |t| t.name == 'PoeticWidgets' }
  puts 'PoeticWidgets target already exists — nothing to do'
  exit 0
end

app = project.targets.find { |t| t.name == 'Poetic' } or abort 'app target missing'
tests = project.targets.find { |t| t.name == 'PoeticTests' } or abort 'test target missing'

# --- 1. App-side new files (Poetic/Widget group + StoreKit + tests) ---
poetic_group = project.files.find { |f| f.path.to_s.end_with?('PoeticApp.swift') }.parent
widget_group = poetic_group.new_group('Widget', 'Widget')
app_widget_files = %w[
  SharedConstants.swift WidgetPayload.swift PoemExcerpt.swift WidgetDataStore.swift
  DailyPoemPicker.swift DeepLink.swift WidgetDataRefresher.swift
].map { |n| widget_group.new_reference(n) }
app.add_file_references(app_widget_files)
puts "added #{app_widget_files.count} files to app target (Poetic/Widget)"

storekit_group = project.files.find { |f| f.path.to_s.end_with?('StoreKitManager.swift') }.parent
supporter_ref = storekit_group.new_reference('SupporterEntitlement.swift')
app.add_file_references([supporter_ref])
puts 'added SupporterEntitlement.swift to app target'

tests_group = project.files.find { |f| f.path.to_s.end_with?('PoemViewModelTests.swift') }.parent
%w[WidgetFoundationTests.swift SupporterEntitlementTests.swift].each do |name|
  ref = tests_group.new_reference(name)
  tests.add_file_references([ref])
  puts "added #{name} to test target"
end

# --- 2. App target settings: entitlements, version bump ---
app.build_configurations.each do |config|
  config.build_settings['CODE_SIGN_ENTITLEMENTS'] = 'Poetic/Poetic.entitlements'
  config.build_settings['MARKETING_VERSION'] = '2.4.0'
end
puts 'app target: entitlements + version 2.4.0'

# --- 3. PrivacyInfo.xcprivacy into app resources (pre-existing bug) ---
privacy_ref = project.files.find { |f| f.path.to_s.end_with?('PrivacyInfo.xcprivacy') }
if privacy_ref && app.resources_build_phase.files_references.none? { |r| r == privacy_ref }
  app.resources_build_phase.add_file_reference(privacy_ref)
  puts 'added PrivacyInfo.xcprivacy to app resources phase'
end

# --- 4. Widget target ---
widget = project.new_target(:app_extension, 'PoeticWidgets', :ios, '17.0')
widget.build_configurations.each do |config|
  settings = config.build_settings
  settings['PRODUCT_BUNDLE_IDENTIFIER'] = 'Dean.Thompson.Poetic.PoeticWidgets'
  settings['INFOPLIST_FILE'] = 'PoeticWidgets/Info.plist'
  settings['GENERATE_INFOPLIST_FILE'] = 'YES'
  settings['INFOPLIST_KEY_CFBundleDisplayName'] = 'Poetic'
  settings['CODE_SIGN_ENTITLEMENTS'] = 'PoeticWidgets/PoeticWidgets.entitlements'
  settings['CODE_SIGN_STYLE'] = 'Automatic'
  settings['DEVELOPMENT_TEAM'] = 'YT4PWFD9G5'
  settings['CURRENT_PROJECT_VERSION'] = '1'
  settings['MARKETING_VERSION'] = '2.4.0'
  settings['SWIFT_VERSION'] = '5.0'
  settings['TARGETED_DEVICE_FAMILY'] = '1'
  settings['SKIP_INSTALL'] = 'YES'
  settings['IPHONEOS_DEPLOYMENT_TARGET'] = '17.0'
  settings['SWIFT_EMIT_LOC_STRINGS'] = 'YES'
end
puts 'created PoeticWidgets target'

ext_group = project.main_group.new_group('PoeticWidgets', 'PoeticWidgets')
views_group = ext_group.new_group('Views', 'Views')
ext_sources = %w[PoeticWidgetsBundle.swift PoemOfTheDayWidget.swift FavoritesWidget.swift]
  .map { |n| ext_group.new_reference(n) }
ext_sources += %w[PoemWidgetView.swift WidgetBackground.swift]
  .map { |n| views_group.new_reference(n) }
widget.add_file_references(ext_sources)
ext_group.new_reference('Info.plist')
ext_group.new_reference('PoeticWidgets.entitlements')
assets_ref = ext_group.new_reference('WidgetAssets.xcassets')
widget.resources_build_phase.add_file_reference(assets_ref)
puts 'added extension sources + assets'

# --- 5. Shared memberships into the widget target ---
shared_paths = %w[
  Color.swift SharedConstants.swift WidgetPayload.swift PoemExcerpt.swift
  WidgetDataStore.swift DeepLink.swift SupporterEntitlement.swift
]
shared_paths.each do |name|
  ref = project.files.find { |f| f.path.to_s == name || f.path.to_s.end_with?("/#{name}") }
  ref ||= project.files.find { |f| f.path.to_s.end_with?(name) }
  abort "shared file not found: #{name}" unless ref
  widget.source_build_phase.add_file_reference(ref)
end
puts "shared #{shared_paths.count} files into widget target"

# --- 6. Embed the extension in the app ---
app.add_dependency(widget)
embed = app.new_copy_files_build_phase('Embed Foundation Extensions')
embed.symbol_dst_subfolder_spec = :plug_ins
build_file = embed.add_file_reference(widget.product_reference)
build_file.settings = { 'ATTRIBUTES' => ['RemoveHeadersOnCopy'] }
puts 'embed phase added'

project.save

# --- 7. Sanity: the XCVersionGroup must survive the save ---
reopened = Xcodeproj::Project.open(File.join(ROOT, 'Poetic.xcodeproj'))
vg = reopened.objects.find { |o| o.isa == 'XCVersionGroup' }
children = vg.children.map(&:path)
abort "XCVersionGroup damaged: #{children.inspect}" unless
  children.include?('Poetic.xcdatamodel') && children.include?('Poetic 2.xcdatamodel')
puts "version group intact: #{children.inspect}"
puts 'saved'
