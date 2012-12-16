lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'cligu/version'
require 'rake'


Gem::Specification.new do |s|
  s.name = 'cligu'
  s.version = Cligu::VERSION
  s.summary = %q{Manage posix groups and users in openldap with a fancy syntax}
  s.authors = 'Andi Fink'
  s.email = 'finkzeug@gmail.com'

  s.files         = FileList['lib/**/*.rb', 'bin/*', '[A-Z]*', 'test/**/*'].to_a
  s.test_files    = FileList['test/**/*'].to_a
  s.executables   = FileList['bin/*'].to_a.map{ |f| File.basename(f) }

  s.require_paths = ["lib"]
  s.add_dependency 'activeldap'
  s.add_dependency 'ruby-ldap'
  s.add_dependency 'json' if RUBY_VERSION < "1.9"
  s.add_development_dependency 'rake'
  s.add_development_dependency 'minitest' if RUBY_VERSION < "1.9"
  s.bindir = 'bin'
end
