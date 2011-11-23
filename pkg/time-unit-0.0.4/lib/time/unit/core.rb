# Time::Unit
#   Copyright (C) 2010-2011  Kenichi Kamiya
#   documented for YARD format

require 'forwardable'

class Time
  # @author Kenichi Kamiya
  # * express the interval between two times
  # * internal base unit is second
  class Unit
    extend Forwardable
    include Comparable
    
    VERSION = '0.0.4'.freeze
    Version = VERSION
    
    SECOND      = Rational 1, 1
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
    
    RADIXES = SHORTER_RADIXES.merge(VERBOSE_RADIXES).freeze
    
    FIELD_PATTERN = /\A(\d+)(day|hour|min(?:ute)?|sec(?:ond)?|millisecond|msec)s?\z/i
    
    class << self
      # @return [Time::Unit]
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
  
      # @macro [attach] define_changer
      #   @method $1=(size)
      #   @param size new content
      #   @return [Time::Unit] self(content replaced)
      def define_changer(unit)
        define_method "#{unit}=" do |size|
          replace size, unit
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

    define_reader :day
    define_reader :hour
    define_reader :minute
    define_reader :min
    define_reader :second
    define_reader :sec
    define_reader :milisecond
    define_reader :msec

    define_changer :day
    define_changer :hour
    define_changer :minute
    define_changer :min
    define_changer :second
    define_changer :sec
    define_changer :milisecond
    define_changer :msec

    # @return [Number]
    def hash
      [self.class, @second].hash
    end
    
    def eql?(other)
      hash.equal? other.hash
    end

    # @return [Time::Unit]
    def +(other)
      self.class.new(second + other)
    end

    # @return [Time::Unit]
    def -(other)
      self.class.new(
        if self >= other
          second - other
        else
          raise ArgumentError, 'Keep plus number.'
        end
      )
    end
    
    # @return [Strirng] separated a space and removed empty field
    def to_s(verbose=false)
      units = (
        case verbose
        when false
          SHORTER_RADIXES
        when true
          VERBOSE_RADIXES
        else
          raise ArgumentError, 'Choose verbose-option from [true, false].'
        end
      ).sort_by{|key, val|val}.map{|key, val|key}.reverse

      if (list = to_a).all?{|size|size == 0}
        '0'
      else
        list.each_with_index.select{|size, i|size > 0}.map{|size, i|"#{size}#{units[i]}"}.join(' ')
      end
    end
    
    # @return [Array<Number>]
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
    
    private
    
    def replace(size, unit)
      raise ArgumentError, "Unknown unit. Choose from [#{RADIXES.keys.join(', ')}]." unless radix = RADIXES[unit]
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
  end
end
