# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "rainbow-template/version"

Gem::Specification.new do |s|
  s.name        = "rainbow-template"
  s.version     = Rainbow::Template::VERSION
  s.authors     = ["Poga Po"]
  s.email       = ["poga.bahamut@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{a tumblr-like template engine}
  s.description = %q{a logic-less, never-throw-exception template engine}

  s.rubyforge_project = "rainbow-template"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  s.add_runtime_dependency "json"
end
