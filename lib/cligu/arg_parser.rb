require 'ostruct'
require 'pp'

require 'cligu/contexts'
require 'cligu/command'
require 'cligu/list'

module Cligu
  class ArgParser
    def initialize(argv, opts = {})
      @data = []
      @command_klass = opts.fetch(:command_klass, Command)
      parse(argv)
    end

    def parse(argv)
      Array(argv).each do |arg|
        @data << @command_klass.new(self.class.send :parse, arg)
      end
    end

    def each(&block)
      @data.each &block
    end

    def run_with_retry(this_many = 1)
      this_many.times do
        @data.reject { |c| 
          c.executed_at or 
          c.errorcount > this_many
        }.each &:rescued_call
      end
    end

    def errors?
      @data.any? {|d| d.errorcount > 0 }
    end

    class << self
      private

      def operator_to_method(op = '')
        case op
        when '+' then 'add'
        when '=' then 'set'
        when '%' then 'del'
        end
      end

      def parse(arg='')
        cli_names = Cligu.contexts.cli_names.join("|")
        x = arg.scan(/^(#{cli_names}):([^#{FS}]+)#{FS}?(.*)/)

        result = x.first or raise "cannot parse #{arg}"

        context = Cligu.contexts.get(result.first)

        name, operator, parameters = result[1].split(/([\+%=])/)
        jobs = []

        if operator
          jobs << [operator_to_method(operator), parameters.split(',')]
        end

        result[2].split(FS).each do |command|
          parts = command.split(/([\+%=])/)

          values = parts[2] && parts[2] != '__EMPTY__' ? parts[2].split(',') : nil
          jobs << [parts[0..1].join, values].compact
        end

        {
          :context => context,
          :name=> name,
          :jobs => jobs
        }
      end
    end
  end

  class PrettyErrors
    def initialize(debug = false, &block)
      return block.call if debug
      begin
        block.call
      rescue => e
        Cligu.log.error { e.message }
      end
    end
  end
end
