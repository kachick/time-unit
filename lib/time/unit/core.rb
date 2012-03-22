# Time::Unit
#   Copyright (C) 2010  Kenichi Kamiya

require 'forwardable'

class Time
  # @author Kenichi Kamiya
  class Unit
    extend Forwardable
    include Comparable

    VERSION = '0.0.6'.freeze
    Version = VERSION
    
    SECOND      = Rational 1, 1
    MILLISECOND = SECOND / 1000
    MICROSECOND = MILLISECOND / 1000
    NANOSECOND  = MICROSECOND / 1000
    PICOSECOND  = NANOSECOND / 1000
    MINUTE      = SECOND * 60
    HOUR        = MINUTE * 60
    DAY         = HOUR   * 24  

    UNIT_PATTERN = /\A(\d+)(day|hour|min(?:ute)?|sec(?:ond)?|millisecond|msec)s?\z/i

    BASE_RADIXES ={
      :hour        => HOUR,
      :day         => DAY
    }.freeze
    
    VERBOSE_RADIXES = BASE_RADIXES.merge(
      :second      => SECOND,
      :millisecond => MILLISECOND,
      :microsecond => MICROSECOND,
      :nanosecond  => NANOSECOND,
      :picosecond  => PICOSECOND,
      :minute      => MINUTE
    ).freeze
    
    SHORTER_RADIXES = BASE_RADIXES.merge(
      :sec         => SECOND,
      :msec        => MILLISECOND,
      :min         => MINUTE
    ).freeze
    
    RADIXES = SHORTER_RADIXES.merge(VERBOSE_RADIXES).freeze
    
    SHORT_UNIT_NAMES = SHORTER_RADIXES.sort_by{|key, val|val}.map{|key, val|key}.reverse.freeze
    LONG_UNIT_NAMES  = VERBOSE_RADIXES.sort_by{|key, val|val}.map{|key, val|key}.reverse.freeze
    
    if respond_to? :private_constant
      private_constant :BASE_RADIXES, :VERBOSE_RADIXES, :SHORTER_RADIXES, :SHORT_UNIT_NAMES, :LONG_UNIT_NAMES
    end
    
    class << self
      # @return [Time::Unit]
      def parse(str)
        seconds = 0
        
        str.split.each do |field|
          if UNIT_PATTERN =~ field
            unit = $2.downcase.to_sym
            seconds += ($1.to_i * RADIXES[unit])
          else
            raise ArgumentError, 'Unknown Format'
          end
        end
        
        new seconds, :second
      end
      
      private(*Forwardable.instance_methods(false))
      private

      # @macro [attach] define_reader
      #   @method $1()
      #   @return [Number]
      def define_reader(unit)
        define_method unit do
          rational = @second / RADIXES[unit]
          integer = rational.to_i
          rational == integer ? integer : rational
        end
      end
    end

    def initialize(size, unit=:second)
      replace size, unit
    end

    def_delegators(:@second,
      :to_i, :to_f, :to_r, :/, :divmod, :div, :quo, :modulo, :remainder, :zero?,
      :nonzero?, :to_int, :<=>, :step, :coerce, :*, :**, :%, :hash
    )

    define_reader :day
    define_reader :hour
    define_reader :minute
    define_reader :min
    define_reader :second
    define_reader :sec
    define_reader :millisecond
    define_reader :msec
    alias_method :days, :day
    alias_method :hours, :hour
    alias_method :minutes, :minute
    alias_method :seconds, :second
    alias_method :milliseconds, :millisecond
    alias_method :milli, :millisecond
    
    def eql?(other)
      kind_of?(other.class) && @second == other.second
    end
    
    alias_method :==, :eql?

    # @return [Time::Unit]
    def +(other)
      self.class.new(second + other)
    end

    # @return [Time::Unit]
    def -(other)
      if self >= other
        self.class.new(second - other)
      else
        raise ArgumentError, 'Keep plus number.'
      end
    end
    
    # @return [Strirng] separated a space and removed empty field
    def to_s(verbose=false)
      case verbose
      when false
        to_short_str
      when true
        to_verbose_str
      else
        raise ArgumentError, 'Choose verbose-option from [true, false].'
      end
    end
    
    # @return [Array<Number>]
    def to_a
      [].tap {|list|
        val  = 0
        rest = second
        
        [DAY, HOUR, MINUTE, SECOND].each do |radix|
          val, rest = rest.divmod(radix)
          list << val
        end
        
        msec = rest / MILLISECOND
        
        list << (msec == msec.to_i ? msec.to_i : raise('must not happen'))
      }
    end
    
    # @return [Integer]
    def sleep
      Kernel.sleep @second
    end
    
    private
    
    def replace(size, unit)
      raise ArgumentError, "Unknown unit." unless radix = RADIXES[unit]
      raise ArgumentError, 'Keep plus number.' unless size >= 0
      raise ArgumentError, 'Only Integer for msec.' if [:msec, :millisecond].include?(unit) and ! size.kind_of?(Integer)

      case size
      when Integer, Rational
        if (second = size * radix) % MILLISECOND == 0
          @second = second
          self
        else
          raise ArgumentError, 'Contain too small number.'
        end
      else
        raise ArgumentError, 'Choose from [Integer, Rational].'
      end
    end
    
    def nonempty_units
      to_a.each_with_index.select{|size, i|size > 0}
    end

    def to_short_str
      if (units = nonempty_units).any?
        units.map{|size, i|"#{size}#{SHORT_UNIT_NAMES[i]}"}.join(' ')
      else
        '0msec'
      end
    end

    def to_long_str
      if (units = nonempty_units).any?
        units.map{|size, i|"#{size}#{LONG_UNIT_NAMES[i]}#{size > 1 ? 's' : nil}"}.join(' ')
      else
        '0millisecond'
      end
    end
    
    alias_method :to_verbose_str, :to_long_str
  end
end