Pod::Spec.new do |s|
  s.name             = 'adapty_ui_flutter'
  s.version          = '1.0.0'
  s.summary          = 'AdaptyUI flutter plugin.'
  s.description      = <<-DESC
A new Flutter plugin project.
                       DESC
  s.homepage         = 'https://adapty.io/'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Adapty' => 'contact@adapty.io' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.ios.dependency 'AdaptyUI'
  s.platform = :ios, '13.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.3'
end
