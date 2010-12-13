def operator_to_method(op = '')
  case op
  when '+' then 'add'
  when '=' then 'set'
  when '%' then 'del'
  end
end

def guparse(arg='')
  o = Array.new
  arg.scan(/(group|user):([^#{FS}]+)#{FS}?(.*)/) do |x|
    context = case x.shift
              when 'group' then 'Group'
              when 'user'  then 'Person'
              end

    name, operator, par = x.shift.split(/([\+%=])/)
    o << { :context => context, :name => name, :command => operator_to_method(operator), :parameters => par.split(',') } unless operator.nil?

    x.first.split(FS).each do |c|
      command, parameter = c.split('=')
      command += '='
      o << { :context => context, :name=> name, :command => command, :parameters => parameter}
    end
  end
  o
end

def show(me)
  entry = Object.const_get(me[:context]).find(me[:name])
  Object.const_get(me[:context]).name + "(#{entry.dn})." + "#{me[:command]}#{me[:parameters]}"
end

