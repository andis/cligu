#!/usr/bin/ruby
# -*- coding: utf-8 -*-

require 'active_ldap'
require 'uri'
require 'json'

require 'cligu/config'

module Cligu
  module Connect
    def self.ldap_connect
      ldap_server = Config::Global.ldap_server

      ActiveLdap::Base.
         setup_connection(
                          :allow_anonymous => true,
                          :host => ldap_server[:host],
                          :base => ldap_server[:base],
                          :try_sasl => true
                          )
    end
  end

  class Groups < ActiveLdap::Base
    this_class = name.split('::').last.downcase

    ldap_options =
      Config::Global.ldap_config.reverse_merge this_class => { "prefix" => "ou=#{this_class}" }

    ldap_mapping :dn_attribute => 'cn',
    :prefix => ldap_options[this_class]['prefix'],
    :classes => ['top', 'posixGroup']

    Cligu.contexts.register(self, 'groups?')

    def members
      Array(self.memberUid)
    end

    def members=( m = [] )
      self.memberUid = m
      self.save!
      members
    end

    #Question: How do I DRY the following defs?
    #I only define them, b/c I don’t know how to __send__ -= and |=
    alias_method :set, :members=

    def add( m=[] )
      self.members |= m
    end

    def del( m=[] )
      self.members -= m
    end
  end

  class Users < ActiveLdap::Base
    this_class = name.split('::').last.downcase

    ldap_options =
      Config::Global.ldap_config.reverse_merge this_class => { "prefix" => "ou=People" }

    ldap_mapping :dn_attribute => 'uid',
    :prefix => ldap_options[this_class]['prefix'],
    :classes => ['inetOrgPerson', 'posixAccount']
    belongs_to :ldapgroups, :class => Groups, :many => 'memberUid', :primary_key => 'uid'

    Cligu.contexts.register(self, 'user')

    #TODO: Handle primary groups

    def groups
      self.ldapgroups.collect(&:cn)
    end

    def groups=(gg = [])
      self.ldapgroups = Groups.find(Array(gg))
      groups
    end

    alias_method :set, :groups=

    def add( m=[] )
      self.groups |= m
    end

    def del( m=[] )
      self.groups -= m
    end
  end
end
