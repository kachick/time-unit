$VERBOSE = true
require File.dirname(__FILE__) + '/test_helper-import.rb'

class TestTimeUnit < Test::Unit::TestCase
  
  def test_minus
    last = Time.now
    sleep 1
    now = Time.now
    result = now - last

    assert_equal result.class, Time::Unit
    assert_equal result, 1
  end
end
