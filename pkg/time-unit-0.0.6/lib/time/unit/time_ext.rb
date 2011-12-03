require 'forwardable'
require_relative 'core'

module Time::Unit::TimeExtention
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
  extend Time::Unit::TimeExtention::EigenMethod
end