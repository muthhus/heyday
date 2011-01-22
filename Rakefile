require 'rubygems'
require 'rake'
require 'echoe'

Echoe.new('heyday', '0.1.0') do |p|
  p.description = "Integrate fullcalendar jQuery plugin with Rails"
  p.summary = "An easy way to get a great calendar in any Rails3 project"
  p.url = "http://github.com/??/heyday"
  p.author = "Adam Stasio"
  p.email = "adamstasio@gmail.com"
  p.ignore_pattern = ["tmp/*", "script/*"]
  p.development_dependencies = []
end

Dir["#{File.dirname(__FILE__)}/tasks/*.rake"].sort.each { |ext| load ext }
