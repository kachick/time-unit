# time-unit
#   express the interval between two times
#
#   Copyright (C) 2010-2011  Kenichi Kamiya

require 'forwardable'

class Time
  # base unit is second.
  class Unit
    extend Forwardable
    include Comparable
    
    SECOND      = Rational(1, 1)
    MILLISECOND = SECOND / 1000
    MINUTE      = SECOND * 60
    HOUR        = MINUTE * 60
    DAY         = HOUR   * 24  
    
    BASE_RADIXES ={
      :hour        => HOUR,
      :day         => DAY
    }.freeze
    
    VERBOSE_RADIXES = BASE_RADIXES.merge(
      :second      => SECOND,
      :millisecond => MILLISECOND,
      :minute      => MINUTE
    ).freeze
    
    SHORTER_RADIXES = BASE_RADIXES.merge(
      :sec         => SECOND,
      :msec        => MILLISECOND,
      :min         => MINUTE
    ).freeze
    
    RADIXES = SHORTER_RADIXES.merge VERBOSE_RADIXES
    
    FIELD_PATTERN = /\A(\d+)(day|hour|min(?:ute)?|sec(?:ond)?|millisecond|msec)s?\z/i
    
    class << self
      def parse(str)
        seconds = 0
        
        str.split.each do |field|
          if FIELD_PATTERN =~ field
            unit = $2.downcase.to_sym
            seconds += ($1.to_i * RADIXES[unit])
          else
            raise ArgumentError, 'Unknown Format'
          end
        end
        
        new seconds, :second
      end
      
      module_eval do
        private
        
        def define_reader(unit, radix)
          define_method unit do
            rational = @second / radix
            integer = rational.to_i
            rational == integer ? integer : rational
          end
        end
        
        def define_writer(unit)
          define_method "#{unit}=" do |size|
            replace size, unit
          end
        end
        
        def define_accessor(unit, radix)
          define_reader unit, radix
          define_writer unit
        end
      end
    end

    def initialize(size, unit=:second)
      replace size, unit
    end
    
    def_delegators(:@second,
      :to_i, :to_f, :to_r, :/, :divmod, :div, :quo, :modulo, :remainder, :zero?,
      :nonzero?, :to_int, :<=>, :step, :coerce, :*, :**, :%
    )
    
    RADIXES.each_pair do |unit, radix|
      define_accessor unit, radix
    end
    
    def hash
      [self.class, @second].hash
    end
    
    def eql?(other)
      hash.equal? other.hash
    end

    def +(other)
      self.class.new(second + other)
    end
    
    def -(other)
      self.class.new(
        if self >= other
          second - other
        else
          raise ArgumentError, 'Keep plus number.'
        end
      )
    end
    
    # return: str separated a space and removed 0 char
    def to_s(verbose=false)
      units = (
        case verbose
        when false
          SHORTER_RADIXES
        when true
          VERBOSE_RADIXES
        else
          raise ArgumentError, 'Choose verbose-option in [true or false].'
        end
      ).sort_by{|key, val|val}.map{|key, val|key}.reverse

      if (list = to_a).all?{|size|size == 0}
        '0'
      else
        list.each_with_index.select{|size, i|size > 0}.map{|size, i|"#{size}#{units[i]}"}.join(' ')
      end
    end
    
    private
    
    def replace(size, unit)
      raise ArgumentError, 'Keep plus number.' unless size >= 0
      raise ArgumentError, 'Only Integer for msec.' if size.kind_of? Rational and [:msec, :millisecond].include? unit

      case size
      when Integer, Rational
        if radix = RADIXES[unit]
          if (@second = size * radix) % MILLISECOND == 0
            @second
          else
            raise ArgumentError, 'Too small number.'
          end
        else
          raise ArgumentError, "Out of range. Choose in [#{RADIXES.keys.join(',')}]."
        end
      else
        raise ArgumentError, "Choose in [Integer, Rational]."
      end
    end

    def to_a
      [].tap do |list|
        val  = 0
        rest = second
        
        [DAY, HOUR, MINUTE, SECOND].each do |radix|
          val, rest = rest.divmod(radix)
          list << val
        end
        
        msec = rest / MILLISECOND
        
        list << (msec == msec.to_i ? msec.to_i : raise('must not happen'))
      end
    end
  end
end
