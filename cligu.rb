#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
def rr(lib)
  require File.join(File.dirname(__FILE__),lib)
end

require 'optparse'
require 'json'
rr 'lib/util.rb'

FS = ':' #Field seperator
verbose = false
quiet = false
noop = false
connect = true

OptionParser.new do |opts|
  opts.banner = <<-"EOT"
Usage: #{File.basename __FILE__} [options] [group:<name>[+=%members][#{FS}attribute=value]*] [user:<name>[+=%groups][#{FS}attribute=value]*]

Examples:
group:staff+bob,jon,ron group:authors%jon,jack
user:alice+staff#{FS}loginshell=/bin/zsh#{FS}mail=alice@example.com

EOT

  opts.on("-v", "--[no-]verbose", "Run verbosely") { |v| verbose = v }
  opts.on("-n", "--noop", "just pretend") { |n| noop = n }
  opts.on("-q", "--quiet", "Hide even moderate amounts of information") { |q| quiet = q }
  opts.on("-d", "--[no-]connect", "don’t connect to server") { |d| connect = d }
end.parse!

o = []
ARGV.each do |a|
  o += guparse(a)
end

jj o if verbose


if connect
  rr 'lib/ldap-connect.rb'
  ldap_connect
end

o.each do |c|
  print show(c) unless quiet
  entry = Object.const_get(c[:context]).find(c[:name])
  entry.send(c[:command], c[:parameters])
  entry.save! unless noop
  puts ': ok' unless quiet
end
