warn 'Your Ruby version wasn\'t tested.' if RUBY_VERSION < '1.9.2'

require_relative 'unit/core'
require_relative 'unit/time_ext'