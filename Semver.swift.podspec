Pod::Spec.new do |s|
  s.name         = "Semver.swift"
  s.version      = "1.1.0"
  s.license      = "MIT"
  s.summary      = "Semantic Versioning implementation in Swift"
  s.homepage     = "https://github.com/glwithu06/Semver.swift"
  s.author       = { "Nate Kim" => "glwithu06@gmail.com" }
  s.frameworks   = "Foundation"
  s.source       = { :git => "https://github.com/glwithu06/Semver.swift.git", :tag => "#{s.version}" }
  s.source_files  = "Sources/*.swift"
  s.ios.deployment_target = "8.0"
  s.osx.deployment_target = "10.11"
  s.tvos.deployment_target = "9.0"
  s.watchos.deployment_target = "2.0"
end
