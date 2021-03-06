require_relative 'test_helper-import'

class TestTimeUnit < Test::Unit::TestCase
  def test_minus
    last = Time.now
    sleep 1
    now = Time.now
    result = now - last

    assert_equal Time::Unit, result.class
    assert_equal 1, result.to_i
  end
end
