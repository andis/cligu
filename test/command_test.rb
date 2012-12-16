require File.dirname(__FILE__) + "/test_helper"
require 'cligu/arg_parser'
include MiniTest

module Cligu
  describe Command do
    it 'initializes with context and name' do
      cmd = Command.new(:context => 'Bla', :name => 'blubb')
      assert_instance_of(Command, cmd)
    end

    describe '#call' do
      before do
        @context = Mock.new
        @context_instance = Mock.new
        @name = Mock.new
        @context.expect :find, @context_instance, [@name]
      end

      it 'sends find to context' do
        # 'Given' in before block

        cmd = Command.new(:context => @context, :name => @name)
        cmd.call
        @context.verify
      end

      it 'sends simple job to context' do
        job = ["foo_to_send"]
        @context_instance.expect :foo_to_send, nil

        cmd = Command.new(:context => @context, :name => @name, :jobs => [job])
        cmd.call
        @context.verify
        @context_instance.verify
      end

      it 'sends job with single parameter to context' do
        job = ["foo_to_send", expected_arg = Mock.new]
        @context_instance.expect :foo_to_send, nil, [expected_arg]

        cmd = Command.new(:context => @context, :name => @name, :jobs => [job])
        cmd.call
        @context.verify
        @context_instance.verify
      end

      it 'sends job with multiple parameters to context' do
        job = ["foo_to_send", expected_arg = [Mock.new, Mock.new]]
        @context_instance.expect :foo_to_send, nil, [expected_arg]

        cmd = Command.new(:context => @context, :name => @name, :jobs => [job])
        cmd.call
        @context.verify
        @context_instance.verify
      end
    end
  end
end
