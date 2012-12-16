#!/usr/bin/ruby
# -*- coding: utf-8 -*-

require 'active_ldap'
require 'uri'
require 'json'

require 'cligu/config'

module Cligu
  class ContextFinder
    [:to_s,:inspect,:=~,:===, :respond_to?].each do |m|
      undef_method m
    end

    def initialize(context, name)
      @context = context
      @name = name
      @tofind = nil
      @found = nil

    end

    def find(tofind)
      @tofind = tofind
      self
    end

    def create
      @found = @context.create(@tofind)
    end

    def method_missing(*args, &block)
      @found ||= @context.find(@tofind)
      @found.__send__(*args, &block)
    end
  end
end
