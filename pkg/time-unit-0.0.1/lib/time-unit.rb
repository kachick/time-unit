$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

class Time::Unit
  VERSION = '0.0.1'.freeze
  Version = VERSION
end
