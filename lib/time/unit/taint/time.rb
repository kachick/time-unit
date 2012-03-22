class Time
  alias_method :original_minus, :-
  
  def -(other)
    if other.kind_of? Time
      self.class.Unit((original_minus(other).to_r * 1000).to_i, :msec)
    else
      original_minus other
    end
  end
end