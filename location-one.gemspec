# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "location-one/version"

Gem::Specification.new do |s|
  s.name        = "location-one"
  s.version     = LocationOne::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Karl Krukow"]
  s.email       = ["karl@lesspainful.com"]
  s.homepage    = "http://calaba.sh"
  s.summary     = %q{Location Simulation Client for Calabash and Frank}
  s.description = %q{Location Simulation Client for Calabash and Frank backends.}
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_paths = ["lib"]

  s.add_dependency( "geocoder","~>1.1")
  s.add_dependency( "json" )
  s.add_dependency( "httpclient","~> 2.3.3")

end
