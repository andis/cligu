# -*- coding: utf-8 -*-
require "cligu/context_finder"

module Cligu
  class Contexts
    def initialize(data = {})
      @data = data
    end

    def get(context)
      @data.find do |dat|
        dat.first.match(context)
      end.last
    end

    def cli_names
      @data.keys
    end

    def register(klass, cli_name = klass.to_s.downcase.split('::').last)
      @data[cli_name.to_s] = klass
    end
  end

  CONTEXTS = Contexts.new

  def self.contexts
    CONTEXTS
  end
end
