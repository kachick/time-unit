# Time::Unit
#   Copyright (C) 2010-2011  Kenichi Kamiya

require 'forwardable'
require_relative 'core'

module Time::Unit::TimeExtention
  module EigenMethod
    extend Forwardable

    class << self
      private *Forwardable.instance_methods(false)
    end

    ##
    #
    def_delegator ::Time::Unit, :new, :Unit
  end
end

class Time
  extend Time::Unit::TimeExtention::EigenMethod

  alias_method :original_minus, :-
  
  def -(other)
    if other.kind_of? Time
      self.class.Unit((original_minus(other).to_r * 1000).to_i, :msec)
    else
      original_minus other
    end
  end
end