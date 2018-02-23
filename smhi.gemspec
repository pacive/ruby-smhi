# simpleoauth.gemspec
# frozen_string_literal: true

require_relative 'lib/smhi'

Gem::Specification.new do |s|
  s.name      = 'smhi'
  s.version   = SMHI::VERSION
  s.date      = Time.now.strftime('%F')
  s.summary   = 'A flexible gem for getting weather forecasts from SMHI'
  s.author    = 'Anders Alfredsson'
  s.email     = 'andersb86@gmail.com'
  s.files     = ['lib/smhi.rb', 'lib/smhi/forecast.rb']
  s.homepage  = 'https://github.com/pacive/ruby-smhi'
  s.license   = 'GPL-3.0'
end
