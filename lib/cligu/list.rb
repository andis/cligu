module Cligu
  class List
    Cligu.contexts.register(self)

    def self.find(arg)
      case arg
      when /users?/
        attributes = %w(uidNumber gidNumber cn homeDirectory loginShell)
        puts People.search(:attributes => attributes).map {|per| ([per.last['cn'], '*'] + attributes.map { |a| per.last[a] }).join(':') }
        People
      when /groups?/
        puts Groups.all.map {|g| "#{g.cn}:*:#{g.gidnumber}:#{g.members.join ','}" }
        Groups
      end
    end
  end
end
