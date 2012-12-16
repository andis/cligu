require 'uri'
require 'ostruct'

module Cligu
  class Config
    attr_accessor :ldap_server
    attr_accessor :noop
    attr_accessor :ldap_config

    DEFAULT = {
      :cligu_configfiles => [
                             ENV['CLIGUCONF'] &&
                               File.expand_path(ENV['CLIGUCONF']) || '',
                             '/etc/cligu_conf.rb',
                             '/etc/cligu.d/*_conf.rb',
                             File.expand_path('~/.local/share/cligu/*_conf.rb'),
                             File.expand_path('~/.cligu_conf.rb'),
                            ],
      :ldap_configfiles => [
                             '/etc/ldap/ldap.conf',
                             '/etc/ldap.conf',
                             File.expand_path('~/.ldaprc'),
                             ENV['LDAPRC'] &&
                               File.expand_path(ENV['LDAPRC']) || ''
                            ]
    }

    def initialize(opts = {})
      @ldap_configfiles = opts.fetch(:ldap_configfiles, DEFAULT[:ldap_configfiles])
      self.ldap_server = opts.fetch(:ldap_server, parse_ldap_conf)
      self.ldap_config ||= {}

      cligu_configfiles = opts.fetch(:cligu_configfiles, DEFAULT[:cligu_configfiles])
      eval_cligu_configfiles(cligu_configfiles)
    end

    def noop_wrapper(&block)
      block.call unless @noop
    end

    private
    def parse_ldap_conf(reader = File.method(:readlines))
      out = {}

      Dir.glob(@ldap_configfiles).each do |ldap_configfile|
        lines = reader.call(ldap_configfile)
        lines.grep(/^(host|base|uri)/i).each do |match|
          key, val = match.downcase.split[0..1]
          out[key.to_sym] = val
          out[:host] = URI(val).host if key == 'uri'
        end
      end

      out.delete(:uri)
      raise "Please set ldap host and base in one of #{DEFAULT[:ldap_configfiles].join(' ')}" unless out[:host] && out[:base]

      @ldap_server = out
    end

    def eval_cligu_configfiles(files, reader = File.method(:read))
      Dir.glob(files).each do |file|
        ostructs = instance_eval(<<-EOC, file)
        ldap_config = OpenStruct.new(self.ldap_config)
        ldap_server = OpenStruct.new(self.ldap_server)
        #{reader.call(file)}
        [ldap_config, ldap_server]
        EOC
        self.ldap_config = os_to_h(ostructs[0])
        self.ldap_server = os_to_h(ostructs[1])
      end
    end

    def os_to_h(ostruct)
      if ostruct.respond_to?(:to_hash)
        ostruct.to_hash
      else
        ostruct.send(:table)
      end
    end

    Global = self.new
  end
end
