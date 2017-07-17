Pod::Spec.new do |s|
  s.name             = 'EYSnapAlert'
  s.version          = '0.3.0'
  s.summary          = 'A simple alert box for iOS, with customized style.'


  s.description      = <<-DESC
EYSnapAlert is a simple alert box for iOS, written with Swift, with simple API, customized styles.
                       DESC

  s.homepage         = 'https://github.com/enix223/EYSnapAlert'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'enix223' => 'enix223@163.com' }
  s.source           = { :git => 'https://github.com/enix223/EYSnapAlert.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/enixyu'

  s.ios.deployment_target = '8.0'

  s.source_files = 'EYSnapAlert/Classes/**/*'
end
