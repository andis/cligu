require File.dirname(__FILE__) + "/test_helper"
require 'cligu/config'

module Cligu
  describe Config do
    it 'parses simple ldap.conf' do
      simple = [
                "BASE dc=example,dc=com",
                "URI ldap://ldap.example.com"
               ]

      c = Config.new(:ldap_server => '')
      parsed = c.send(:parse_ldap_conf, proc {simple} )

      c.ldap_server[:base].must_equal 'dc=example,dc=com'
      c.ldap_server[:host].must_equal 'ldap.example.com'
    end

    it 'raises exception when host or base are missing' do
      c = Config.new(:ldap => '')
      proc do
        parsed = c.send(:parse_ldap_conf, proc {[]} )
      end.must_raise RuntimeError
    end

    it 'take values from a config file' do
      c = Config.new(:cligu_configfiles => '')
      content = "ldap_config.foo = 'bar'"
      c.send(:eval_cligu_configfiles, '/', proc { content })

      c.ldap_config[:foo].must_equal 'bar'
    end
  end
end
