
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "blazer/version"

Gem::Specification.new do |spec|
  spec.name          = "sql-jarvis"
  spec.version       = Blazer::VERSION
  spec.authors       = ["ThanhKhoaIT"]
  spec.email         = ["thanhkhoait@gmail.com"]
  spec.summary       = "Fork from ankane! Explore your data with SQL. Easily create charts and dashboards, and share them with your team."
  spec.homepage      = "https://github.com/ThanhKhoaIT/blazer"
  spec.license       = "MIT"

  spec.author        = "Andrew Kane"
  spec.email         = "andrew@chartkick.com"

  spec.files         = Dir["*.{md,txt}", "{app,config,lib}/**/*"]
  spec.require_path  = "lib"

  spec.required_ruby_version = ">= 2.3"

  spec.add_dependency "railties", ">= 4.2"
  spec.add_dependency "activerecord", ">= 4.2"
  spec.add_dependency "haml-rails"
  spec.add_dependency "zip-zip"
  spec.add_dependency "axlsx"
  spec.add_dependency "axlsx_rails"
  spec.add_dependency "chartkick"
  spec.add_dependency "safely_block", ">= 0.1.1"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
end
