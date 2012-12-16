require File.dirname(__FILE__) + "/test_helper"
require 'cligu/arg_parser'
include MiniTest

module Cligu
  describe ArgParser do
    describe 'instantiate' do
      it 'instantiates properly' do

        klass = Mock.new
        Cligu.contexts.register(klass, 'mock_context')
        ap = ArgParser.new('mock_context:bla')
      end
    end

    describe '::parse with banner examples' do
      it 'parses user:alice+staff' do
        expected = {
          :context => People,
          :name => 'alice',
          :jobs => [['add', ['staff']]]
        }

        parsed = ArgParser.send(:parse, 'user:alice+staff')
        assert_equal(expected, parsed)
      end

      it 'parses user:alice:loginshell=/bin/zsh' do
        expected = {
          :context => People,
          :name => 'alice',
          :jobs => [['loginshell=', ['/bin/zsh']]]
        }

        parsed = ArgParser.send(:parse, 'user:alice:loginshell=/bin/zsh')
        assert_equal(expected, parsed)
      end

      it 'parses group:staff+bob,jon,ron' do
        expected = {
          :context => Groups,
          :name => 'staff',
          :jobs => [['add', %w(bob jon ron)]]
        }

        parsed = ArgParser.send(:parse, 'group:staff+bob,jon,ron')
        assert_equal(expected, parsed)
      end

      it 'parses group:authors%jon,jack' do
        expected = {
          :context => Groups,
          :name => 'authors',
          :jobs => [['del', %w(jon jack)]]
        }

        parsed = ArgParser.send(:parse, 'group:authors%jon,jack')
        assert_equal(expected, parsed)
      end

      it 'parses user:foouser:to_ldif' do
        expected = {
          :context => People,
          :name => 'foouser',
          :jobs => [['to_ldif']]
        }

        parsed = ArgParser.send(:parse, 'user:foouser:to_ldif')
        assert_equal(expected, parsed)
      end

      it 'parses user:foouser=foogroup:key=value1,value2,value3:to_ldif' do
        expected = {
          :context => People,
          :name => 'foouser',
          :jobs => [['set', ['foogroup']],['key=', ['value1', 'value2', 'value3']], ['to_ldif']]
        }

        parsed = ArgParser.send(:parse, 'user:foouser=foogroup:key=value1,value2,value3:to_ldif')
        assert_equal(expected, parsed)
      end
    end

    describe 'list feature' do
      it 'parses list:users' do
        expected = {
          :context => List,
          :name => 'users',
          :jobs => []
        }

        parsed = ArgParser.send(:parse, 'list:users')
        assert_equal(expected, parsed)
      end
    end
  end
end
