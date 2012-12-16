module Cligu
  class List
    Cligu.contexts.register(self)

    def self.find(arg)
      case arg
      when /users?/
        attributes = %w(uidNumber gidNumber cn homeDirectory loginShell)
        puts Person.search(:attributes => attributes).map {|per| ([per.last['cn'], '*'] + attributes.map { |a| per.last[a] }).join(':') }
        Person
      when /groups?/
        puts Group.all.map {|g| "#{g.cn}:*:#{g.gidnumber}:#{g.members.join ','}" }
        Group
      end
    end
  end
end
