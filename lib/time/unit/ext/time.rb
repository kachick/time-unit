require 'forwardable'

module Time::Unit::TimeExtension
  module EigenMethod
    extend Forwardable

    class << self
      private(*Forwardable.instance_methods(false))
    end

    ##
    #
    def_delegator ::Time::Unit, :new, :Unit
  end
end

class Time
  extend Time::Unit::TimeExtension::EigenMethod
end