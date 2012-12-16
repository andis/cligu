module Cligu
  class Command
    attr_reader :executed_at

    def initialize(args, &block)
      @context = args.delete(:context) or raise(ArgumentError.new("Need :context"))
      @name = args.delete(:name) or raise(ArgumentError.new("Need :name"))
      @jobs = Array(args.fetch :jobs, nil)
      @errors = []

      @config = args.fetch :config, Cligu::Config::Global
    end

    def call(context = find_context)
      Cligu.log.info { "[#{object_id}] Executing " << to_s }
      obj = context.find(@name)

      results = @jobs.map do |job|
        result = obj.__send__(*job)
        Cligu.log.warn { pretty_puts result } unless result.nil?
        result
      end

      if obj.valid?
        @config.noop_wrapper { obj.save! }
      else
        Cligu.log.error "Error saving #{to_s}"
        obj.errors.each do |e1,e2|
          @errors << { Time.now => [e1, e2] }
          Cligu.log.error "  #{e1} #{e2}"
        end
      end if obj.respond_to?(:valid?)

      @executed_at = Time.now
      results
    rescue => e
      raise e.exception("[#{object_id}] #{e.message}")
    end

    def rescued_call(context = find_context)
      call(context)
    rescue => e
      @errors << { Time.now => e }
      Cligu.log.error { e.message }
    end

    def errorcount
      @errors.count
    end

    def to_s
      jobs = @jobs.collect do |job|
        bla = job.first.to_s
        bla += "(#{job[1..-1].dup.join(',')})" unless job[1..-1].empty?
        bla
      end
      "#@context('#@name'):#{jobs.join(':')}"
    end

    def [](key)
      instance_variable_get("@#{key}")
    end

    private
    def find_context
      ContextFinder.new @context, @name
    end

    def pretty_puts(obj)
      if obj.to_s == obj
        obj
      elsif obj.nil?
        ''
      else
        obj.pretty_inspect
      end
    end
  end
end
