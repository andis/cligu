# -*- coding: utf-8 -*-
require 'optparse'
require 'yaml'
require 'logger'
require 'ostruct'

require 'cligu'
require 'cligu/arg_parser'
require 'cligu/config'
require 'cligu/ldap-connect'

class Cligu::Cli
  include Cligu

  def initialize(argv = ARGV)
    @argv = Array(argv)
    @connect = true
    log.level = Logger::INFO

    parse_argv(@argv)
  end

  def parse_argv(argv = @argv)
    OptionParser.new do |opts|
      opts.banner = <<-"EOT"
Usage: #{File.basename __FILE__} [options] [group:<name>[+=%members][#{FS}attribute=value]*] [user:<name>[+=%groups][#{FS}attribute=value]*]

Examples:
group:staff+bob,jon,ron group:authors%jon,jack
user:alice+staff#{FS}loginshell=/bin/zsh#{FS}mail=alice@example.com

EOT

      opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
        log.level = Logger::DEBUG
      end

      opts.on("-n", "--noop", "just pretend") do |n|
        Config::Global.noop = n
      end

      opts.on(
        "-q",
        "--quiet",
        "Hide even moderate amounts of information"
        ) do |q|
        log.level = Logger::WARN
        @quiet = q
      end

      opts.on("-d", "--[no-]connect", "don’t connect to server") do |d|
        @connect = d
      end

      opts.on('--irb', 'drop into irb session') do
        require 'irb'
        Connect.ldap_connect if @connect
        ARGV.clear
        IRB.start
        catch(:IRB_EXIT) { @exit = true }
      end

      opts.on_tail("--version", "Show version") do
        puts VERSION
        @exit = true
      end
    end.parse!(argv)
  end

  def run
    return if @exit

    log.debug { @argv.to_yaml }
    commands = ArgParser.new(@argv)
    log.debug { commands.to_yaml }

    PrettyErrors.new(log.level <= Logger::DEBUG) do
      Connect.ldap_connect if @connect
      commands.run_with_retry
    end

    exit !commands.errors?
  end
end
