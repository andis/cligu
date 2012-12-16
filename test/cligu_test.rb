require File.dirname(__FILE__) + "/test_helper"
require 'cligu/cli'

module Cligu
  describe Cli do
    it 'shows the version' do
      argv = '--version'
      lambda {
        Cli.new(argv).run
      }.must_output "#{VERSION}\n"
    end
  end
end
