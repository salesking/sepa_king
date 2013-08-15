# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'sepa/version'

Gem::Specification.new do |s|
  s.name = %q{king_sepa}
  s.version = SEPA::VERSION

  s.required_rubygems_version = Gem::Requirement.new('>= 0') if s.respond_to? :required_rubygems_version=
  s.authors = ['Georg Leciejewski', 'Georg Ledermann']
  s.date = %q{2013-08-10}
  s.summary = %q{Generate SEPA bank transfers .. the easy way}
  s.description = %q{}
  s.email = %q{gl@salesking.eu}
  s.extra_rdoc_files = ['README.markdown']
  s.executables   = nil
  s.files         = `git ls-files`.split("\n").reject{|i| i[/^docs\//] }
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")

  s.homepage = %q{http://github.com/salesking/sepa_king}
  s.require_paths = ['lib']
  s.rubygems_version = %q{1.6.2}

  s.add_runtime_dependency 'i18n'

  s.add_development_dependency 'rspec'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'rake', '>= 0.9.2'
  s.add_development_dependency 'libxml-ruby'
end
