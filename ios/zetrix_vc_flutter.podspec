Pod::Spec.new do |spec|
  spec.name          = 'zetrix_vc_flutter'
  spec.version       = '1.0.0'
  spec.summary       = 'A Flutter plugin for platform-specific Zetrix VC(VP Generation) functionality with BBS Signature.'
  spec.description   = 'This plugin adds platform-specific functionality to Zetrix VC(VP Generation)  on iOS.'
  spec.homepage      = 'https://example.com/zetrix'
  spec.license       = { :type => 'MIT', :file => 'LICENSE' }
  spec.author        = { 'Author Name' => 'email@example.com' }
  spec.ios.deployment_target = '12.0'

  # Flutter plugin classes (defined for Dart to communicate with Objective-C code)
  spec.source_files = 'Classes/**/*.{h,m}'

  # Add the static library and header files
  spec.vendored_libraries = 'Frameworks/libbbs.a'
  spec.vendored_headers = 'Frameworks/*.h'

  # Add additional resources if required by your `.xcodeproj` or static library
end
