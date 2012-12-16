lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)


require 'rake/testtask'
require 'pathname'
require 'cligu/version'

Rake::TestTask.new do |t|
  t.pattern = 'test/*_test.rb'
end

desc "Build deb package"
task :deb do
  pkgprefix  = ENV['PKGPREFIX']  || ENV['pkgprefix']  || ''
  pkgname    = ENV['PKGNAME']    || ENV['pkgname']    || File.basename(Dir.pwd)
  pkgversion = ENV['PKGVERSION'] || ENV['pkgversion'] || Cligu::VERSION
  fpmbin     = ENV['FPMBIN']     || ENV['fpmbin']     || 'fpm'
  tmpdir = '/tmp/cligu-deb'

  FileUtils.mkdir_p tmpdir
  Dir.chdir tmpdir do
    puts Dir.pwd
    open('Gemfile', 'w') do |f|
      f.puts "source :rubygems"
      f.puts "gem 'cligu', :git => '#{File.dirname(__FILE__)+'/.git'}'"
    end
    sh "bundle install --path=lib/#{pkgname} --binstubs --standalone"

    Pathname.glob("bin/*").reject { |r| r.fnmatch "**/#{pkgname}" }.each &:delete
    sh %Q(#{fpmbin} --version #{pkgversion}-#{Time.now.strftime('%Y%m%d')} -t deb --deb-user root --deb-group root -x '*/cache*' -x '*/test*' -x '*/example*' -x '*/spec*' -x '*/*.java' -x '*/*.o' -x '*/*.gemspec' -x '*/*.git/*' -x '*/.bundle*' -x '**/Gemfile*' -s dir --prefix /usr/local -n #{pkgprefix}#{pkgname} -C #{tmpdir} .)
  end
end
