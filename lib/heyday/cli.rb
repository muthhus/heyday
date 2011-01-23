$:.unshift File.expand_path('../vendor', __FILE__)
require 'thor'
require 'thor/actions'
require 'rubygems/user_interaction'
require 'rubygems/config_file'

# Work around a RubyGems bug
Gem.configuration

module Heyday
  class CLI < Thor
    include Thor::Actions

    def initialize(*)
      super
      the_shell = (options["no-color"] ? Thor::Shell::Basic.new : shell)
      Bundler.ui = UI::Shell.new(the_shell)
      Bundler.ui.debug! if options["verbose"]
      Gem::DefaultUserInteraction.ui = UI::RGProxy.new(Bundler.ui)
    end

    check_unknown_options! unless ARGV.include?("exec") || ARGV.include?("config")

    default_task :help
    class_option "no-color", :type => :boolean, :banner => "Disable colorization in output"
    class_option "verbose",  :type => :boolean, :banner => "Enable verbose output mode", :aliases => "-V"

    def help(cli = nil)
      case cli
      when "gemfile" then command = "gemfile.5"
      when nil       then command = "bundle"
      else command = "bundle-#{cli}"
      end

      manpages = %w(
          bundle
          bundle-config
          bundle-exec
          bundle-install
          bundle-package
          bundle-update
          gemfile.5)

      if manpages.include?(command)
        root = File.expand_path("../man", __FILE__)

        if have_groff? && root !~ %r{^file:/.+!/META-INF/jruby.home/.+}
          groff   = "groff -Wall -mtty-char -mandoc -Tascii"
          pager   = ENV['MANPAGER'] || ENV['PAGER'] || 'less'

          Kernel.exec "#{groff} #{root}/#{command} | #{pager}"
        else
          puts File.read("#{root}/#{command}.txt")
        end
      else
        super
      end
    end

    desc "new", "Creates a new Rails application with a built-in calendar"
    long_desc <<-D
      Creates a new Rails application with a built-in calendar. Just pass in the name of your application.
      $ heyday new my_scheduler
    D
    method_option "app_name", :type => :boolean, :banner =>
      "The name of the rails application to create"
    def new
      opts = options.dup

      if opts[:app_name].blank?
        puts "Enter a name for the new rails app. e.g. $ heyday new my_scheduler"
        exit 1
      end

      rails generate heyday:install --model_name=event --controller_name=calendar --jquery --layout // Generate files
      rake db:migrate 											// Migrate
      rails server 													// Start the server
      open http://localhost:3000/calendar 	// View the calendar

      system("rails new #{opts[:app_name]}")
      
      cd("#{opts[:app_name]}") do
        File.append("Gemfile", "\ngem 'heyday', :require => 'heyday'")
        system("bundle install")
        system("rails generate heyday:install --model_name=event --controller_name=calendar --jquery --layout")
        system("rake db:migrate")
        system("rails server")
        system("open http://localhost:3000/calendar")
      end
    end

    def self.source_root
      File.expand_path(File.join(File.dirname(__FILE__), 'templates'))
    end

  end
end
