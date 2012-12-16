require 'logger'
require 'cligu/version'

module Cligu
  FS = ':' #Field seperator

  def self.log
    @logger ||= Logger.new($stdout)
  end

  def log
    Cligu.log
  end
end


require 'cligu/cli'
require 'cligu/ldap-connect'
