$VERBOSE = true
require File.dirname(__FILE__) + '/test_helper.rb'

class TestTimeUnit < Test::Unit::TestCase

  def setup
    @unit1      = Time::Unit.new 9999
    @unit2      = Time::Unit.new 984578584383123, :millisecond
    @unit3      = Time::Unit.new 8888
    @unit_dummy = Time::Unit.new 9999
    @unit4      = Time::Unit.new Rational(3, 10), :sec
  end
  
  def test_parse
    assert_equal @unit1, Time::Unit.parse('2hour 46min 39sec')
    assert_equal @unit1, Time::Unit.parse('2hours 46minutes 39seconds')
    assert_equal Time::Unit.new(120, :min), Time::Unit.parse('1hours 30minutes 20minute 600sec')
    assert_equal @unit2, Time::Unit.parse('11395585day 11hour 13min 3sec 123msec')
    assert_equal @unit2, Time::Unit.parse('11395585dAys 11hoUr 13minutes 3second 123milliSecond')
    assert_raise(ArgumentError){Time::Unit.parse('1139dayz 11hour')}
  end
  
  def test_to_a
    var = nil
    assert_equal [0, 2, 46, 39, 0], (@unit1.instance_eval{var = to_a}; var)
    assert_equal [11395585, 11, 13, 3, 123], (@unit2.instance_eval{var = to_a}; var)
  end
  
  def test_to_s
    assert_equal '2hour 46min 39sec', @unit1.to_s
    assert_equal '2hours 46minutes 39seconds', @unit1.to_s(true)
    assert_equal '2hours 1minute 39seconds', (@unit1 - Time::Unit.new(45, :min)).to_s(true)
    assert_equal '11395585day 11hour 13min 3sec 123msec', @unit2.to_s
    assert_equal '11395585days 11hours 13minutes 3seconds 123milliseconds', @unit2.to_s(true)
    assert_equal '1hour 39minutes', Time::Unit.new(99, :min).to_s(true)
    assert_equal '2hours 1minute', (Time::Unit.new(99, :min) + Time::Unit.new(22, :min)).to_s(true)
    assert_equal '0msec', Time::Unit.new(0).to_s
    assert_equal '0millisecond', Time::Unit.new(0).to_s(true)
    assert_equal '300msec', @unit4.to_s
  end
  
  def test_construct_with_unitname
    assert_equal Rational(984578584383123, 1000), @unit2.second
    assert_equal @unit2, (Time::Unit.new 984578584383123, :msec)
    assert_raise(ArgumentError){Time::Unit.new(Rational(1, 99), :msec)}
    assert_raise(ArgumentError){Time::Unit.new(Rational(1, 1001), :sec)}
  end
  
  def test_eql?
    assert_equal @unit_dummy, @unit1
    assert_same true, @unit1 == @unit_dummy
    assert_not_equal @unit1, @unit2
    assert_same false, @unit_dummy.equal?(@unit1)
    assert_equal [@unit1, @unit2], [@unit1, @unit2, @unit_dummy].uniq
  end
  
  def test_operator
    assert_equal @unit1 + @unit3, Time::Unit.new(18887)
    assert_equal @unit1 - @unit3, Time::Unit.new(1111)
  end
  
  def test_compare
    assert(@unit2 > @unit1)
    assert(@unit3 < @unit1)
  end
  
  def test_attr_writer
    unit = @unit1.dup
    unit.minute = 30
    
    assert_not_equal @unit1, unit
    assert_equal(Time::Unit.new(1800), unit)
  end
  
  def test_truth
    assert true
  end

  def test_class_method
    assert_equal Time.Unit(5), Time::Unit.new(5)
    assert_equal Time.Unit(5).class, Time::Unit.new(5).class
  end
end
