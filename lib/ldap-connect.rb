#!/usr/bin/ruby
# -*- coding: utf-8 -*-

require 'active_ldap'
require 'uri'
require 'json'

def ldap_connect
  ldap = { }
  Dir['/etc/ldap/ldap.conf','/etc/ldap.conf'].each do |ldap_configfile|
    File.open(ldap_configfile).grep(/^(host|base|uri)/i).each do |m|
      ldap.merge! Hash[*(m.downcase.split)]
    end
  end
  ldap['host'] = URI.parse(ldap['uri']).host if ldap['uri']

  raise 'Please set ldap host and base in ldap.conf' unless ldap['host'] and ldap['base']

  ActiveLdap::Base.setup_connection(
                                    :allow_anonymous => true,
                                    :host => ldap['host'],
                                    :base => ldap['base'],
                                    :try_sasl => true
                                    )
end

def json_config
  o = {"ldap"=>{"groups"=>{"prefix"=>"ou=groups"}, "people"=>{"prefix"=>"ou=people"}}}

  Dir['/etc/cligu.json', File.expand_path('~/.cligu.json')].each do |jc|
    o.update JSON.load(File.open(jc))
  end
  o
end


class Group < ActiveLdap::Base
  ldap_options=json_config['ldap']

  ldap_mapping :dn_attribute => 'cn',
               :prefix => ldap_options['groups']['prefix'],
               :classes => ['top', 'posixGroup']

  def members
    [self.memberUid || []].flatten #any nicer way?
  end
  
  def members=( m = [] )
    self.memberUid = m
    self.save!
    [self.memberUid || []].flatten
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

class Person < ActiveLdap::Base
  #TORF: DRY out the following call
  ldap_options=json_config['ldap']

  ldap_mapping :dn_attribute => 'uid',
               :prefix => ldap_options['people']['prefix'],
               :classes => ['inetOrgPerson', 'posixAccount']
  belongs_to :ldapgroups, :class_name => 'Group', :many => 'memberUid', :primary_key => 'uid'

  #TODO: Handle primary groups

  def groups
    self.ldapgroups.collect &:cn
  end

  def groups=(gg = [])
    self.ldapgroups = Group.find(*[gg])
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
