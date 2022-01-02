Pod::Spec.new do |s|
  s.name             = 'CodableFiles'
  s.version          = '0.1.0'
  s.summary          = 'Save and load Codable objects from DocumentDirectory on iOS Devices.'
  s.homepage         = 'https://github.com/egzonpllana/CodableFiles'
  s.license          = { :type => 'MIT', :file => 'LICENSE.md' }
  s.author           = { 'Egzon Pllana' => 'docpllana@gmail.com' }
  s.source           = { :git => 'https://github.com/egzonpllana/CodableFiles.git', :tag => s.version.to_s }
  s.ios.deployment_target = '13.0'
  s.swift_version = '5.0'
  s.source_files = 'Sources/CodableFiles/**/*'
end