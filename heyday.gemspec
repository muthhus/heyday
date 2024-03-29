# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "lib/heyday/version"

Gem::Specification.new do |s|
  s.name = "heyday"
  s.version = Heyday::VERSION
  s.platform = Gem::Platform::RUBY
  s.authors = ["Adam Stasio"]
  s.email = ["adamstasio@gmail.com"]
  s.homepage = "https://github.com/thatguy/heyday"
  s.summary = "Integrate Fullcalendar jQuery calendar plugin with a Rails application"
  s.description = "Integrate Fullcalendar jQuery calendar plugin with a Rails application"
  s.files = `git ls-files`.split("\n")
  s.executables = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  s.add_dependency('ice_cube', '>= 0.6.4')
  s.add_dependency('activesupport')
end
